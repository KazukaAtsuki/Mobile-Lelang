import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_lelang/models/auction.dart';
import 'package:mobile_lelang/services/bid.dart'; // Pastikan nama file service sesuai

class PlaceBidPage extends StatefulWidget {
  final AuctionItem item;

  const PlaceBidPage({super.key, required this.item});

  @override
  State<PlaceBidPage> createState() => _PlaceBidPageState();
}

class _PlaceBidPageState extends State<PlaceBidPage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _bidService = BidService();
  
  bool _isLoading = false;

  // Warna Utama
  final Color primaryColor = const Color(0xFF4A47D5);

  @override
  void initState() {
    super.initState();
    // Opsional: Isi input awal dengan harga minimal + sedikit kenaikan
    // _priceController.text = _formatNumber(_minBid + 10000); 
  }

  // Helper: Mendapatkan angka minimal bid
  int get _minBid {
    if (widget.item.hargaAkhir != null && widget.item.hargaAkhir! > 0) {
      return widget.item.hargaAkhir!;
    }
    return widget.item.hargaAwal;
  }

  // Helper: Format Rupiah string untuk tampilan
  String _formatNumber(int number) {
    final format = NumberFormat.decimalPattern('id');
    return format.format(number);
  }

  // Helper: Format Rupiah lengkap dengan simbol
  String formatRupiah(int value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
  }

  // Fungsi menambah harga lewat tombol Quick Bid
  void _addQuickBid(int amount) {
    // Ambil nilai saat ini dari controller (hapus titik dulu)
    String cleanText = _priceController.text.replaceAll('.', '');
    int currentVal = int.tryParse(cleanText) ?? _minBid;
    
    // Jika input kosong atau dibawah min, start dari minBid
    if (currentVal < _minBid) currentVal = _minBid;

    int newVal = currentVal + amount;
    
    setState(() {
      _priceController.text = _formatNumber(newVal);
      // Pindahkan kursor ke akhir teks
      _priceController.selection = TextSelection.fromPosition(
        TextPosition(offset: _priceController.text.length),
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Bersihkan input dari titik (format ribuan) sebelum kirim ke API
    String cleanValue = _priceController.text.replaceAll('.', '');
    int bidPrice = int.parse(cleanValue);

    setState(() => _isLoading = true);

    // Panggil Service
    final result = await _bidService.placeBid(widget.item.id, bidPrice);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(height: 10),
              Text("Tawaran Masuk!"),
            ],
          ),
          content: Text(
            "Anda berhasil menawar di angka\n${formatRupiah(bidPrice)}",
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context, true); // Kembali ke detail & refresh
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        title: const Text("Pasang Tawaran", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Gambar Barang & Info Singkat
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Image.network(
                    "http://127.0.0.1:8000/storage/${widget.item.gambarBarang}",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      height: 180, 
                      color: Colors.grey[200], 
                      child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey))
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      widget.item.namaBarang,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Info Harga Tertinggi
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Posisi Tertinggi", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text("Saat Ini", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          Text(
                            formatRupiah(_minBid),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text("Masukkan Tawaran Anda", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),

                    // 3. Input Field dengan Formatter
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyInputFormatter(), // Custom Class di bawah
                      ],
                      decoration: InputDecoration(
                        prefixText: "Rp ",
                        hintText: "0",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Harga tidak boleh kosong";
                        
                        // Hapus titik untuk validasi angka
                        String clean = value.replaceAll('.', '');
                        int? val = int.tryParse(clean);
                        
                        if (val == null) return "Masukkan angka valid";
                        if (val <= _minBid) return "Harus lebih tinggi dari ${formatRupiah(_minBid)}";
                        
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    
                    // 4. Quick Bid Buttons (Chips)
                    const Text("Tambah Cepat:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        _buildQuickButton(10000),
                        _buildQuickButton(50000),
                        _buildQuickButton(100000),
                        _buildQuickButton(500000),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // 5. Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 5,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text("KIRIM TAWARAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(int amount) {
    return ActionChip(
      label: Text("+${NumberFormat.compact(locale: 'id').format(amount)}"),
      backgroundColor: Colors.white,
      side: BorderSide(color: primaryColor.withOpacity(0.5)),
      labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      onPressed: () => _addQuickBid(amount),
    );
  }
}

// ==========================================
// Class Tambahan: Formatter untuk Input Rupiah (Ribuan)
// ==========================================
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    int value = int.parse(newValue.text.replaceAll('.', ''));
    final formatter = NumberFormat('#,###', 'id');
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText.replaceAll(',', '.'), // Memastikan pemisah ribuan adalah titik
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}