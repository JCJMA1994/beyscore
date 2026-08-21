import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  late IdentityService identityService;

  setUp(() {
    identityService = IdentityService();
  });

  group('IdentityService - Recovery Code & Anonymous Account', () {
    test('generates exactly 12-character raw recovery code', () {
      final code = identityService.generateRawRecoveryCode();
      expect(code.length, 12);
      expect(code, matches(r'^[23456789ABCDEFGHJKLMNPQRSTUVWXYZ]{12}$'));
    });

    test('formats code into XXXX-XXXX-XXXX', () {
      const raw = '23456789ABCD';
      final formatted = identityService.formatRecoveryCode(raw);
      expect(formatted, '2345-6789-ABCD');
    });

    test('normalizes recovery code by removing hyphens and uppercase', () {
      final normalized = identityService.normalizeRecoveryCode('2345-6789-abcd');
      expect(normalized, '23456789ABCD');
    });

    test('hashes code consistently and verifies match', () {
      final code = identityService.generateRawRecoveryCode();
      final hash = identityService.hashRecoveryCode(code);

      expect(identityService.verifyRecoveryCode(code, hash), isTrue);
      expect(identityService.verifyRecoveryCode(identityService.formatRecoveryCode(code), hash), isTrue);
      expect(identityService.verifyRecoveryCode('WRONGCODE123', hash), isFalse);
    });

    test('creates anonymous profile with UUID v7 and recovery code', () {
      final result = identityService.createAnonymousProfile(nickname: 'RYU_07');

      expect(result.profile.nickname, 'RYU_07');
      expect(result.profile.id, isNotEmpty);
      expect(result.profile.deviceId, isNotEmpty);
      expect(result.profile.recoveryCodeHash, isNotEmpty);
      expect(result.formattedRecoveryCode.length, 14); // 12 chars + 2 hyphens
    });
  });
}
