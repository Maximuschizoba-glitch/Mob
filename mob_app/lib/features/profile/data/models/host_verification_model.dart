import '../../../../shared/models/enums.dart';
import '../../domain/entities/host_verification.dart';


class HostVerificationModel extends HostVerification {
  const HostVerificationModel({
    super.hostType,
    required super.businessName,
    super.bio,
    required super.status,
    super.documentType,
    super.verifiedAt,
    super.createdAt,
  });


  factory HostVerificationModel.fromJson(Map<String, dynamic> json) {
    return HostVerificationModel(
      hostType: HostType.fromString(json['host_type'] as String?),
      businessName: json['business_name'] as String? ?? '',
      bio: json['bio'] as String?,
      status: VerificationStatus.fromString(
            json['verification_status'] as String?,
          ) ??
          VerificationStatus.pending,
      documentType: VerificationDocumentType.fromString(
        json['verification_document_type'] as String?,
      ),
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'host_type': hostType?.value,
      'business_name': businessName,
      'bio': bio,
      'verification_status': status.value,
      'verification_document_type': documentType?.value,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }


  factory HostVerificationModel.fromEntity(HostVerification entity) {
    return HostVerificationModel(
      hostType: entity.hostType,
      businessName: entity.businessName,
      bio: entity.bio,
      status: entity.status,
      documentType: entity.documentType,
      verifiedAt: entity.verifiedAt,
      createdAt: entity.createdAt,
    );
  }
}
