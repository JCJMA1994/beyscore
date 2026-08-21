import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BeysHubPage extends StatelessWidget {
  const BeysHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ARSENAL & COMBOS',
              style: AppTypography.displayMedium.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Administra tus combinaciones de piezas y crea tus Decks 3on3 para torneo.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
            ),
            const SizedBox(height: 24),
            _buildNavCard(
              context: context,
              title: 'MIS COMBOS',
              subtitle: 'Crea y personaliza combinaciones Blade + Ratchet + Bit',
              icon: Icons.tune,
              color: AppColors.x,
              route: '/combos',
            ),
            const SizedBox(height: 12),
            _buildNavCard(
              context: context,
              title: 'DECKS 3ON3',
              subtitle: 'Configura tus 3 Beys para competencia oficial',
              icon: Icons.layers,
              color: AppColors.dragoon,
              route: '/decks',
            ),
            const SizedBox(height: 12),
            _buildNavCard(
              context: context,
              title: 'CATÁLOGO DE PIEZAS',
              subtitle: 'Explora 239 piezas oficiales y sus especificaciones',
              icon: Icons.grid_view,
              color: AppColors.pegasus,
              route: '/catalog',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.mono.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mute,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mute),
          ],
        ),
      ),
    );
  }
}
