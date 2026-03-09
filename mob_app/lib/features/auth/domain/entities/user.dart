import 'package:equatable/equatable.dart';


class User extends Equatable {
  final String uuid;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final bool isGuest;
  final bool emailVerified;
  final bool phoneVerified;
  final bool hasHostProfile;
  final String? hostVerificationStatus;
  final DateTime? createdAt;

  const User({
    required this.uuid,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.isGuest,
    required this.emailVerified,
    required this.phoneVerified,
    required this.hasHostProfile,
    this.hostVerificationStatus,
    this.createdAt,
  });


  bool get isHostVerified => hostVerificationStatus == 'approved';


  bool get isHost => role == 'host';


  bool get isAdmin => role == 'admin';


  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [
        uuid,
        name,
        email,
        phone,
        avatarUrl,
        role,
        isGuest,
        emailVerified,
        phoneVerified,
        hasHostProfile,
        hostVerificationStatus,
        createdAt,
      ];
}
