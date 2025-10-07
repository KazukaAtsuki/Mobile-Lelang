import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000/api"; // ganti sesuai hosting kamu

  /// REGISTER USER
  Future<Map<String, dynamic>> register({
    File? avatar,
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    var uri = Uri.parse("$baseUrl/register");

    var request = http.MultipartRequest("POST", uri);
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['password_confirmation'] = passwordConfirmation;

    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath("avatar", avatar.path));
    }

    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      final data = jsonDecode(respStr);

      // simpan token kalau backend kirim
      if (data['auth_token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data['auth_token']);
      }

      return data;
    } else {
      throw Exception("Failed to register: $respStr");
    }
  }

  /// LOGIN USER
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      body: {
        "email": email,
        "password": password,
      },
    );

    final respStr = response.body;

    if (response.statusCode == 200) {
      final data = jsonDecode(respStr);

      // simpan token
      if (data['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data['token']);
      }

      return data;
    } else {
      throw Exception("Login gagal: $respStr");
    }
  }

  /// LOGOUT USER
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  /// AMBIL TOKEN
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// REQUEST DENGAN TOKEN (contoh untuk API lain)
  Future<http.Response> getWithAuth(String endpoint) async {
    final token = await getToken();
    if (token == null) throw Exception("No token found, please login first");

    final url = Uri.parse("$baseUrl/$endpoint");
    return await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );
  }
}
