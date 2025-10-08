import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile_lelang/models/auction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuctionService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  // Ambil daftar barang lelang dengan filter opsional kategori
  Future<List<AuctionItem>> getAuctions({int? kategoriId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("No token found, please login first.");
    }

    final uri = Uri.parse("$baseUrl/lelang-barang").replace(queryParameters: {
      if (kategoriId != null) 'kategori_id': kategoriId.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body['data'] is List) {
        return (body['data'] as List)
            .map((json) => AuctionItem.fromJson(json))
            .toList();
      } else {
        throw Exception("Unexpected response format");
      }
    } else {
      throw Exception("Failed to load auctions: ${response.body}");
    }
  }

  // Ambil daftar kategori untuk filter
  Future<List<Map<String, dynamic>>> getCategories() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final response = await http.get(
    Uri.parse("$baseUrl/categories"),
    headers: {
      if (token != null) HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.acceptHeader: "application/json",
    },
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final List data = body['data'];
    return data
        .map((e) => {
              'id': e['id'],
              'nama_kategori': e['nama_kategori'],
            })
        .toList();
  } else {
    throw Exception("Failed to load categories: ${response.body}");
  }
}

}
