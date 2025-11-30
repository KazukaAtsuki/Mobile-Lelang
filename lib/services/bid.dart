import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BidService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<Map<String, dynamic>> placeBid(int lelangId, int harga) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/harga-bid');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'lelang_id': lelangId,
          'harga': harga,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Tawaran berhasil dikirim',
          'data': responseBody['data']
        };
      } else {
        // Handle error dari Laravel (misal: harga kurang tinggi, nipl belum ada, dll)
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Gagal melakukan penawaran',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: $e',
      };
    }
  }

  // ---------------------------------------------------------
  // 2. Ambil Data User yang sedang login
  // ---------------------------------------------------------
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final url = Uri.parse('$baseUrl/user'); 
    
    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error get user: $e");
    }
    return null;
  }

  // ---------------------------------------------------------
  // 3. Ambil Semua Data Bid (Raw Data)
  // ---------------------------------------------------------
  Future<List<dynamic>> getAllBidsRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/harga-bid');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      }
    } catch (e) {
      print("Error fetch bids: $e");
    }
    return [];
  }
}