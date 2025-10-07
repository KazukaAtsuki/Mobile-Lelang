class User {
  final int id;
  final String? avatar;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    this.avatar,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}
