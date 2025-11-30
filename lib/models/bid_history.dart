import 'package:intl/intl.dart';

class BidHistory {
  final int id;
  final int harga;        // Sesuai dengan $table->integer('harga');
  final String userName;  // Diambil dari relasi user (Controller backend harus ->with('user'))
  final String createdAt; // Sesuai dengan $table->timestamps();

  BidHistory({
    required this.id,
    required this.harga,
    required this.userName,
    required this.createdAt,
  });

  factory BidHistory.fromJson(Map<String, dynamic> json) {
    return BidHistory(
      id: json['id'],
      // Pastikan harga diambil sebagai int. Backend Laravel kadang mengirimnya sebagai string/int
      harga: int.parse(json['harga'].toString()), 
      
      // Mengambil nama dari relasi 'user'. Jika null, tampilkan 'User'
      userName: json['user'] != null ? json['user']['name'] : 'User', 
      
      // Ambil waktu dari created_at
      createdAt: json['created_at'],
    );
  }

  // Helper untuk memformat tanggal agar enak dibaca (Contoh: 29 Nov 2025, 18:30)
  String get formattedDate {
    try {
      final DateTime date = DateTime.parse(createdAt).toLocal(); // Convert ke waktu lokal HP
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return createdAt;
    }
  }

  // Helper untuk memformat Rupiah
  String get formattedHarga {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(harga);
  }
}