import 'package:flutter/material.dart';
import 'package:mobile_lelang/models/nipl.dart';
import 'package:mobile_lelang/services/nipl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NiplPage extends StatefulWidget {
  const NiplPage({super.key});

  @override
  State<NiplPage> createState() => _NiplPageState();
}

class _NiplPageState extends State<NiplPage> {
  NiplModel? nipl;
  bool isLoading = true;
  final TextEditingController _phoneController = TextEditingController();
  final NiplService _niplService = NiplService();

  @override
  void initState() {
    super.initState();
    _loadNipl();
  }

  Future<void> _loadNipl() async {
    try {
      final fetched = await _niplService.checkNipl();
      setState(() {
        nipl = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _buyNipl() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nomor telepon')),
      );
      return;
    }

    try {
      final url = await _niplService.createNipl(phone);
      if (url != null && context.mounted) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat NIPL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "NIPL Saya",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B1221),
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : nipl != null
              ? ListView(
                  padding: const EdgeInsets.all(0),
                  children: [
                    Card(
                      margin: const EdgeInsets.all(16),
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Ikon di kiri
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                Icons.credit_card_outlined,
                                size: 64,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Detail teks di kanan
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "No Nipl : ${nipl!.noNipl.toString()}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Email: ${nipl!.email}",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  Text(
                                    "No Telepon: ${nipl!.noTelepon}",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  Text(
                                    "Tanggal pembuatan: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(nipl!.createdAt.toUtc().add(const Duration(hours: 7)))} WIB",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Anda belum memiliki NIPL",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Nomor Telepon",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.payment, color: Colors.white),
                        label: const Text(
                          "Beli NIPL (Rp25.000)",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 19, 19, 54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _buyNipl,
                      )
                    ],
                  ),
                ),
    );
  }
}
