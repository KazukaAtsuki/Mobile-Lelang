import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile_lelang/models/auction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuctionService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<List<AuctionItem>> getAuctions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("No token found, please login first.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/lelang-barang"),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => AuctionItem.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load auctions: ${response.body}");
    }
  }

  Future<bool> placebid(int auctionId, int bidAmount) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auctions/$auctionId/bid"),
        body: {'amount': bidAmount.toString()},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error saat place bid: $e");
      return false;
    }
  }

  
}
