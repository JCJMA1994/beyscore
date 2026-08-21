import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// PhoneShell — vertical shell for mobile player app.
///
/// 4 main navigation tabs:
/// 0: Inicio (/home)
/// 1: Beys & Decks (/beys)
/// 2: Estadísticas (/stats)
/// 3: Perfil (/profile)
class PhoneShell extends StatelessWidget {
  const PhoneShell({
    super.key,
    required this.child,
  });

  final Widget child;

  static const _routes = [
    '/home',
    '/beys',
    '/stats',
    '/profile',
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) {
        return i;
      }
    }
    if (location.startsWith('/catalog') ||
        location.startsWith('/combos') ||
        location.startsWith('/decks')) {
      return 1; // Beys tab
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: AppColors.steel,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'BEYSCORE PLAYER',
              style: AppTypography.displaySmall.copyWith(
                fontSize: 16,
                letterSpacing: 1.2,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppColors.dragoon, AppColors.x],
                  ).createShader(const Rect.fromLTWH(0, 0, 180, 20)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                'BLADER',
                style: AppTypography.mono.copyWith(
                  fontSize: 9,
                  color: AppColors.x,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: SyncStatusIndicator(
              isOnline: true,
              isSyncing: false,
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.void_,
          border: Border(
            top: BorderSide(color: AppColors.line),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _onItemTapped(index, context),
            indicatorColor: AppColors.x.withValues(alpha: 0.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.mute),
                selectedIcon: Icon(Icons.home, color: AppColors.x),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined, color: AppColors.mute),
                selectedIcon: Icon(Icons.tune, color: AppColors.dragoon),
                label: 'Combos',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined, color: AppColors.mute),
                selectedIcon: Icon(Icons.bar_chart, color: AppColors.pegasus),
                label: 'Estadísticas',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: AppColors.mute),
                selectedIcon: Icon(Icons.person, color: AppColors.x),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
