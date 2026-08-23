import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('UuidV7Generator Tests', () {
    const generator = UuidV7Generator();

    test('generates valid UUID string', () {
      final id = generator.generate();
      expect(id, isNotEmpty);
      expect(Uuid.isValidUUID(fromString: id), isTrue);
    });

    test('ensureValidUuid preserves valid UUIDs', () {
      final validUuid = generator.generate();
      expect(UuidV7Generator.ensureValidUuid(validUuid), validUuid);
    });

    test('ensureValidUuid converts legacy prefix strings into deterministic valid UUIDs', () {
      const legacyComboId = 'combo-1787457420366';
      const legacyDeckId = 'deck-1787457436472';

      final uuid1 = UuidV7Generator.ensureValidUuid(legacyComboId);
      final uuid2 = UuidV7Generator.ensureValidUuid(legacyDeckId);

      expect(Uuid.isValidUUID(fromString: uuid1), isTrue);
      expect(Uuid.isValidUUID(fromString: uuid2), isTrue);

      // Determinism test
      expect(UuidV7Generator.ensureValidUuid(legacyComboId), uuid1);
    });
  });
}
