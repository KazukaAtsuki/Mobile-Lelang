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
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _auctions = _auctionService.getAuctions();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _auctionService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      debugPrint("Error loading categories: $e");
    }
  }

  Future<void> _refreshAuctions() async {
    setState(() {
      _auctions = _auctionService.getAuctions(
        kategoriId: _selectedCategoryId,
      );
    });
  }

  void _onCategoryChanged(int? id) {
    setState(() {
      _selectedCategoryId = id;
      _auctions = _auctionService.getAuctions(kategoriId: id);
    });
  }

  List<AuctionItem> _filterAuctions(List<AuctionItem> items) {
    return items.where((item) {
      final matchSearch = item.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchSearch;
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

              // 🔍 Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
              ),

              const SizedBox(height: 10),

              // 🧩 Dropdown kategori dari API
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text("Filter berdasarkan kategori"),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text("Semua Kategori"),
                      ),
                      ..._categories.map((cat) => DropdownMenuItem<int>(
                            value: cat['id'],
                            child: Text(cat['nama_kategori']),
                          )),
                    ],
                    onChanged: _onCategoryChanged,
                  ),
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
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // dua kolom seperti layout samping
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
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
                                  Stack(
                                    children: [
                                      Image.network(
                                        "http://127.0.0.1:8000/storage/${item.gambarBarang}",
                                        height: 100,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: item.status == "aktif"
                                                ? Colors.green.withOpacity(0.85)
                                                : Colors.red.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item.status.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.namaBarang,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Rp${item.hargaAwal}",
                                          style: TextStyle(
                                            color: Colors.green.shade200,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Kategori: ${item.kategoriNama ?? 'Lainnya'}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF2575FC),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => AuctionDetailPage(item: item),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.visibility, color: Colors.white, size: 14),
                                            label: const Text(
                                              "Detail",
                                              style: TextStyle(fontSize: 12, color: Colors.white),
                                            ),
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
