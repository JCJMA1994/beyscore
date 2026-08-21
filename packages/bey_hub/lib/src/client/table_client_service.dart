import 'dart:convert';
import 'package:http/http.dart' as http;

class TableClientData {
  const TableClientData({
    required this.tableNumber,
    required this.playerA,
    required this.playerB,
    required this.scoreA,
    required this.scoreB,
    required this.status,
    this.lastFinishType,
    this.isPenalty = false,
  });

  factory TableClientData.fromJson(Map<String, dynamic> json) {
    return TableClientData(
      tableNumber: json['table'] as int? ?? 1,
      playerA: json['playerA'] as String? ?? '',
      playerB: json['playerB'] as String? ?? '',
      scoreA: json['scoreA'] as int? ?? 0,
      scoreB: json['scoreB'] as int? ?? 0,
      status: json['status'] as String? ?? 'IDLE',
      lastFinishType: json['lastFinishType'] as String?,
      isPenalty: json['isPenalty'] as bool? ?? false,
    );
  }

  final int tableNumber;
  final String playerA;
  final String playerB;
  final int scoreA;
  final int scoreB;
  final String status;
  final String? lastFinishType;
  final bool isPenalty;
}

class PlayerHubStatus {
  const PlayerHubStatus({
    required this.nickname,
    required this.isRegistered,
    required this.checkInVerified,
    required this.isRejected,
    this.rejectionReason,
    this.assignedTable,
    this.opponent,
    this.myScore = 0,
    this.opponentScore = 0,
    this.tableStatus = 'IDLE',
    this.tournamentStatus = 'NONE',
  });

  factory PlayerHubStatus.fromJson(Map<String, dynamic> json) {
    return PlayerHubStatus(
      nickname: json['nickname'] as String? ?? '',
      isRegistered: json['isRegistered'] as bool? ?? false,
      checkInVerified: json['checkInVerified'] as bool? ?? false,
      isRejected: json['isRejected'] as bool? ?? false,
      rejectionReason: json['rejectionReason'] as String?,
      assignedTable: json['assignedTable'] as int?,
      opponent: json['opponent'] as String?,
      myScore: json['myScore'] as int? ?? 0,
      opponentScore: json['opponentScore'] as int? ?? 0,
      tableStatus: json['tableStatus'] as String? ?? 'IDLE',
      tournamentStatus: json['tournamentStatus'] as String? ?? 'NONE',
    );
  }

  final String nickname;
  final bool isRegistered;
  final bool checkInVerified;
  final bool isRejected;
  final String? rejectionReason;
  final int? assignedTable;
  final String? opponent;
  final int myScore;
  final int opponentScore;
  final String tableStatus;
  final String tournamentStatus;
}

class TableClientService {
  TableClientService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  String _formatUrl(String baseUrl, String path) {
    var formatted = baseUrl.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'http://$formatted';
    }
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return '$formatted$path';
  }

  /// Fetches the assigned match and status for a specific table.
  Future<TableClientData?> fetchTableStatus({
    required String hubUrl,
    required int tableNumber,
  }) async {
    try {
      final uri = Uri.parse(_formatUrl(hubUrl, '/api/table/$tableNumber'));
      final response = await _client.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return TableClientData.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  /// Fetches live player status (registered, checkin, assigned table, live match) from Hub.
  Future<PlayerHubStatus?> fetchPlayerStatus({
    required String hubUrl,
    required String nickname,
  }) async {
    try {
      final encodedNick = Uri.encodeComponent(nickname);
      final uri = Uri.parse(_formatUrl(hubUrl, '/api/tournament/player/$encodedNick'));
      final response = await _client.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PlayerHubStatus.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  /// Reports real-time score to the LAN Hub.
  Future<bool> sendScore({
    required String hubUrl,
    required int tableNumber,
    required int scoreA,
    required int scoreB,
    String? finishType,
    bool isPenalty = false,
  }) async {
    try {
      final uri = Uri.parse(_formatUrl(hubUrl, '/api/table/$tableNumber/finish'));
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'scoreA': scoreA,
          'scoreB': scoreB,
          'finishType': finishType,
          'isPenalty': isPenalty,
        }),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Flags a dispute to alert the head judge / organizer.
  Future<bool> sendDispute({
    required String hubUrl,
    required int tableNumber,
  }) async {
    try {
      final uri = Uri.parse(_formatUrl(hubUrl, '/api/table/$tableNumber/dispute'));
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Confirms the match outcome to advance the bracket in the Hub.
  Future<bool> sendConfirm({
    required String hubUrl,
    required int tableNumber,
  }) async {
    try {
      final uri = Uri.parse(_formatUrl(hubUrl, '/api/table/$tableNumber/confirm'));
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
