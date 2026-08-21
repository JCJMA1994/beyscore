import 'package:equatable/equatable.dart';

/// User identity profile for anonymous account model.
///
/// Follows SISTEMA.md:
/// - Anonymous account with UUID v7 `userId` and `deviceId`.
/// - 12-character recovery code stored as SHA-256 hash.
/// - No email/password required.
/// - Supports guest linking via `mergedInto` and `createdBy`.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.deviceId,
    required this.nickname,
    required this.recoveryCodeHash,
    required this.createdAt,
    this.isGuest = false,
    this.createdBy,
    this.mergedInto,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      nickname: json['nickname'] as String,
      recoveryCodeHash: json['recovery_code_hash'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isGuest: json['is_guest'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      mergedInto: json['merged_into'] as String?,
    );
  }

  final String id;
  final String deviceId;
  final String nickname;
  final String recoveryCodeHash;
  final DateTime createdAt;
  final bool isGuest;
  final String? createdBy;
  final String? mergedInto;

  UserProfile copyWith({
    String? id,
    String? deviceId,
    String? nickname,
    String? recoveryCodeHash,
    DateTime? createdAt,
    bool? isGuest,
    String? createdBy,
    String? mergedInto,
  }) {
    return UserProfile(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      nickname: nickname ?? this.nickname,
      recoveryCodeHash: recoveryCodeHash ?? this.recoveryCodeHash,
      createdAt: createdAt ?? this.createdAt,
      isGuest: isGuest ?? this.isGuest,
      createdBy: createdBy ?? this.createdBy,
      mergedInto: mergedInto ?? this.mergedInto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'nickname': nickname,
      'recovery_code_hash': recoveryCodeHash,
      'created_at': createdAt.toIso8601String(),
      'is_guest': isGuest,
      'created_by': createdBy,
      'merged_into': mergedInto,
    };
  }

  @override
  List<Object?> get props => [
        id,
        deviceId,
        nickname,
        recoveryCodeHash,
        createdAt,
        isGuest,
        createdBy,
        mergedInto,
      ];
}
