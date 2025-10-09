class AuctionItem {
  final int id;
  final String gambarBarang;
  final String namaBarang;
  final int? kategoriId;
  final int? winnerId;
  final String deskripsi;
  final int hargaAwal;
  final int? hargaAkhir;
  final DateTime waktuMulai;
  final DateTime waktuSelesai;
  final String status;
  final String? kategoriNama; // ✅ tambahkan ini untuk menampilkan nama kategori

  AuctionItem({
    required this.id,
    required this.gambarBarang,
    required this.namaBarang,
    this.kategoriId,
    this.winnerId,
    required this.deskripsi,
    required this.hargaAwal,
    this.hargaAkhir,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.status,
    this.kategoriNama, // ✅ tambahkan ke constructor
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    return AuctionItem(
      id: json['id'],
      gambarBarang: json['gambar_barang'],
      namaBarang: json['nama_barang'],
      kategoriId: json['kategori_id'],
      winnerId: json['winner_id'],
      deskripsi: json['deskripsi'],
      hargaAwal: json['harga_awal'],
      hargaAkhir: json['harga_akhir'],
      waktuMulai: DateTime.parse(json['waktu_mulai']),
      waktuSelesai: DateTime.parse(json['waktu_selesai']),
      status: json['status'],
      kategoriNama: json['kategori'] != null
          ? json['kategori']['nama_kategori']
          : null, // ✅ ambil dari nested object jika ada
    );
  }
}
