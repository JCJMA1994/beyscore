import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../discovery/lan_discovery_service.dart';
import 'table_status.dart';

class LanHubServer {
  LanHubServer();

  HttpServer? _server;
  String? _localIp;
  int _port = 8080;
  bool _isRunning = false;

  final Map<int, TableStatus> _tables = {};
  final Set<String> _verifiedBladers = {};
  final Map<String, String> _rejectedBladers = {}; // nickname -> reason
  final Map<String, Map<String, dynamic>> _registeredDecks = {}; // nickname -> deck + combos
  final _eventController = StreamController<Map<int, TableStatus>>.broadcast();
  final _registrationController = StreamController<Map<String, dynamic>>.broadcast();

  final Set<WebSocket> _wsClients = {};
  final Map<WebSocket, String?> _wsClientPlayers = {};
  final Map<WebSocket, int?> _wsClientTables = {};
  final Set<HttpResponse> _sseClients = {};

  Map<String, dynamic>? currentTournamentJson;

  Stream<Map<int, TableStatus>> get tablesStream => _eventController.stream;
  Stream<Map<String, dynamic>> get registrationStream => _registrationController.stream;
  Map<int, TableStatus> get currentTables => Map.unmodifiable(_tables);
  Set<String> get verifiedBladers => Set.unmodifiable(_verifiedBladers);
  Map<String, String> get rejectedBladers => Map.unmodifiable(_rejectedBladers);
  bool get isRunning => _isRunning;
  String? get localIp => _localIp;
  int get port => _port;
  String get hubUrl => 'http://${_localIp ?? '127.0.0.1'}:$_port';
  int get connectedWebSocketCount => _wsClients.length;
  int get connectedSseCount => _sseClients.length;

  /// Broadcasts a real-time event to all connected WebSockets and SSE streams.
  void broadcastEvent(String type, Map<String, dynamic> payload) {
    final eventMap = {
      'type': type,
      'payload': payload,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    final jsonStr = jsonEncode(eventMap);

    // Send to WebSockets
    final deadSockets = <WebSocket>[];
    for (final ws in _wsClients) {
      try {
        ws.add(jsonStr);
      } catch (_) {
        deadSockets.add(ws);
      }
    }
    for (final dead in deadSockets) {
      _wsClients.remove(dead);
      _wsClientPlayers.remove(dead);
      _wsClientTables.remove(dead);
    }

    // Send to SSE clients
    final ssePayload = 'data: $jsonStr\n\n';
    final deadSse = <HttpResponse>[];
    for (final sse in _sseClients) {
      try {
        sse.write(ssePayload);
        sse.flush().catchError((_) {});
      } catch (_) {
        deadSse.add(sse);
      }
    }
    deadSse.forEach(_sseClients.remove);
  }

  void _handleWebSocketClient(WebSocket socket) {
    _wsClients.add(socket);

    // Send initial handshake state
    final welcomeEvent = {
      'type': 'HEARTBEAT',
      'payload': {
        'status': 'CONNECTED',
        'tournament_name': currentTournamentJson?['name'] ?? 'Torneo BeyScore',
        'tables_count': _tables.length,
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    try {
      socket.add(jsonEncode(welcomeEvent));
    } catch (_) {}

    socket.listen(
      (dynamic message) {
        if (message is! String) return;
        try {
          final decoded = jsonDecode(message);
          if (decoded is Map<String, dynamic>) {
            final action = decoded['action'] as String? ?? '';
            if (action == 'REGISTER') {
              final player = decoded['player'] as String?;
              final table = decoded['table'] as int?;
              if (player != null) _wsClientPlayers[socket] = player.trim();
              if (table != null) _wsClientTables[socket] = table;
            } else if (action == 'PING') {
              socket.add(jsonEncode({
                'type': 'HEARTBEAT',
                'payload': {'action': 'PONG'},
                'timestamp': DateTime.now().millisecondsSinceEpoch,
              }));
            }
          }
        } catch (_) {}
      },
      onDone: () {
        _wsClients.remove(socket);
        _wsClientPlayers.remove(socket);
        _wsClientTables.remove(socket);
      },
      onError: (_) {
        _wsClients.remove(socket);
        _wsClientPlayers.remove(socket);
        _wsClientTables.remove(socket);
      },
      cancelOnError: true,
    );
  }

  void _handleSseClient(HttpRequest request) {
    final response = request.response
      ..bufferOutput = false
      ..headers.add('Content-Type', 'text/event-stream; charset=utf-8')
      ..headers.add('Cache-Control', 'no-cache, no-transform')
      ..headers.add('Connection', 'keep-alive')
      ..headers.add('Access-Control-Allow-Origin', '*');

    _sseClients.add(response);

    // Send initial snapshot
    final initialSnapshot = {
      'type': 'HEARTBEAT',
      'payload': {
        'status': 'OK',
        'tournament_name': currentTournamentJson?['name'] ?? 'Torneo BeyScore',
        'tables_count': _tables.length,
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    response.write('data: ${jsonEncode(initialSnapshot)}\n\n');
    response.flush().catchError((_) {});

    response.done.then((_) {
      _sseClients.remove(response);
    }).catchError((_) {
      _sseClients.remove(response);
    });
  }

  Map<String, dynamic>? getDeckForBlader(String nickname) {
    final clean = nickname.trim().toLowerCase();
    for (final entry in _registeredDecks.entries) {
      if (entry.key.trim().toLowerCase() == clean) {
        return entry.value;
      }
    }
    return null;
  }

  void verifyBladerCheckIn(String nickname) {
    final clean = nickname.trim();
    if (clean.isEmpty) return;
    _verifiedBladers.add(clean);
    _rejectedBladers.removeWhere((k, _) => k.toLowerCase() == clean.toLowerCase());
    broadcastEvent('CHECKIN_VERIFIED', {
      'nickname': clean,
      'checkInVerified': true,
    });
  }

  void rejectBladerCheckIn(String nickname, String reason) {
    final clean = nickname.trim();
    if (clean.isEmpty) return;
    _verifiedBladers.removeWhere((b) => b.toLowerCase() == clean.toLowerCase());
    _rejectedBladers[clean] = reason;
    broadcastEvent('CHECKIN_REJECTED', {
      'nickname': clean,
      'checkInVerified': false,
      'isRejected': true,
      'rejectionReason': reason,
    });
  }

  Future<String?> _findLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  final _discoveryService = LanDiscoveryService();

  Future<bool> start({int port = 8080}) async {
    if (_isRunning) return true;
    _port = port;
    _localIp = await _findLocalIp();

    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      _isRunning = true;
      _server!.listen(_handleRequest);

      // Start UDP beacon for automatic LAN discovery
      unawaited(
        _discoveryService.startBeacon(
          hubUrl: hubUrl,
          tournamentName: currentTournamentJson?['name'] as String? ?? 'Torneo LAN',
        ),
      );

      return true;
    } catch (e) {
      _isRunning = false;
      return false;
    }
  }

  Future<void> stop() async {
    _isRunning = false;
    _discoveryService.stopBeacon();

    for (final ws in _wsClients.toList()) {
      try {
        await ws.close(WebSocketStatus.goingAway, 'Server stopping');
      } catch (_) {}
    }
    _wsClients.clear();
    _wsClientPlayers.clear();
    _wsClientTables.clear();

    for (final sse in _sseClients.toList()) {
      try {
        await sse.close();
      } catch (_) {}
    }
    _sseClients.clear();

    await _server?.close(force: true);
    _server = null;
  }

  void assignMatchToTable({
    required int tableNumber,
    required String playerA,
    required String playerB,
  }) {
    _tables[tableNumber] = TableStatus(
      tableNumber: tableNumber,
      playerA: playerA,
      playerB: playerB,
      scoreA: 0,
      scoreB: 0,
      status: 'RUNNING',
      lastSeen: DateTime.now(),
    );
    _eventController.add(_tables);
    broadcastEvent('MATCH_ASSIGNED', {
      'tableNumber': tableNumber,
      'table': tableNumber,
      'playerA': playerA,
      'playerB': playerB,
      'scoreA': 0,
      'scoreB': 0,
      'status': 'RUNNING',
    });
  }

  void resolveDispute({
    required int tableNumber,
    required int scoreA,
    required int scoreB,
  }) {
    final existing = _tables[tableNumber];
    if (existing != null) {
      _tables[tableNumber] = existing.copyWith(
        scoreA: scoreA,
        scoreB: scoreB,
        status: 'RUNNING',
        lastSeen: DateTime.now(),
      );
      _eventController.add(_tables);
      broadcastEvent('SCORE_UPDATED', {
        'tableNumber': tableNumber,
        'table': tableNumber,
        'playerA': existing.playerA,
        'playerB': existing.playerB,
        'scoreA': scoreA,
        'scoreB': scoreB,
        'status': 'RUNNING',
      });
    }
  }

  void completeTournament() {
    if (currentTournamentJson != null) {
      currentTournamentJson!['status'] = 'completed';
    }
    for (final table in _tables.values) {
      _tables[table.tableNumber] = table.copyWith(status: 'COMPLETED');
    }
    _eventController.add(_tables);
    broadcastEvent('TOURNAMENT_UPDATED', {
      'status': 'completed',
      'tournamentStatus': 'completed',
    });
  }

  Future<void> _handleRequest(HttpRequest request) async {
    // Check if it is a WebSocket upgrade request
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      try {
        final socket = await WebSocketTransformer.upgrade(request);
        _handleWebSocketClient(socket);
      } catch (_) {}
      return;
    }

    if (request.uri.path == '/ws') {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write('Expected WebSocket Upgrade');
      await request.response.close();
      return;
    }

    // Add CORS headers for table devices
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    try {
      final path = request.uri.path;

      // GET /api/events (Server-Sent Events for Web UI / OBS)
      if (path == '/api/events' && request.method == 'GET') {
        _handleSseClient(request);
        return;
      }

      // GET / (Spectator Dashboard)
      if ((path == '/' || path == '/live' || path == '/spectator') && request.method == 'GET') {
        const html = '''
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BeyScore — LAN Tournament Hub</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, monospace; }
    body { background: #06070C; color: #EEF1F7; padding: 20px; }
    header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #28324A; padding-bottom: 16px; margin-bottom: 24px; }
    h1 { font-size: 22px; letter-spacing: 2px; color: #00E5D0; }
    .badge { background: #151B29; border: 1px solid #28324A; padding: 6px 12px; border-radius: 6px; font-size: 12px; font-family: monospace; color: #00FF66; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 16px; }
    .card { background: #0E1220; border: 1px solid #28324A; border-radius: 12px; padding: 18px; box-shadow: 0 4px 12px rgba(0,0,0,0.5); }
    .table-title { font-size: 13px; font-weight: bold; color: #78859D; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 1.5px; }
    .vs-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
    .player { font-size: 18px; font-weight: bold; }
    .player-a { color: #2B6BFF; }
    .player-b { color: #FF3B2F; }
    .score { font-size: 32px; font-weight: 900; font-family: monospace; }
    .status-tag { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 10px; font-weight: bold; text-transform: uppercase; }
    .status-RUNNING { background: rgba(0, 229, 208, 0.15); color: #00E5D0; border: 1px solid #00E5D0; }
    .status-DISPUTE { background: rgba(255, 59, 47, 0.15); color: #FF3B2F; border: 1px solid #FF3B2F; }
    .status-CONFIRMED { background: rgba(0, 255, 102, 0.15); color: #00FF66; border: 1px solid #00FF66; }
    .empty-state { text-align: center; padding: 48px; color: #78859D; grid-column: 1 / -1; }
  </style>
</head>
<body>
  <header>
    <div>
      <h1>BEYSCORE · LAN HUB</h1>
      <p style="color: #78859D; font-size: 12px; margin-top: 4px;">Panel de Espectador en Vivo para Torneos Beyblade X</p>
    </div>
    <div class="badge" id="hub-info">CONECTANDO AL HUB...</div>
  </header>
  <div class="grid" id="tables-grid">
    <div class="empty-state">Buscando mesas de combate activas...</div>
  </div>
  <script>
    async function updateStatus() {
      try {
        const res = await fetch('/api/status');
        const data = await res.json();
        const tName = data.tournament_name || 'BEYSCORE';
        document.getElementById('hub-info').innerText = tName + ' · HUB: ' + (data.hub_ip || '127.0.0.1') + ' · MESAS: ' + data.tables_count;
        const grid = document.getElementById('tables-grid');
        if (!data.active_tables || data.active_tables.length === 0) {
          grid.innerHTML = '<div class="empty-state">No hay mesas asignadas aún. El organizador está configurando la ronda.</div>';
          return;
        }
        grid.innerHTML = data.active_tables.map(function(t) {
          return '<div class="card">' +
            '<div style="display: flex; justify-content: space-between; align-items: center;">' +
              '<div class="table-title">MESA ' + t.table + '</div>' +
              '<span class="status-tag status-' + t.status + '">' + t.status + '</span>' +
            '</div>' +
            '<div class="vs-row">' +
              '<div class="player player-a">' + t.playerA + '</div>' +
              '<div class="score player-a">' + t.scoreA + '</div>' +
            '</div>' +
            '<div class="vs-row" style="margin-bottom: 0;">' +
              '<div class="player player-b">' + t.playerB + '</div>' +
              '<div class="score player-b">' + t.scoreB + '</div>' +
            '</div>' +
          '</div>';
        }).join('');
      } catch (e) {
        document.getElementById('hub-info').innerText = 'DESCONECTADO';
      }
    }
    updateStatus();
    if (window.EventSource) {
      const sse = new EventSource('/api/events');
      sse.onmessage = function() { updateStatus(); };
      sse.onerror = function() { setInterval(updateStatus, 2000); };
    } else {
      setInterval(updateStatus, 2000);
    }
  </script>
</body>
</html>
''';
        request.response.headers.contentType = ContentType.html;
        request.response.write(html);
        await request.response.close();
        return;
      }

      // GET /stream-overlay or /overlay (OBS / Broadcast / Stadium HUD)
      if ((path == '/stream-overlay' || path == '/overlay') && request.method == 'GET') {
        final tableParam = int.tryParse(request.uri.queryParameters['table'] ?? '1') ?? 1;
        final isChroma = request.uri.queryParameters['chroma'] == 'true';
        final layout = request.uri.queryParameters['layout'] ?? 'standard';
        final bgColor = isChroma ? '#00FF00' : 'transparent';
        final isCompact = layout == 'compact';

        final overlayHtml = '''
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BeyScore — Stream HUD Overlay</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, sans-serif; }
    body {
      background: $bgColor;
      overflow: hidden;
      width: 100vw;
      height: 100vh;
      display: flex;
      align-items: ${isCompact ? 'flex-start' : 'flex-end'};
      justify-content: ${isCompact ? 'flex-start' : 'center'};
      padding: ${isCompact ? '24px' : '32px'};
    }
    
    .hud-container {
      display: flex;
      align-items: center;
      background: rgba(6, 7, 12, 0.92);
      backdrop-filter: blur(16px);
      border: 1px solid rgba(255, 255, 255, 0.18);
      border-radius: ${isCompact ? '8px' : '14px'};
      padding: ${isCompact ? '8px 16px' : '14px 28px'};
      box-shadow: 0 12px 32px rgba(0,0,0,0.85), 0 0 24px rgba(0, 229, 208, 0.25);
      min-width: ${isCompact ? '420px' : '680px'};
      max-width: ${isCompact ? '540px' : '900px'};
      position: relative;
      transition: transform 0.2s ease;
    }
    
    .player-box {
      flex: 1;
      display: flex;
      align-items: center;
    }
    .player-box.right {
      justify-content: flex-end;
      text-align: right;
    }
    
    .name-col {
      display: flex;
      flex-direction: column;
    }
    
    .player-name {
      font-size: ${isCompact ? '16px' : '22px'};
      font-weight: 900;
      letter-spacing: 1.5px;
      text-transform: uppercase;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      max-width: ${isCompact ? '130px' : '220px'};
    }
    .player-a-name { color: #2B6BFF; text-shadow: 0 0 12px rgba(43,107,255,0.7); }
    .player-b-name { color: #FF3B2F; text-shadow: 0 0 12px rgba(255,59,47,0.7); }
    
    .bey-name {
      font-size: ${isCompact ? '9px' : '11px'};
      color: #78859D;
      font-family: monospace;
      margin-top: 1px;
    }
    
    .score-badge {
      font-size: ${isCompact ? '26px' : '38px'};
      font-weight: 900;
      font-family: monospace;
      padding: ${isCompact ? '2px 12px' : '4px 20px'};
      border-radius: 8px;
      margin: ${isCompact ? '0 10px' : '0 18px'};
      background: #151B29;
      border: 1.5px solid #28324A;
      color: #EEF1F7;
      transition: transform 0.2s ease;
    }
    
    .score-a { color: #2B6BFF; border-color: rgba(43,107,255,0.6); }
    .score-b { color: #FF3B2F; border-color: rgba(255,59,47,0.6); }
    
    .center-hud {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: ${isCompact ? '0 10px' : '0 18px'};
      border-left: 1px solid rgba(255,255,255,0.12);
      border-right: 1px solid rgba(255,255,255,0.12);
    }
    
    .logo-tag {
      font-size: ${isCompact ? '9px' : '11px'};
      font-weight: 900;
      letter-spacing: 2px;
      color: #00E5D0;
    }
    .target-pts {
      font-size: ${isCompact ? '8px' : '9px'};
      color: #FFB300;
      font-family: monospace;
      margin-top: 2px;
    }

    /* Finish Type Live Pop-Up Banner */
    .finish-banner {
      position: absolute;
      top: -46px;
      left: 50%;
      transform: translateX(-50%) scale(0.8);
      background: #000;
      padding: 6px 18px;
      border-radius: 20px;
      font-size: 13px;
      font-weight: 900;
      letter-spacing: 1.5px;
      text-transform: uppercase;
      opacity: 0;
      pointer-events: none;
      transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      white-space: nowrap;
      box-shadow: 0 4px 20px rgba(0,0,0,0.8);
    }
    .finish-banner.show {
      opacity: 1;
      transform: translateX(-50%) scale(1);
    }
    .finish-XTREME { background: #FFB300; color: #06070C; box-shadow: 0 0 24px rgba(255,179,0,0.8); }
    .finish-BURST { background: #FF3B2F; color: #FFF; box-shadow: 0 0 24px rgba(255,59,47,0.8); }
    .finish-OVER { background: #00FF66; color: #06070C; box-shadow: 0 0 24px rgba(0,255,102,0.8); }
    .finish-SPIN { background: #2B6BFF; color: #FFF; box-shadow: 0 0 24px rgba(43,107,255,0.8); }
    .finish-PENALTY { background: #FF8800; color: #000; }
  </style>
</head>
<body>
  <div class="hud-container">
    <div id="finish-banner" class="finish-banner">XTREME FINISH! +3</div>
    
    <div class="player-box">
      <div class="name-col">
        <div class="player-name player-a-name" id="pA-name">BLADER A</div>
        <div class="bey-name" id="pA-bey">ESTADIO X</div>
      </div>
      <div class="score-badge score-a" id="pA-score">0</div>
    </div>
    
    <div class="center-hud">
      <div class="logo-tag">MESA $tableParam</div>
      <div class="target-pts">PRIMERO A 4 PTS</div>
    </div>
    
    <div class="player-box right">
      <div class="score-badge score-b" id="pB-score">0</div>
      <div class="name-col">
        <div class="player-name player-b-name" id="pB-name">BLADER B</div>
        <div class="bey-name" id="pB-bey">ESTADIO X</div>
      </div>
    </div>
  </div>

  <script>
    const tableNum = $tableParam;
    let lastScoreA = 0;
    let lastScoreB = 0;
    let bannerTimeout = null;

    function triggerFinishAnimation(finishType, isPenalty) {
      const banner = document.getElementById('finish-banner');
      if (!banner) return;

      let text = '';
      let cls = '';

      if (isPenalty) {
        text = '⚠️ PENALIZACIÓN (+1 PT)';
        cls = 'finish-PENALTY';
      } else if (finishType) {
        const clean = finishType.toUpperCase();
        if (clean.includes('XTREME')) {
          text = '💥 XTREME FINISH! +3 PTS';
          cls = 'finish-XTREME';
        } else if (clean.includes('BURST')) {
          text = '💥 BURST FINISH! +2 PTS';
          cls = 'finish-BURST';
        } else if (clean.includes('OVER')) {
          text = '🌀 OVER FINISH! +2 PTS';
          cls = 'finish-OVER';
        } else {
          text = '⚡ SPIN FINISH! +1 PT';
          cls = 'finish-SPIN';
        }
      }

      if (text) {
        banner.className = 'finish-banner ' + cls + ' show';
        banner.innerText = text;
        clearTimeout(bannerTimeout);
        bannerTimeout = setTimeout(function() {
          banner.className = 'finish-banner';
        }, 2800);
      }
    }

    async function refresh() {
      try {
        const res = await fetch('/api/table?table=' + tableNum);
        const t = await res.json();
        if (t && t.table) {
          document.getElementById('pA-name').innerText = t.playerA || 'BLADER A';
          document.getElementById('pB-name').innerText = t.playerB || 'BLADER B';
          
          if (t.scoreA !== lastScoreA || t.scoreB !== lastScoreB) {
            triggerFinishAnimation(t.lastFinishType, t.isPenalty);
            lastScoreA = t.scoreA;
            lastScoreB = t.scoreB;
          }

          document.getElementById('pA-score').innerText = t.scoreA;
          document.getElementById('pB-score').innerText = t.scoreB;
        }
      } catch (e) {}
    }

    refresh();
    if (window.EventSource) {
      const sse = new EventSource('/api/events');
      sse.onmessage = function(e) {
        try {
          const d = JSON.parse(e.data);
          if (d.type === 'SCORE_UPDATED' || d.type === 'MATCH_ASSIGNED' || d.type === 'HEARTBEAT') {
            if (d.payload && d.payload.table == tableNum && d.payload.finishType) {
              triggerFinishAnimation(d.payload.finishType, d.payload.isPenalty);
            }
            refresh();
          }
        } catch(_) { refresh(); }
      };
      sse.onerror = function() { setInterval(refresh, 1000); };
    } else {
      setInterval(refresh, 800);
    }
  </script>
</body>
</html>
''';
        request.response.headers.contentType = ContentType.html;
        request.response.write(overlayHtml);
        await request.response.close();
        return;
      }

      // GET /stadium-board (Giant Stadium Screen / Jumbotron / Projector)
      if (path == '/stadium-board' && request.method == 'GET') {
        const stadiumHtml = '''
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BeyScore — Pantalla Gigante de Estadio</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Roboto', -apple-system, sans-serif; }
    body { background: #06070C; color: #EEF1F7; padding: 24px; min-height: 100vh; display: flex; flex-direction: column; }
    
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: #0E1220;
      border: 1px solid #28324A;
      border-radius: 12px;
      padding: 16px 24px;
      margin-bottom: 24px;
      box-shadow: 0 4px 20px rgba(0,229,208,0.08);
    }
    
    .logo-area { display: flex; align-items: center; gap: 16px; }
    .brand-icon {
      width: 42px; height: 42px; background: #00E5D0;
      clip-path: polygon(25% 0%, 100% 0%, 75% 100%, 0% 100%);
      display: flex; align-items: center; justify-content: center;
      font-weight: 900; color: #06070C; font-size: 20px;
    }
    .brand-title { font-size: 24px; font-weight: 900; letter-spacing: 3px; color: #00E5D0; }
    .brand-subtitle { font-size: 11px; color: #78859D; letter-spacing: 1.5px; text-transform: uppercase; }
    
    .stats-bar { display: flex; gap: 16px; align-items: center; }
    .stat-pill {
      background: #151B29;
      border: 1px solid #28324A;
      border-radius: 8px;
      padding: 8px 16px;
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    .stat-val { font-size: 16px; font-weight: bold; color: #00E5D0; font-family: monospace; }
    .stat-lbl { font-size: 9px; color: #78859D; text-transform: uppercase; letter-spacing: 1px; }

    .grid-container {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(420px, 1fr));
      gap: 20px;
      flex: 1;
    }

    .table-jumbotron {
      background: #0E1220;
      border: 2px solid #28324A;
      border-radius: 16px;
      padding: 24px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      box-shadow: 0 8px 24px rgba(0,0,0,0.6);
      transition: all 0.3s ease;
      position: relative;
    }
    .table-jumbotron.active { border-color: rgba(0, 229, 208, 0.4); box-shadow: 0 8px 24px rgba(0, 229, 208, 0.15); }
    .table-jumbotron.match-point { border-color: #FFB300; box-shadow: 0 0 24px rgba(255,179,0,0.3); }
    .table-jumbotron.dispute { border-color: #FF3B2F; box-shadow: 0 8px 24px rgba(255, 59, 47, 0.4); }

    .tbl-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      border-bottom: 1px solid #1C2333;
      padding-bottom: 12px;
    }
    .tbl-num { font-size: 14px; font-weight: 900; letter-spacing: 2px; color: #78859D; text-transform: uppercase; }
    .tbl-badge {
      font-size: 10px; font-weight: 900; text-transform: uppercase; letter-spacing: 1px;
      padding: 4px 10px; border-radius: 6px;
    }
    .badge-RUNNING { background: rgba(0, 229, 208, 0.15); color: #00E5D0; border: 1px solid #00E5D0; }
    .badge-MATCH_POINT { background: rgba(255, 179, 0, 0.2); color: #FFB300; border: 1px solid #FFB300; }
    .badge-DISPUTE { background: rgba(255, 59, 47, 0.2); color: #FF3B2F; border: 1px solid #FF3B2F; animation: pulse 1s infinite; }

    @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }

    .vs-arena {
      display: grid;
      grid-template-columns: 1fr auto 1fr;
      align-items: center;
      gap: 16px;
      margin: 12px 0;
    }
    .player-col { display: flex; flex-direction: column; }
    .player-col.right { align-items: flex-end; text-align: right; }
    
    .p-name { font-size: 22px; font-weight: 900; letter-spacing: 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .p-name.a { color: #2B6BFF; }
    .p-name.b { color: #FF3B2F; }
    
    .p-score {
      font-size: 64px;
      font-weight: 900;
      font-family: monospace;
      line-height: 1;
      margin-top: 6px;
    }
    .p-score.a { color: #2B6BFF; text-shadow: 0 0 20px rgba(43,107,255,0.6); }
    .p-score.b { color: #FF3B2F; text-shadow: 0 0 20px rgba(255,59,47,0.6); }

    .mid-divider {
      display: flex;
      flex-direction: column;
      align-items: center;
      font-size: 12px;
      font-weight: 900;
      color: #78859D;
      padding: 0 10px;
    }
    .target-tag { font-size: 9px; color: #FFB300; letter-spacing: 1px; font-family: monospace; margin-top: 4px; }

    .empty-prompt {
      text-align: center;
      padding: 80px 20px;
      color: #78859D;
      grid-column: 1 / -1;
      font-size: 16px;
      background: #0E1220;
      border: 1px dashed #28324A;
      border-radius: 12px;
    }
  </style>
</head>
<body>
  <header>
    <div class="logo-area">
      <div class="brand-icon">X</div>
      <div>
        <div class="brand-title">BEYSCORE · STADIUM JUMBOTRON</div>
        <div class="brand-subtitle">Pantalla Gigante de Torneo en Vivo · Red Local LAN</div>
      </div>
    </div>
    <div class="stats-bar">
      <div class="stat-pill">
        <span class="stat-val" id="page-indicator">1/1</span>
        <span class="stat-lbl">PÁGINA</span>
      </div>
      <div class="stat-pill">
        <span class="stat-val" id="time-clock">--:--</span>
        <span class="stat-lbl">HORA LOCAL</span>
      </div>
      <div class="stat-pill">
        <span class="stat-val" id="table-count">0</span>
        <span class="stat-lbl">MESAS ACTIVAS</span>
      </div>
    </div>
  </header>

  <div class="grid-container" id="jumbotron-grid">
    <div class="empty-prompt">Esperando asignación de combates por el organizador...</div>
  </div>

  <script>
    let allTables = [];
    let currentPage = 0;
    const PAGE_SIZE = 8;

    function updateClock() {
      const now = new Date();
      document.getElementById('time-clock').innerText = now.toTimeString().split(' ')[0];
    }
    setInterval(updateClock, 1000);
    updateClock();

    function renderCurrentPage() {
      const grid = document.getElementById('jumbotron-grid');
      document.getElementById('table-count').innerText = allTables.length;

      if (!allTables || allTables.length === 0) {
        grid.innerHTML = '<div class="empty-prompt">No hay mesas en combate en este momento.</div>';
        document.getElementById('page-indicator').innerText = '1/1';
        return;
      }

      const totalPages = Math.ceil(allTables.length / PAGE_SIZE) || 1;
      if (currentPage >= totalPages) currentPage = 0;
      document.getElementById('page-indicator').innerText = (currentPage + 1) + '/' + totalPages;

      const pageItems = allTables.slice(currentPage * PAGE_SIZE, (currentPage + 1) * PAGE_SIZE);

      grid.innerHTML = pageItems.map(function(t) {
        const isDispute = t.status === 'DISPUTE';
        const isMatchPoint = (t.scoreA >= 3 || t.scoreB >= 3) && !isDispute;
        let cardCls = 'active';
        let badgeCls = 'badge-RUNNING';
        let badgeText = t.status;

        if (isDispute) {
          cardCls = 'dispute';
          badgeCls = 'badge-DISPUTE';
        } else if (isMatchPoint) {
          cardCls = 'match-point';
          badgeCls = 'badge-MATCH_POINT';
          badgeText = 'MATCH POINT';
        }

        return '<div class="table-jumbotron ' + cardCls + '">' +
          '<div class="tbl-top">' +
            '<span class="tbl-num">MESA ' + t.table + '</span>' +
            '<span class="tbl-badge ' + badgeCls + '">' + badgeText + '</span>' +
          '</div>' +
          '<div class="vs-arena">' +
            '<div class="player-col">' +
              '<span class="p-name a">' + (t.playerA || 'BLADER A') + '</span>' +
              '<span class="p-score a">' + t.scoreA + '</span>' +
            '</div>' +
            '<div class="mid-divider">' +
              '<span>VS</span>' +
              '<span class="target-tag">OBJETIVO: 4 PTS</span>' +
            '</div>' +
            '<div class="player-col right">' +
              '<span class="p-name b">' + (t.playerB || 'BLADER B') + '</span>' +
              '<span class="p-score b">' + t.scoreB + '</span>' +
            '</div>' +
          '</div>' +
        '</div>';
      }).join('');
    }

    // Auto-rotate pages every 8 seconds if there are multiple pages
    setInterval(function() {
      const totalPages = Math.ceil(allTables.length / PAGE_SIZE) || 1;
      if (totalPages > 1) {
        currentPage = (currentPage + 1) % totalPages;
        renderCurrentPage();
      }
    }, 8000);

    async function pollStadiumStatus() {
      try {
        const res = await fetch('/api/status');
        const data = await res.json();
        allTables = data.active_tables || [];
        if (data.tournament_name) {
          const titleEl = document.querySelector('.brand-title');
          if (titleEl) titleEl.innerText = data.tournament_name.toUpperCase();
        }
        renderCurrentPage();
      } catch (e) {}
    }

    pollStadiumStatus();
    if (window.EventSource) {
      const sse = new EventSource('/api/events');
      sse.onmessage = function() { pollStadiumStatus(); };
      sse.onerror = function() { setInterval(pollStadiumStatus, 1500); };
    } else {
      setInterval(pollStadiumStatus, 1000);
    }
  </script>
</body>
</html>
''';
        request.response.headers.contentType = ContentType.html;
        request.response.write(stadiumHtml);
        await request.response.close();
        return;
      }

      // GET /api/status
      if (path == '/api/status' && request.method == 'GET') {
        final activeTablesList = <Map<String, dynamic>>[];
        final now = DateTime.now();

        if (_tables.isNotEmpty) {
          activeTablesList.addAll(
            _tables.values.map(
              (t) => {
                'table': t.tableNumber,
                'playerA': t.playerA,
                'playerB': t.playerB,
                'scoreA': t.scoreA,
                'scoreB': t.scoreB,
                'status': t.status,
                'lastFinishType': t.lastFinishType,
                'isPenalty': t.isPenalty,
                'last_seen_ago_seconds': now.difference(t.lastSeen).inSeconds,
                'is_online': now.difference(t.lastSeen).inSeconds < 12,
              },
            ),
          );
        } else if (currentTournamentJson != null && currentTournamentJson!['rounds'] is List) {
          final rounds = currentTournamentJson!['rounds'] as List;
          for (final r in rounds) {
            if (r is Map && r['matchups'] is List) {
              final matchups = r['matchups'] as List;
              for (var i = 0; i < matchups.length; i++) {
                final m = matchups[i];
                if (m is Map && !(m['isCompleted'] as bool? ?? false) && !(m['isBye'] as bool? ?? false)) {
                  final pA = (m['playerAName'] as String? ?? '').trim();
                  final pB = (m['playerBName'] as String? ?? '').trim();
                  if (pA.isNotEmpty && pA != 'TBD' && pB.isNotEmpty && pB != 'TBD') {
                    final tNum = (m['tableNumber'] as int?) ?? (i + 1);
                    activeTablesList.add({
                      'table': tNum,
                      'playerA': pA,
                      'playerB': pB,
                      'scoreA': (m['scoreA'] as int?) ?? 0,
                      'scoreB': (m['scoreB'] as int?) ?? 0,
                      'status': 'RUNNING',
                      'last_seen_ago_seconds': 0,
                      'is_online': true,
                    });
                  }
                }
              }
              if (activeTablesList.isNotEmpty) break;
            }
          }
        }

        final data = {
          'status': 'OK',
          'hub_ip': _localIp,
          'tournament_name': currentTournamentJson?['name'] ?? 'Torneo BeyScore',
          'tier': currentTournamentJson?['tier'] ?? 'G3',
          'tournament_status': currentTournamentJson?['status'] ?? 'RUNNING',
          'tables_count': activeTablesList.isNotEmpty ? activeTablesList.length : _tables.length,
          'active_tables': activeTablesList,
        };
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(data));
        await request.response.close();
        return;
      }

      // GET /api/tournament
      if (path == '/api/tournament' && request.method == 'GET') {
        if (currentTournamentJson == null) {
          request.response.statusCode = HttpStatus.notFound;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'error': 'No hay torneo activo en el Hub LAN'}));
        } else {
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode(currentTournamentJson));
        }
        await request.response.close();
        return;
      }

      // POST /api/tournament/register
      if (path == '/api/tournament/register' && request.method == 'POST') {
        final bodyStr = await utf8.decodeStream(request);
        final json = jsonDecode(bodyStr) as Map<String, dynamic>;
        final nickname = (json['nickname'] as String? ?? '').trim();
        final deckData = json['deck'] as Map<String, dynamic>?;
        final combosData = json['combos'] as List<dynamic>?;

        if (currentTournamentJson != null && nickname.isNotEmpty) {
          final participants = List<String>.from(currentTournamentJson!['participants'] as List? ?? []);
          final exists = participants.any((p) => p.trim().toLowerCase() == nickname.toLowerCase());
          if (!exists) {
            participants.add(nickname);
            currentTournamentJson!['participants'] = participants;
          }
        }

        if (nickname.isNotEmpty) {
          if (deckData != null || combosData != null) {
            _registeredDecks[nickname] = {
              'deck': deckData,
              'combos': combosData,
            };
          }

          _registrationController.add({
            'nickname': nickname,
            'deck': deckData,
            'combos': combosData,
          });

          broadcastEvent('PLAYER_REGISTERED', {
            'nickname': nickname,
            'deck': deckData,
            'combos': combosData,
          });
        }

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({
          'status': 'REGISTERED',
          'nickname': nickname,
          'tournament': currentTournamentJson,
        }));
        await request.response.close();
        return;
      }

      // GET /api/tournament/player/:nickname
      final playerMatch = RegExp(r'^/api/tournament/player/([^/]+)$').firstMatch(path);
      if (playerMatch != null && request.method == 'GET') {
        final nickname = Uri.decodeComponent(playerMatch.group(1)!).trim();
        final participants = List<String>.from(currentTournamentJson?['participants'] as List? ?? []);
        final isRegistered = participants.any((p) => p.trim().toLowerCase() == nickname.toLowerCase());
        final isVerified = _verifiedBladers.any((b) => b.trim().toLowerCase() == nickname.toLowerCase());
        final rejectionReason = _rejectedBladers.entries
            .firstWhere(
              (e) => e.key.trim().toLowerCase() == nickname.toLowerCase(),
              orElse: () => const MapEntry('', ''),
            )
            .value;
        final actualReason = rejectionReason.isNotEmpty ? rejectionReason : null;
        final bladerDeck = getDeckForBlader(nickname);

        // Check if blader has an active match on any table
        int? assignedTable;
        String? opponent;
        var myScore = 0;
        var oppScore = 0;
        var tableStatus = 'IDLE';

        for (final table in _tables.values) {
          if (table.playerA.trim().toLowerCase() == nickname.toLowerCase()) {
            assignedTable = table.tableNumber;
            opponent = table.playerB;
            myScore = table.scoreA;
            oppScore = table.scoreB;
            tableStatus = table.status;
            break;
          } else if (table.playerB.trim().toLowerCase() == nickname.toLowerCase()) {
            assignedTable = table.tableNumber;
            opponent = table.playerA;
            myScore = table.scoreB;
            oppScore = table.scoreA;
            tableStatus = table.status;
            break;
          }
        }

        final data = {
          'nickname': nickname,
          'isRegistered': isRegistered,
          'checkInVerified': isVerified,
          'isRejected': actualReason != null,
          'rejectionReason': actualReason,
          'assignedTable': assignedTable,
          'opponent': opponent,
          'myScore': myScore,
          'opponentScore': oppScore,
          'tableStatus': tableStatus,
          'tournamentStatus': currentTournamentJson?['status'] ?? 'NONE',
          'deck': bladerDeck?['deck'],
          'combos': bladerDeck?['combos'],
        };

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(data));
        await request.response.close();
        return;
      }

      // POST /api/checkin/:nickname/verify
      final verifyMatch = RegExp(r'^/api/checkin/([^/]+)/verify$').firstMatch(path);
      if (verifyMatch != null && request.method == 'POST') {
        final nickname = Uri.decodeComponent(verifyMatch.group(1)!).trim();
        verifyBladerCheckIn(nickname);
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'status': 'VERIFIED', 'nickname': nickname}));
        await request.response.close();
        return;
      }

      // POST /api/checkin/:nickname/reject
      final rejectMatch = RegExp(r'^/api/checkin/([^/]+)/reject$').firstMatch(path);
      if (rejectMatch != null && request.method == 'POST') {
        final nickname = Uri.decodeComponent(rejectMatch.group(1)!).trim();
        final bodyStr = await utf8.decodeStream(request);
        final json = bodyStr.isNotEmpty ? jsonDecode(bodyStr) as Map<String, dynamic> : <String, dynamic>{};
        final reason = json['reason'] as String? ?? 'Deck no cumple con el reglamento';
        rejectBladerCheckIn(nickname, reason);
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'status': 'REJECTED', 'nickname': nickname, 'reason': reason}));
        await request.response.close();
        return;
      }

      // Match table path: /api/table/:num/...
      final tableMatch = RegExp(r'^/api/table/(\d+)(/.*)?$').firstMatch(path);
      if (tableMatch != null) {
        final tableNum = int.parse(tableMatch.group(1)!);
        final subpath = tableMatch.group(2) ?? '';

        // GET /api/table/:num
        if (subpath.isEmpty && request.method == 'GET') {
          var table = _tables[tableNum];
          if (table == null && currentTournamentJson != null && currentTournamentJson!['rounds'] is List) {
            final rounds = currentTournamentJson!['rounds'] as List;
            for (final r in rounds) {
              if (r is Map && r['matchups'] is List) {
                final matchups = r['matchups'] as List;
                for (var i = 0; i < matchups.length; i++) {
                  final m = matchups[i];
                  if (m is Map && !(m['isCompleted'] as bool? ?? false) && !(m['isBye'] as bool? ?? false)) {
                    final tNum = (m['tableNumber'] as int?) ?? (i + 1);
                    if (tNum == tableNum) {
                      final pA = (m['playerAName'] as String? ?? '').trim();
                      final pB = (m['playerBName'] as String? ?? '').trim();
                      if (pA.isNotEmpty && pA != 'TBD' && pB.isNotEmpty && pB != 'TBD') {
                        table = TableStatus(
                          tableNumber: tableNum,
                          playerA: pA,
                          playerB: pB,
                          scoreA: (m['scoreA'] as int?) ?? 0,
                          scoreB: (m['scoreB'] as int?) ?? 0,
                          status: 'RUNNING',
                          lastSeen: DateTime.now(),
                        );
                        _tables[tableNum] = table;
                        _eventController.add(_tables);
                        break;
                      }
                    }
                  }
                }
                if (table != null) break;
              }
            }
          }

          if (table == null) {
            request.response.statusCode = HttpStatus.notFound;
            request.response.write(jsonEncode({'error': 'Mesa no asignada'}));
          } else {
            _tables[tableNum] = table.copyWith(lastSeen: DateTime.now());
            _eventController.add(_tables);
            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode({
              'table': table.tableNumber,
              'playerA': table.playerA,
              'playerB': table.playerB,
              'scoreA': table.scoreA,
              'scoreB': table.scoreB,
              'status': table.status,
              'lastFinishType': table.lastFinishType,
              'isPenalty': table.isPenalty,
            }));
          }
          await request.response.close();
          return;
        }

        // POST /api/table/:num/finish
        if (subpath == '/finish' && request.method == 'POST') {
          final bodyStr = await utf8.decodeStream(request);
          final json = jsonDecode(bodyStr) as Map<String, dynamic>;

          final scoreA = json['scoreA'] as int? ?? 0;
          final scoreB = json['scoreB'] as int? ?? 0;
          final finishType = json['finishType'] as String?;
          final isPenalty = json['isPenalty'] as bool? ?? false;

          final existing = _tables[tableNum];
          if (existing != null) {
            final updated = existing.copyWith(
              scoreA: scoreA,
              scoreB: scoreB,
              lastFinishType: finishType,
              isPenalty: isPenalty,
              lastSeen: DateTime.now(),
            );
            _tables[tableNum] = updated;
            _eventController.add(_tables);

            broadcastEvent('SCORE_UPDATED', {
              'tableNumber': tableNum,
              'table': tableNum,
              'playerA': updated.playerA,
              'playerB': updated.playerB,
              'scoreA': scoreA,
              'scoreB': scoreB,
              'finishType': finishType,
              'isPenalty': isPenalty,
              'status': updated.status,
            });
          }

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'status': 'RECORDED'}));
          await request.response.close();
          return;
        }

        // POST /api/table/:num/dispute
        if (subpath == '/dispute' && request.method == 'POST') {
          final existing = _tables[tableNum];
          if (existing != null) {
            final updated = existing.copyWith(
              status: 'DISPUTE',
              lastSeen: DateTime.now(),
            );
            _tables[tableNum] = updated;
            _eventController.add(_tables);

            broadcastEvent('DISPUTE_FLAGGED', {
              'tableNumber': tableNum,
              'table': tableNum,
              'playerA': updated.playerA,
              'playerB': updated.playerB,
              'status': 'DISPUTE',
            });
          }

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'status': 'DISPUTE_REPORTED'}));
          await request.response.close();
          return;
        }

        // POST /api/table/:num/confirm
        if (subpath == '/confirm' && request.method == 'POST') {
          final existing = _tables[tableNum];
          if (existing != null) {
            final updated = existing.copyWith(
              status: 'CONFIRMED',
              lastSeen: DateTime.now(),
            );
            _tables[tableNum] = updated;
            _eventController.add(_tables);

            broadcastEvent('SCORE_UPDATED', {
              'tableNumber': tableNum,
              'table': tableNum,
              'playerA': updated.playerA,
              'playerB': updated.playerB,
              'scoreA': updated.scoreA,
              'scoreB': updated.scoreB,
              'status': 'CONFIRMED',
            });
          }

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'status': 'CONFIRMED_OK'}));
          await request.response.close();
          return;
        }
      }

      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    } catch (e) {
      try {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'error': 'Bad Request: $e'}));
        await request.response.close();
      } catch (_) {}
    }
  }
}
