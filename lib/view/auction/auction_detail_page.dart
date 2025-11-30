import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_lelang/models/auction.dart';
// import 'package:mobile_lelang/models/nipl.dart';
import 'package:mobile_lelang/services/nipl.dart';
import 'package:mobile_lelang/view/nipl/nipl.dart';
import 'package:mobile_lelang/view/auction/place_bid.dart';

class AuctionDetailPage extends StatefulWidget {
  final AuctionItem item;

  const AuctionDetailPage({super.key, required this.item});

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  bool _loading = true;
  bool _hasNipl = false;

  @override
  void initState() {
    super.initState();
    _checkNipl();
  }

  Future<void> _checkNipl() async {
    final niplService = NiplService();
    final nipl = await niplService.checkNipl();
    setState(() {
      _hasNipl = nipl != null;
      _loading = false;
    });
  }

  String formatRupiah(int value) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(value);
  }

  void _showNiplDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("NIPL Belum Dibuat"),
        content: const Text(
          "Anda harus membuat NIPL terlebih dahulu sebelum bisa mengikuti lelang.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 19, 19, 54),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NiplPage(),
                ),
              );
            },
            child: const Text(
              "Buat NIPL",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bool aktif = item.status == "aktif";
    const primaryColor = Color(0xFF4A47D5);
    const backgroundColor = Color(0xFFF4F5FB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Detail Lelang",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar utama
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24)),
                    child: Image.network(
                      "http://127.0.0.1:8000/storage/${item.gambarBarang}",
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card Detail Barang
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaBarang,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Harga awal
                            Row(
                              children: [
                                const Icon(Icons.monetization_on,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  "Harga Awal: ${formatRupiah(item.hargaAwal)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Harga akhir (jika ada)
                            if (item.hargaAkhir != null)
                              Row(
                                children: [
                                  const Icon(Icons.trending_up,
                                      color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Tawaran Tertinggi: ${formatRupiah(item.hargaAkhir!)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),

                            // Status
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color:
                                        aktif ? Colors.green : Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  aktif ? "Status: Aktif" : "Status: Selesai",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        aktif ? Colors.green : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Kategori
                            if (item.kategoriNama != null)
                              Row(
                                children: [
                                  const Icon(Icons.category,
                                      color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Kategori: ${item.kategoriNama}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 14),

                            // Deskripsi
                            const Text(
                              "Deskripsi Barang",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.deskripsi,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

      // Tombol Ikut Lelang
      bottomNavigationBar: !_loading
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.gavel, color: Colors.white),
                  label: Text(
                    aktif
                        ? (_hasNipl
                            ? "Ikut Lelang"
                            : "Silahkan Buat NIPL terlebih dahulu")
                        : "Lelang Selesai",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: aktif
                        ? (_hasNipl ? primaryColor : Colors.grey)
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                 // Di dalam build method AuctionDetailPage
onPressed: !aktif
    ? () {
        // ... kode snackbar lelang selesai ...
      }
    : _hasNipl
        ? () async {
            // NAVIGASI KE HALAMAN TAWAR
            final bool? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceBidPage(item: item),
              ),
            );

            // Jika result true (berhasil ngebid), refresh halaman detail ini
            // Agar harga tertinggi terupdate otomatis
            if (result == true) {
               setState(() {
                 _loading = true; 
               });
               // Disini kamu harus memanggil fungsi untuk reload data AuctionItem dari API
               // Contoh: _fetchAuctionDetail(); 
               // Karena di kode awalmu item dipass via constructor, 
               // idealnya page detail punya fungsi fetch ulang by ID.
            }
          }
        : _showNiplDialog,
                ),
              ),
            )
          : null,
    );
  }
}
