class UserModel {
  final String uid;           
  final String? email;        
  final bool phoneVerified;
  final String? phoneNumber;   
  final String? token;         

  UserModel({
    required this.uid,
    this.email,
    this.phoneVerified = false,
    this.phoneNumber,
    this.token,
  });

  // Factory constructor to parse from JSON (backend response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
      token: json['token'] as String?,
    );
  }

  // Convert back to JSON (optional, if you need to send user back to backend)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phoneVerified': phoneVerified,
      'phoneNumber': phoneNumber,
      'token': token,
    };
  }
}
