import '../../domain/entities/user.dart';


class UserModel extends User {
  const UserModel({
    required super.uuid,
    required super.name,
    required super.email,
    super.phone,
    super.avatarUrl,
    required super.role,
    required super.isGuest,
    required super.emailVerified,
    required super.phoneVerified,
    required super.hasHostProfile,
    super.hostVerificationStatus,
    super.createdAt,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      isGuest: json['is_guest'] as bool? ?? false,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      hasHostProfile: json['has_host_profile'] as bool? ?? false,
      hostVerificationStatus: json['host_verification_status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'is_guest': isGuest,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'has_host_profile': hasHostProfile,
      'host_verification_status': hostVerificationStatus,
      'created_at': createdAt?.toIso8601String(),
    };
  }


  factory UserModel.fromEntity(User user) {
    return UserModel(
      uuid: user.uuid,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      role: user.role,
      isGuest: user.isGuest,
      emailVerified: user.emailVerified,
      phoneVerified: user.phoneVerified,
      hasHostProfile: user.hasHostProfile,
      hostVerificationStatus: user.hostVerificationStatus,
      createdAt: user.createdAt,
    );
  }
}
