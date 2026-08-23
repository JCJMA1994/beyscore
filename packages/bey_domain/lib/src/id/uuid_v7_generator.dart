import 'package:uuid/uuid.dart';

/// Generates UUID v7 (time-ordered) for client-side ID generation.
///
/// UUID v7 is critical for the outbox pattern: IDs are generated on the
/// client so writes never wait for the server, and the time-ordering
/// makes them naturally sortable.
class UuidV7Generator {
  const UuidV7Generator();

  static const _uuid = Uuid();

  String generate() => _uuid.v7();

  /// Generates a time-ordered UUID v7.
  static String v7() => _uuid.v7();

  /// Ensures that any ID string is a valid UUID for PostgreSQL/Supabase.
  /// If it is already a valid UUID, returns it unchanged; otherwise converts it
  /// deterministically via UUID v5.
  static String ensureValidUuid(String rawId) {
    if (Uuid.isValidUUID(fromString: rawId)) {
      return rawId;
    }
    return _uuid.v5(Namespace.url.value, 'beyscore://$rawId');
  }
}
