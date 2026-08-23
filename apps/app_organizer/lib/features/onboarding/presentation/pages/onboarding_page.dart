import 'dart:async';
import 'package:bey_data/bey_data.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:bey_ui/bey_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _nicknameController = TextEditingController();
  final _recoveryCodeController = TextEditingController();

  bool _isImporting = false;
  String? _generatedRecoveryCode;
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _recoveryCodeController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;

    setState(() => _isLoading = true);

    final identityRepo = getIt<IdentityRepository>();
    final result = await identityRepo.createProfile(nickname);
    unawaited(getIt<SyncEngine>().syncNow());

    if (!mounted) return;

    setState(() {
      _generatedRecoveryCode = result.formattedRecoveryCode;
      _isLoading = false;
    });
  }

  Future<void> _importAccount() async {
    final code = _recoveryCodeController.text.trim();
    final nickname = _nicknameController.text.trim();
    if (code.isEmpty || nickname.isEmpty) return;

    setState(() => _isLoading = true);

    final identityRepo = getIt<IdentityRepository>();
    final success = await identityRepo.restoreWithRecoveryCode(code, nickname: nickname);

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      setState(() => _isLoading = false);
      await BeyFeedbackDialog.showError(
        context,
        title: 'Recuperación Fallida',
        message: 'El código de recuperación ingresado no coincide con ninguna cuenta registrada o está mal escrito.',
        solution: 'Verifica los 12 caracteres (formato XXXX-XXXX-XXXX) e intenta nuevamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _generatedRecoveryCode != null
                  ? _buildSuccessCodeView()
                  : (_isImporting ? _buildImportView() : _buildCreateView()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.panel,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.x),
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.x, size: 40),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'BIENVENIDO A BEYSCORE',
          textAlign: TextAlign.center,
          style: AppTypography.displayMedium.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu marcador de combates físico offline-first.\nCrea tu identidad de Blader para comenzar.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(
            labelText: 'Apodo de Blader',
            hintText: 'Ej. Tyson_X',
            prefixIcon: Icon(Icons.person, color: AppColors.x),
            border: OutlineInputBorder(),
          ),
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 20),
        ChamferButton(
          text: 'CREAR CUENTA BLADER',
          variant: ChamferButtonVariant.go,
          isLoading: _isLoading,
          onPressed: _createAccount,
        ),
        const SizedBox(height: 14),
        ChamferButton(
          text: 'Ya tengo código de recuperación',
          variant: ChamferButtonVariant.ghost,
          onPressed: () => setState(() => _isImporting = true),
        ),
      ],
    );
  }

  Widget _buildImportView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'RECUPERAR CUENTA',
          textAlign: TextAlign.center,
          style: AppTypography.displayMedium.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu apodo y código de 12 caracteres (XXXX-XXXX-XXXX)',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(
            labelText: 'Apodo de Blader',
            hintText: 'Ej. Tyson_X',
            prefixIcon: Icon(Icons.person, color: AppColors.x),
            border: OutlineInputBorder(),
          ),
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _recoveryCodeController,
          decoration: const InputDecoration(
            labelText: 'Código de Recuperación',
            hintText: 'ABCD-EFGH-JKLM',
            prefixIcon: Icon(Icons.key, color: AppColors.x),
            border: OutlineInputBorder(),
          ),
          style: AppTypography.mono.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ChamferButton(
          text: 'RESTAURAR CUENTA',
          variant: ChamferButtonVariant.go,
          isLoading: _isLoading,
          onPressed: _importAccount,
        ),
        const SizedBox(height: 12),
        ChamferButton(
          text: 'Volver a Crear Cuenta',
          variant: ChamferButtonVariant.ghost,
          onPressed: () => setState(() => _isImporting = false),
        ),
      ],
    );
  }

  Widget _buildSuccessCodeView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.x, size: 54),
        const SizedBox(height: 16),
        Text(
          '¡CUENTA CREADA!',
          textAlign: TextAlign.center,
          style: AppTypography.displayMedium.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 12),
        const Text(
          'GUARDA ESTE CÓDIGO. Es tu única forma de recuperar tu cuenta si cambias de dispositivo:',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.pegasus, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.panel,
            border: Border.all(color: AppColors.x, width: 1.5),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.x.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _generatedRecoveryCode ?? '',
                textAlign: TextAlign.center,
                style: AppTypography.mono.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: AppColors.x,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  final code = _generatedRecoveryCode;
                  if (code != null && code.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: code));
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.x,
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.void_),
                            const SizedBox(width: 8),
                            Text(
                              '¡CÓDIGO COPIADO AL PORTAPAPELES!',
                              style: AppTypography.mono.copyWith(
                                color: AppColors.void_,
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
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.steel,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy, size: 14, color: AppColors.x),
                      const SizedBox(width: 6),
                      Text(
                        'TOCAR PARA COPIAR CÓDIGO',
                        style: AppTypography.mono.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ChamferButton(
          text: 'ENTRAR AL SISTEMA',
          variant: ChamferButtonVariant.go,
          onPressed: () => context.go('/home'),
        ),
      ],
    );
  }
}
