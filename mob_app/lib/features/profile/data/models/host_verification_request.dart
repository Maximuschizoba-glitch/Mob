

class HostVerificationRequest {
  final String businessName;
  final String? bio;
  final String documentType;
  final String documentUrl;
  final String? hostType;

  const HostVerificationRequest({
    required this.businessName,
    this.bio,
    required this.documentType,
    required this.documentUrl,
    this.hostType,
  });


  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      if (bio != null) 'bio': bio,
      'document_type': documentType,
      'document_url': documentUrl,
      if (hostType != null) 'host_type': hostType,
    };
  }
}
