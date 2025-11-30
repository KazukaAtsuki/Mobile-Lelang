import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_lelang/models/auction.dart';
import 'package:mobile_lelang/services/auction.dart';
import 'package:mobile_lelang/view/auction/auction_detail_page.dart';
import 'package:mobile_lelang/services/auth.dart';
import 'package:mobile_lelang/view/login_page.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({super.key});

  @override
  State<AuctionListPage> createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  final AuctionService _auctionService = AuctionService();
  late Future<List<AuctionItem>> _auctions;
  bool _isLocaleInitialized = false;

  String _searchQuery = "";
  int? _selectedCategoryId;

  final List<Map<String, dynamic>> _iconCategories = [
    {"id": null, "nama": "Semua", "icon": Icons.apps},
    {"id": 1, "nama": "Rumah", "icon": Icons.house_rounded},
    {"id": 2, "nama": "Kendaraan", "icon": Icons.directions_car_rounded},
    {"id": 3, "nama": "Barang Antik", "icon": Icons.account_balance_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _auctions = _auctionService.getAuctions();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    setState(() => _isLocaleInitialized = true);
  }

  String formatRupiah(int value) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(value);
  }

  void _onCategorySelected(int? id) {
    setState(() {
      // klik kategori yg sama = reset
      _selectedCategoryId = _selectedCategoryId == id ? null : id;
      _auctions = _auctionService.getAuctions(kategoriId: _selectedCategoryId);
    });
  }

  List<AuctionItem> _filterAuctions(List<AuctionItem> items) {
    return items
        .where((item) =>
            item.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _refreshAuctions() async {
    setState(() {
      _auctions = _auctionService.getAuctions(kategoriId: _selectedCategoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Row(
                      children: const [
                        Icon(Icons.gavel_rounded,
                            color: Colors.black, size: 30),
                        SizedBox(width: 8),
                        Text(
                          "Lelangin",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.black),
                          onPressed: _refreshAuctions,
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.black),
                          onPressed: () async {
                            final auth = AuthService();
                            await auth.logout();
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                              );
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Cari barang lelang...",
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1.3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: Colors.indigo, width: 1.6),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: _iconCategories.map((category) {
                    final bool isSelected =
                        _selectedCategoryId == category["id"];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => _onCategorySelected(category["id"]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color.fromARGB(255, 19, 19, 54)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black,
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                category["icon"],
                                color:
                                    isSelected ? Colors.white : Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                category["nama"],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // 📜 Daftar lelang
              Expanded(
                child: FutureBuilder<List<AuctionItem>>(
                  future: _auctions,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.black));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Terjadi kesalahan:\n${snapshot.error}",
                          style: const TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final items = _filterAuctions(snapshot.data ?? []);
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          "Tidak ada barang lelang ditemukan",
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshAuctions,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final aktif = item.status == "aktif";

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AuctionDetailPage(item: item),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        "http://127.0.0.1:8000/storage/${item.gambarBarang}",
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.namaBarang,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: aktif
                                                      ? Colors.green
                                                      : Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  aktif ? "AKTIF" : "SELESAI",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Harga awal: ${formatRupiah(item.hargaAwal)}",
                                            style: const TextStyle(
                                                color: Colors.black87),
                                          ),
                                          if (item.hargaAkhir != null)
                                            Text(
                                              "Harga tertinggi: ${formatRupiah(item.hargaAkhir!)}",
                                              style: const TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Kategori: ${item.kategoriNama ?? "Lainnya"}",
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12),
                                          ),
                                          const SizedBox(height: 6),
                                          aktif
                                              ? Text(
                                                  "Berakhir: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(item.waktuSelesai)}",
                                                  style: const TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              : const Text(
                                                  "Lelang telah selesai",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}