class User {
  final int? id;
  final String? email;
  final String? name;
  final String? role;
  final String? token;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? phoneNumber;
  final String? address;
  final String? bio;
  final String? profilePicture;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  final bool? isActive;
  final bool? isVerified;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
    this.firstName,
    this.lastName,
    this.phone,
    this.phoneNumber,
    this.address,
    this.bio,
    this.profilePicture,
    this.dateJoined,
    this.lastLogin,
    this.isActive,
    this.isVerified,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["user_id"] ?? json["id"],
      email: json["email"],
      name: json["name"] ?? json["full_name"],
      role: json["role"],
      token: json["access"] ?? json["token"] ?? json["access_token"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      phone: json["phone"],
      phoneNumber: json["phone_number"],
      address: json["address"],
      bio: json["bio"],
      profilePicture: json["profile_picture"] ?? json["avatar"],
      dateJoined: json["date_joined"] != null ? DateTime.parse(json["date_joined"]) : null,
      lastLogin: json["last_login"] != null ? DateTime.parse(json["last_login"]) : null,
      isActive: json["is_active"],
      isVerified: json["is_verified"] ?? json["email_verified"],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "role": role,
      "token": token,
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "phone_number": phoneNumber,
      "address": address,
      "bio": bio,
      "profile_picture": profilePicture,
      "date_joined": dateJoined?.toIso8601String(),
      "last_login": lastLogin?.toIso8601String(),
      "is_active": isActive,
      "is_verified": isVerified,
    };
  }
}
