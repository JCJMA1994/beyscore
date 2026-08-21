/// An entry in the outbox queue.
///
/// Every mutation that needs server sync goes through here.
/// The UI never waits for this: it already reacted via the local Drift write.
enum OutboxStatus { pending, synced, failed }

class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.operation,
    required this.tableName,
    required this.entityId,
    required this.payload,
    required this.status,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final String operation; // CREATE, UPDATE, DELETE
  final String tableName;
  final String entityId;
  final Map<String, dynamic> payload;
  final OutboxStatus status;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  OutboxEntry copyWith({
    OutboxStatus? status,
    int? attempts,
    String? lastError,
  }) {
    return OutboxEntry(
      id: id,
      operation: operation,
      tableName: tableName,
      entityId: entityId,
      payload: payload,
      status: status ?? this.status,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }
}
