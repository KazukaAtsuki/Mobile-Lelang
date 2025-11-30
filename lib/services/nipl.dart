import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_lelang/models/nipl.dart';

class NiplService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  /// 🔹 Cek apakah user sudah punya NIPL
  Future<NiplModel?> checkNipl() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) return null;

  try {
    final response = await http.get(
      Uri.parse("$baseUrl/nipl/checkNipl"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // cek kemungkinan field yang berbeda-beda
      if (data['data'] != null && data['data'] is Map) {
        return NiplModel.fromJson(data['data']);
      } else if (data['nipl'] != null && data['nipl'] is Map) {
        return NiplModel.fromJson(data['nipl']);
      } else if (data['hasNipl'] == true) {
        return NiplModel.fromJson(data['data']);
      } else {
        return null;
      }
    } else if (response.statusCode == 404) {
      return null; // belum punya NIPL
    } else {
      throw Exception("Gagal memeriksa NIPL (${response.statusCode})");
    }
  } catch (e) {
    throw Exception("Gagal memeriksa NIPL: $e");
  }
}


  /// 🔹 Buat NIPL baru (checkout ke Xendit)
  Future<String?> createNipl(String noTelepon) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Token tidak ditemukan");

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/nipl/buy"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "no_telepon": noTelepon,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data['invoice_url']; // URL Xendit checkout
      } else if (response.statusCode == 409) {
        throw Exception(data['message'] ?? "User sudah memiliki NIPL");
      } else {
        throw Exception(data['message'] ?? "Gagal membuat NIPL");
      }
    } catch (e) {
      throw Exception("Gagal membuat NIPL: $e");
    }
  }
}
