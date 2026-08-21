import 'package:bey_data/bey_data.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/di/injector.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final _identityRepo = getIt<IdentityRepository>();
  final _comboRepo = getIt<ComboRepository>();
  final _catalogRepo = getIt<CatalogRepository>();
  final _battleRepo = getIt<BattleRepository>();
  final _tournamentRepo = getIt<TournamentRepository>();
  final _scoringService = getIt<ScoringService>();

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _identityRepo.getActiveProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerCloudSync() async {
    setState(() => _isSyncing = true);
    await HapticFeedback.lightImpact();
    try {
      await getIt<SyncEngine>().syncNow();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.dragoon,
            content: Row(
              children: [
                const Icon(Icons.cloud_done_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '¡SINCRONIZACIÓN CLOUD COMPLETADA!',
                  style: AppTypography.mono.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.x,
            content: Text(
              'No se pudo sincronizar. Modo offline activo.',
              style: AppTypography.mono.copyWith(color: AppColors.void_, fontSize: 12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showProfileSecurityModal() {
    final nickname = _profile?.nickname ?? 'BLADER';
    final profileId = _profile?.id ?? 'LOCAL';
    final hash = _profile?.recoveryCodeHash ?? 'N/A';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.void_,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'IDENTIDAD Y SEGURIDAD',
                  style: AppTypography.mono.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.x,
                  ),
                ),
                const BeyBadge(label: 'OFFLINE-FIRST', color: AppColors.dragoon),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BLADER: $nickname', style: AppTypography.displayMedium.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('ID CUENTA: $profileId', style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute)),
                  const SizedBox(height: 4),
                  Text('HASH RECUPERACIÓN: ${hash.length > 16 ? "${hash.substring(0, 16)}..." : hash}',
                      style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ChamferButton(
              text: _isSyncing ? 'SINCRONIZANDO...' : 'FORZAR SYNC CON SUPABASE ☁️',
              variant: ChamferButtonVariant.go,
              height: 42,
              onPressed: () {
                Navigator.pop(ctx);
                _triggerCloudSync();
              },
            ),
            const SizedBox(height: 10),
            ChamferButton(
              text: 'CERRAR',
              variant: ChamferButtonVariant.ghost,
              height: 38,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showTournamentPassQrModal() {
    final nickname = _profile?.nickname ?? 'BLADER';
    final qrData = 'beyscore://checkin?nickname=${Uri.encodeComponent(nickname)}&id=${_profile?.id ?? ''}';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.void_,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'PASE DE TORNEO DIGITAL',
              style: AppTypography.mono.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.x,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Muestra este código QR al organizador del torneo para Check-in y asignación de mesa inmediata.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.x.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 190,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              nickname.toUpperCase(),
              style: AppTypography.displayMedium.copyWith(fontSize: 18, color: AppColors.text),
            ),
            Text(
              'ID: ${_profile?.id ?? 'ANONYMOUS'}',
              style: AppTypography.mono.copyWith(fontSize: 9, color: AppColors.mute),
            ),
            const SizedBox(height: 20),
            ChamferButton(
              text: 'CERRAR PASE',
              variant: ChamferButtonVariant.ghost,
              height: 38,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.void_,
        body: Center(child: CircularProgressIndicator(color: AppColors.x)),
      );
    }

    final nickname = _profile?.nickname ?? 'BLADER';

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
                gradient: LinearGradient(
                  colors: [
                    AppColors.panel,
                    AppColors.dragoon.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '¡HOLA, $nickname!',
                          style: AppTypography.displayMedium.copyWith(fontSize: 22),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const BeyBadge(label: 'BLADER OFICIAL', color: AppColors.dragoon),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: 'Seguridad y Sync Cloud',
                            icon: const Icon(Icons.shield_outlined, color: AppColors.text, size: 20),
                            onPressed: _showProfileSecurityModal,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sistema de combate físico offline-first para Beyblade X.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChamferButton(
                          text: 'COMBATE 1V1',
                          variant: ChamferButtonVariant.go,
                          onPressed: () => context.push('/battle'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChamferButton(
                          text: 'TORNEOS',
                          variant: ChamferButtonVariant.ghost,
                          onPressed: () => context.push('/tournaments'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: 'Pase de Torneo QR',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.steel,
                          foregroundColor: AppColors.x,
                        ),
                        icon: const Icon(Icons.qr_code_2_rounded, size: 22),
                        onPressed: _showTournamentPassQrModal,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Hub Navigation Cards (3 Cards)
            Text(
              'MÓDULOS DEL SISTEMA',
              style: AppTypography.mono.copyWith(
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                color: AppColors.mute,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'TORNEOS',
                    subtitle: 'G3 · G2 · G1 · GP',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.pegasus,
                    onTap: () => context.push('/tournaments'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    title: 'DECKS 3ON3',
                    subtitle: 'Regla V12',
                    icon: Icons.layers_rounded,
                    color: AppColors.dragoon,
                    onTap: () => context.push('/decks'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    title: 'CATÁLOGO',
                    subtitle: '239 piezas',
                    icon: Icons.grid_view_rounded,
                    color: AppColors.x,
                    onTap: () => context.push('/catalog'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tournaments Stream Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TORNEOS ACTIVOS',
                  style: AppTypography.mono.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mute,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/tournaments'),
                  child: Text(
                    'VER TODOS',
                    style: AppTypography.mono.copyWith(
                      fontSize: 11,
                      color: AppColors.x,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            StreamBuilder<List<Tournament>>(
              stream: _tournamentRepo.watchAll(),
              builder: (context, snapshot) {
                final tournaments = snapshot.data ?? [];
                if (tournaments.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.mute, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No hay torneos abiertos en este momento.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final t = tournaments.first;
                final isRegistered = _profile != null && t.participants.contains(_profile!.nickname);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isRegistered ? AppColors.x : AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.military_tech_rounded, color: AppColors.pegasus, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name.toUpperCase(),
                              style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${t.tier.label} · ${t.participants.length} participantes · ${t.status.label}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.mute, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      ChamferButton(
                        text: isRegistered ? 'MI PASE' : 'INSCRIBIR',
                        variant: isRegistered ? ChamferButtonVariant.ghost : ChamferButtonVariant.go,
                        onPressed: () {
                          if (isRegistered) {
                            context.push('/tournaments/${t.id}/pass');
                          } else {
                            context.push('/tournaments/${t.id}/register');
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Real-time Combos Stream Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ARSENAL DE COMBOS',
                  style: AppTypography.mono.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mute,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/combos'),
                  child: Text(
                    'VER TODOS',
                    style: AppTypography.mono.copyWith(
                      fontSize: 11,
                      color: AppColors.x,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            StreamBuilder<List<Part>>(
              stream: _catalogRepo.watchByType(PartType.blade),
              builder: (context, bladeSnapshot) {
                final bladesMap = {for (final b in bladeSnapshot.data ?? <Part>[]) b.id: b};

                return StreamBuilder<List<Combo>>(
                  stream: _comboRepo.watchAll(),
                  builder: (context, snapshot) {
                    final combos = snapshot.data ?? [];

                    if (combos.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.tune, color: AppColors.mute, size: 36),
                            const SizedBox(height: 10),
                            const Text(
                              'Aún no tienes combos en tu arsenal',
                              style: TextStyle(color: AppColors.mute, fontSize: 12.5),
                            ),
                            const SizedBox(height: 12),
                            ChamferButton(
                              text: 'Armar mi primer combo',
                              variant: ChamferButtonVariant.ghost,
                              onPressed: () => context.push('/combos/new'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: combos.take(3).map((c) {
                        final bladePart = bladesMap[c.bladeId];

                        final accentColor = switch (bladePart?.beyType) {
                          BeyType.attack => AppColors.dranzer,
                          BeyType.defense => AppColors.dragoon,
                          BeyType.stamina => AppColors.pegasus,
                          BeyType.balance => AppColors.burst,
                          null => AppColors.x,
                        };

                        final typeName = bladePart?.beyType != null
                            ? bladePart!.beyType!.name.toUpperCase()
                            : 'BX COMBO';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.panel,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            children: [
                              PartImage(
                                type: PartType.blade,
                                imageRemote: bladePart?.imageRemote,
                                imageLocal: bladePart?.imageLocal,
                                size: 44,
                                color: accentColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            c.name.toUpperCase(),
                                            style: AppTypography.mono.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (c.calculatedWeight != null || bladePart?.weightG != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.panel2,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppColors.line),
                                            ),
                                            child: Text(
                                              '${(c.calculatedWeight ?? bladePart?.weightG)?.toStringAsFixed(1)}g',
                                              style: AppTypography.mono.copyWith(
                                                fontSize: 10.5,
                                                color: AppColors.x,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${c.bladeId.replaceAll('blade-', '')} · ${c.ratchetId.replaceAll('ratchet-', '')} · ${c.bitId.replaceAll('bit-', '')}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.mute,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        BeyBadge(
                                          label: typeName,
                                          color: accentColor,
                                        ),
                                        if (bladePart?.metaTier != null) ...[
                                          const SizedBox(width: 6),
                                          BeyBadge(
                                            label: 'T${bladePart!.metaTier}',
                                            color: AppColors.dragoon,
                                          ),
                                        ],
                                        if (bladePart?.attack != null || bladePart?.defense != null || bladePart?.stamina != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            'ATK ${bladePart?.attack ?? "-"} / DEF ${bladePart?.defense ?? "-"} / STA ${bladePart?.stamina ?? "-"}',
                                            style: AppTypography.mono.copyWith(
                                              fontSize: 9.5,
                                              color: AppColors.mute,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Live Match History Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HISTORIAL RECIENTE',
                  style: AppTypography.mono.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mute,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/stats'),
                  child: Text(
                    'ESTADÍSTICAS',
                    style: AppTypography.mono.copyWith(
                      fontSize: 11,
                      color: AppColors.pegasus,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            StreamBuilder<List<Match>>(
              stream: _battleRepo.watchAllMatches(),
              builder: (context, snapshot) {
                final matches = snapshot.data ?? [];

                if (matches.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Center(
                      child: Text(
                        'Sin batallas registradas. ¡Inicia un combate 1v1!',
                        style: TextStyle(color: AppColors.mute, fontSize: 12.5),
                      ),
                    ),
                  );
                }

                final recent = matches.take(3);
                return Column(
                  children: recent.map((m) {
                    final score = _scoringService.scoreOf(m);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on_rounded, color: AppColors.dragoon, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${m.playerAId} vs ${m.playerBId}',
                              style: AppTypography.mono.copyWith(fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                          ),
                          Text(
                            '${score.playerAPoints} — ${score.playerBPoints}',
                            style: AppTypography.mono.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.x,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.mono.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 9.5,
                color: AppColors.mute,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
