import 'package:flutter/material.dart';
import 'package:mobile_lelang/models/auction.dart';
import 'package:mobile_lelang/services/auction.dart';
import 'package:mobile_lelang/services/auth.dart';
import 'package:mobile_lelang/view/login_page.dart';
import 'package:mobile_lelang/view/auction/auction_detail_page.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({super.key});

  @override
  State<AuctionListPage> createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  final AuctionService _auctionService = AuctionService();
  late Future<List<AuctionItem>> _auctions;

  String _searchQuery = "";
  String _selectedCategory = "Semua";

  final List<String> _categories = [
    "Semua",
    "Kendaraan",
    "Elektronik",
    "Perabotan",
    "Lainnya",
  ];

  @override
  void initState() {
    super.initState();
    _auctions = _auctionService.getAuctions();
  }

  Future<void> _refreshAuctions() async {
    setState(() {
      _auctions = _auctionService.getAuctions();
    });
  }

  List<AuctionItem> _filterAuctions(List<AuctionItem> items) {
    return items.where((item) {
      final matchSearch = item.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == "Semua" ||
          item.kategori?.toLowerCase() == _selectedCategory.toLowerCase();
      return matchSearch && matchCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🌈 Background gradient lembut
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✨ Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "🌀 Lelangin",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                          onPressed: _refreshAuctions,
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                          onPressed: () async {
                            final authService = AuthService();
                            await authService.logout();
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🔍 Search bar + filter kategori
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    // Search Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Cari barang lelang...",
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Category Filter Chips
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white.withOpacity(0.4),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 📦 Daftar barang lelang
              Expanded(
                child: FutureBuilder<List<AuctionItem>>(
                  future: _auctions,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Terjadi kesalahan:\n${snapshot.error}",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final items = _filterAuctions(snapshot.data ?? []);

                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          "Tidak ditemukan barang lelang 😔",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshAuctions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🖼️ Gambar Barang
                                  Stack(
                                    children: [
                                      Image.network(
                                        "http://127.0.0.1:8000/storage/${item.gambarBarang}",
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 12,
                                        top: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: item.status == "aktif"
                                                ? Colors.green.withOpacity(0.85)
                                                : Colors.red.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            item.status.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 📄 Info Barang
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.namaBarang,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Kategori: ${item.kategori ?? 'Lainnya'}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Harga Awal: Rp${item.hargaAwal}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // 🔘 Tombol Lihat Detail
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.visibility_rounded,
                                                color: Colors.white),
                                            label: const Text(
                                              "Lihat Detail",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF2575FC),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              elevation: 4,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AuctionDetailPage(item: item),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
