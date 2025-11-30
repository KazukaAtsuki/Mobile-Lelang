class NiplModel {
  final int id;
  final String email;
  final int noNipl;
  final int userId;
  final String noTelepon;
  final DateTime createdAt;

  NiplModel({
    required this.id,
    required this.email,
    required this.noNipl,
    required this.userId,
    required this.noTelepon,
    required this.createdAt,
  });

  factory NiplModel.fromJson(Map<String, dynamic> json) {
    return NiplModel(
      id: json['id'],
      email: json['email'],
      noNipl: json['no_nipl'],
      userId: json['user_id'],
      noTelepon: json['no_telepon'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
