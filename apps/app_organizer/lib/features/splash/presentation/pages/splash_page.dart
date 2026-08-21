import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  String _statusText = 'INICIALIZANDO SISTEMA...';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
    _checkInitialState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialState() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _statusText = 'VERIFICANDO PERFIL ORGANIZADOR...';
      });
    }

    final identityRepo = getIt<IdentityRepository>();
    final profile = await identityRepo.getActiveProfile();

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    if (profile == null) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        children: [
          // Background ambient gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.8,
                  colors: [
                    Color(0x282B6BFF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rotating Bey Ring with Logo inside
                  BeyRing(
                    size: 140,
                    color: AppColors.x,
                    duration: const Duration(seconds: 8),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.x.withValues(alpha: 0.35),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const ColoredBox(
                              color: AppColors.panel,
                              child: Icon(
                                Icons.flash_on_rounded,
                                color: AppColors.x,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Styled Brand Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'BEY',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 38,
                          letterSpacing: 2,
                          color: AppColors.x,
                          shadows: [
                            Shadow(
                              color: AppColors.x.withValues(alpha: 0.6),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'SCORE',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 38,
                          letterSpacing: 2,
                          color: AppColors.pegasus,
                          shadows: [
                            Shadow(
                              color: AppColors.dranzer.withValues(alpha: 0.6),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ORGANIZER & TOURNAMENT HUB',
                    style: AppTypography.mono.copyWith(
                      fontSize: 10.5,
                      color: AppColors.mute,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.x,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _statusText,
                    style: AppTypography.mono.copyWith(
                      fontSize: 9.5,
                      color: AppColors.mute,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
