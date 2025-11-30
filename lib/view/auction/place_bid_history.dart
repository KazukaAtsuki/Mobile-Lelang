import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_lelang/services/bid.dart';

class HistoryBidPage extends StatefulWidget {
  const HistoryBidPage({super.key});

  @override
  State<HistoryBidPage> createState() => _HistoryBidPageState();
}

class _HistoryBidPageState extends State<HistoryBidPage> {
  final BidService _bidService = BidService();
  bool _isLoading = true;
  
  int? _currentUserId;
  // List ini akan berisi data lelang unik yang pernah diikuti user
  List<Map<String, dynamic>> _participatedAuctions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    // 1. Ambil User ID dulu
    final user = await _bidService.getCurrentUser();
    if (user == null) {
      setState(() => _isLoading = false);
      return; 
    }
    _currentUserId = user['id'];

    // 2. Ambil Semua Data Bid
    final allBids = await _bidService.getAllBidsRaw();

    // 3. Logic Pengelompokan Data
    // Kita butuh map untuk menyimpan Lelang unik yang diikuti user
    Map<int, Map<String, dynamic>> auctionMap = {};

    // Filter bid milik user saya
    final myBids = allBids.where((bid) => bid['user_id'] == _currentUserId).toList();

    for (var myBid in myBids) {
      final lelang = myBid['lelang'];
      if (lelang == null) continue;
      
      int lelangId = lelang['id'];
      
      // Jika belum ada di map, masukkan
      if (!auctionMap.containsKey(lelangId)) {
        // Cari semua bid untuk lelang ini (dari global list) untuk bikin Leaderboard
        final bidsForThisItem = allBids.where((b) => b['lelang_id'] == lelangId).toList();
        
        // Urutkan bid dari tertinggi ke terendah
        bidsForThisItem.sort((a, b) {
           int priceA = int.parse(a['harga'].toString());
           int priceB = int.parse(b['harga'].toString());
           return priceB.compareTo(priceA);
        });

        // Ambil Top 5
        final top5 = bidsForThisItem.take(5).toList();

        // Cari harga tertinggi (Pemenang sementara)
        int highestPrice = int.parse(top5.first['harga'].toString());

        // Cari harga tertinggi milik SAYA di item ini
        final myBidsForThisItem = bidsForThisItem.where((b) => b['user_id'] == _currentUserId).toList();
        int myHighestBid = 0;
        if(myBidsForThisItem.isNotEmpty){
           myHighestBid = int.parse(myBidsForThisItem.first['harga'].toString());
        }

        // Tentukan status
        bool isWinning = (myHighestBid >= highestPrice);

        auctionMap[lelangId] = {
          'lelang': lelang,
          'my_highest_bid': myHighestBid,
          'top_5': top5,
          'is_winning': isWinning,
          'highest_price_now': highestPrice,
        };
      }
    }

    setState(() {
      _participatedAuctions = auctionMap.values.toList();
      _isLoading = false;
    });
  }

  String formatRupiah(int value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        title: const Text("Status Lelang Saya", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _participatedAuctions.isEmpty
              ? const Center(child: Text("Anda belum mengikuti lelang apapun."))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _participatedAuctions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final itemData = _participatedAuctions[index];
                    final lelang = itemData['lelang'];
                    final List<dynamic> top5 = itemData['top_5'];
                    final bool isWinning = itemData['is_winning'];
                    final int myBid = itemData['my_highest_bid'];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          // Header Card (Status Menang/Kalah)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isWinning ? Colors.green : Colors.redAccent,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    lelang['nama_barang'] ?? 'Unknown',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(isWinning ? Icons.check_circle : Icons.warning, color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        isWinning ? "MEMIMPIN" : "TERBALAP",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Info Tawaran Saya
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Tawaran Terakhir Anda:", style: TextStyle(color: Colors.grey)),
                                    Text(formatRupiah(myBid), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                const Divider(height: 24),
                                
                                // Leaderboard Title
                                const Text(
                                  "🏆 Top 5 Penawar Tertinggi",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4A47D5)),
                                ),
                                const SizedBox(height: 10),

                                // Leaderboard List
                                ...top5.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  var bid = entry.value;
                                  bool isMe = bid['user_id'] == _currentUserId;
                                  int price = int.parse(bid['harga'].toString());
                                  String name = bid['user'] != null ? bid['user']['name'] : 'User';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        // Rank Number
                                        Container(
                                          width: 24, 
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: idx == 0 ? Colors.amber : Colors.grey[200],
                                          ),
                                          child: Text(
                                            "${idx + 1}",
                                            style: TextStyle(
                                              fontSize: 12, 
                                              fontWeight: FontWeight.bold,
                                              color: idx == 0 ? Colors.white : Colors.black54
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Nama User
                                        Expanded(
                                          child: Text(
                                            isMe ? "$name (Saya)" : name,
                                            style: TextStyle(
                                              fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                              color: isMe ? Colors.blue[800] : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        // Harga
                                        Text(
                                          formatRupiah(price),
                                          style: TextStyle(
                                            fontWeight: idx == 0 ? FontWeight.bold : FontWeight.normal,
                                            color: isMe ? Colors.blue[800] : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                // Pesan jika kalah
                                if (!isWinning)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red.withOpacity(0.3))
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.info_outline, color: Colors.red, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Tawaran Anda tertinggal ${formatRupiah(itemData['highest_price_now'] - myBid)} dari harga tertinggi.",
                                              style: TextStyle(color: Colors.red[800], fontSize: 12),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}