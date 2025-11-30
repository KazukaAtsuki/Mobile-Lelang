import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_lelang/models/user.dart';

class UserService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<User?> getCurrentUser(String token) async {
    final url = Uri.parse("$baseUrl/user");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("===== FETCH USER =====");
    print("URL: $url");
    print("TOKEN: $token");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    print("======================");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return User.fromJson(json["data"] ?? json);
    } else {
      print("Error fetch user: ${response.body}");
      return null;
    }
  }
}
