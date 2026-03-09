import 'package:equatable/equatable.dart';

import '../../../../shared/models/enums.dart';


class HostVerification extends Equatable {
  final HostType? hostType;
  final String businessName;
  final String? bio;
  final VerificationStatus status;
  final VerificationDocumentType? documentType;
  final DateTime? verifiedAt;
  final DateTime? createdAt;

  const HostVerification({
    this.hostType,
    required this.businessName,
    this.bio,
    required this.status,
    this.documentType,
    this.verifiedAt,
    this.createdAt,
  });


  bool get isApproved => status == VerificationStatus.approved;


  bool get isPending => status == VerificationStatus.pending;


  bool get isRejected => status == VerificationStatus.rejected;


  bool get canResubmit => isRejected;

  @override
  List<Object?> get props => [
        hostType,
        businessName,
        bio,
        status,
        documentType,
        verifiedAt,
        createdAt,
      ];
}
