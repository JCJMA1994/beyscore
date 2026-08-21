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
}
