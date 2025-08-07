class User {
  final int? id;
  final String? email;
  final String? name;
  final String? role;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["user_id"],
      email: json["email"],
      name: json["name"],
      role: json["role"],
      token: json["access"] ?? json["token"] ?? json["access_token"],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "role": role,
      "token": token,
    };
  }
}
