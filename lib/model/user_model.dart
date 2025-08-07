class User {
  final int? id;
  final String? email;
  final String? name;
  final String? role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      email: json["email"],
      name: json["name"],
      role: json["role"],
    );
  }
  Map<String, dynamic> toJson() {
    return {"id": id, "email": email, "name": name, "role": role};
  }
}
