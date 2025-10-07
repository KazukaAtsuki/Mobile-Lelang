// import 'package:flutter/material.dart';
// import 'package:mobile_lelang/services/auction.dart';
// import 'package:mobile_lelang/models/auction.dart';

// class NiplPage extends StatefulWidget {
//   final AuctionItem auction;

//   const NiplPage({super.key, required this.auction});

//   @override
//   State<NiplPage> createState() => _NiplPageState();
// }

// class _NiplPageState extends State<NiplPage> {
//   final TextEditingController _bidController = TextEditingController();
//   final AuctionService _auctionService = AuctionService();
//   bool _loading = false;

//   Future<void> _submitBid() async {
//     final bidAmount = int.tryParse(_bidController.text);
//     if (bidAmount == null || bidAmount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Masukkan nominal yang valid")),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final success = await _auctionService.placebid(widget.auction.id, bidAmount);
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Berhasil ikut lelang 🎉")),
//         );
//         Navigator.pop(context, true); // balik ke detail
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Gagal ikut lelang")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }

//     setState(() => _loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Ikut Lelang"),
//         backgroundColor: const Color(0xFF2575FC),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Barang: ${widget.auction.namaBarang}",
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 18)),
//             const SizedBox(height: 10),
//             Text("Harga Awal: Rp${widget.auction.hargaAwal}"),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _bidController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: "Masukkan harga penawaran",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _submitBid,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2575FC),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: _loading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("Submit Penawaran"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
