class Player {
  const Player({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final DateTime? createdAt;
}
