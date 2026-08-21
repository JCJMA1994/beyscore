import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final identityRepo = getIt<IdentityRepository>();
    final profile = await identityRepo.getActiveProfile();

    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
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
    final id = _profile?.id ?? 'ID-ANON';

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERFIL DEL BLADER',
              style: AppTypography.displayMedium.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.dragoon.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: AppColors.dragoon, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nickname.toUpperCase(),
                          style: AppTypography.displayMedium.copyWith(fontSize: 20),
                        ),
                        Text(
                          'ID: $id',
                          style: AppTypography.mono.copyWith(fontSize: 10, color: AppColors.mute),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'OPCIONES DE CUENTA',
              style: AppTypography.mono.copyWith(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: AppColors.mute),
            ),
            const SizedBox(height: 12),
            _optionTile(
              icon: Icons.sync,
              title: 'Estado de Sincronización',
              subtitle: 'Outbox local activo · Modo Offline-first',
              color: AppColors.x,
            ),
            const SizedBox(height: 10),
            _optionTile(
              icon: Icons.key,
              title: 'Código de Recuperación',
              subtitle: 'Respaldo para transferir tu cuenta',
              color: AppColors.pegasus,
            ),
            const SizedBox(height: 24),
            ChamferButton(
              text: 'CERRAR SESIÓN / CAMBIAR BLADER',
              variant: ChamferButtonVariant.danger,
              onPressed: () => context.go('/onboarding'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.mono.copyWith(fontSize: 12.5, fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.mute)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
