import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../id/uuid_v7_generator.dart';
import 'user_profile.dart';

/// Identity and Recovery Code service.
///
/// Follows SISTEMA.md:
/// - 12-character recovery codes (60 bits of entropy).
/// - Unambiguous alphanumeric alphabet (excludes 0, 1, I, O).
/// - Only the SHA-256 hash is persisted.
/// - Client-side UUID v7 identity generation.
class IdentityService {
  IdentityService({
    UuidV7Generator? uuidGenerator,
    Random? random,
  })  : _uuidGenerator = uuidGenerator ?? const UuidV7Generator(),
        _random = random ?? Random.secure();

  final UuidV7Generator _uuidGenerator;
  final Random _random;

  /// Unambiguous 32-character alphabet (5 bits/char => 12 chars = 60 bits).
  static const _alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

  /// Generates a raw 12-character recovery code.
  String generateRawRecoveryCode() {
    final buffer = StringBuffer();
    for (var i = 0; i < 12; i++) {
      buffer.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }

  /// Formats a 12-character code as `XXXX-XXXX-XXXX` for readability.
  String formatRecoveryCode(String rawCode) {
    final clean = rawCode.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
    if (clean.length != 12) return rawCode;
    return '${clean.substring(0, 4)}-${clean.substring(4, 8)}-${clean.substring(8, 12)}';
  }

  /// Normalizes a recovery code (removes dashes/spaces, uppercase).
  String normalizeRecoveryCode(String input) {
    return input.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
  }

  /// Computes the SHA-256 hash of a normalized recovery code.
  String hashRecoveryCode(String rawOrFormattedCode) {
    final normalized = normalizeRecoveryCode(rawOrFormattedCode);
    final bytes = utf8.encode(normalized);
    return sha256.convert(bytes).toString();
  }

  /// Validates whether an input code matches a stored hash.
  bool verifyRecoveryCode(String inputCode, String storedHash) {
    final inputHash = hashRecoveryCode(inputCode);
    return inputHash == storedHash;
  }

  /// Creates a new anonymous user profile with fresh IDs and recovery code.
  ({UserProfile profile, String formattedRecoveryCode}) createAnonymousProfile({
    required String nickname,
    String? existingDeviceId,
  }) {
    final rawCode = generateRawRecoveryCode();
    final hash = hashRecoveryCode(rawCode);
    final userId = _uuidGenerator.generate();
    final deviceId = existingDeviceId ?? _uuidGenerator.generate();

    final profile = UserProfile(
      id: userId,
      deviceId: deviceId,
      nickname: nickname.trim(),
      recoveryCodeHash: hash,
      createdAt: DateTime.now().toUtc(),
      isGuest: false,
    );

    return (
      profile: profile,
      formattedRecoveryCode: formatRecoveryCode(rawCode),
    );
  }
}
