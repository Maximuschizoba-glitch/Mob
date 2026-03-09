

class UpdateProfileRequest {
  final String? name;
  final String? email;
  final String? phone;
  final String? bio;

  const UpdateProfileRequest({
    this.name,
    this.email,
    this.phone,
    this.bio,
  });


  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (bio != null) 'bio': bio,
    };
  }
}
