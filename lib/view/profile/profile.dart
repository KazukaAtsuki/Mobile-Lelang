import 'package:flutter/material.dart';
import 'package:mobile_lelang/services/auth.dart';
import 'package:mobile_lelang/services/user.dart';
import 'package:mobile_lelang/models/user.dart';
import 'package:mobile_lelang/view/login_page.dart';
import 'package:mobile_lelang/view/nipl/nipl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  
  User? _currentUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final token = await _auth.getToken(); 

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    final user = await _userService.getCurrentUser(token);

    setState(() {
      _currentUser = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _currentUser == null
                ? const Center(child: Text("Gagal memuat data user"))
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.person_rounded, color: Colors.black, size: 30),
                  SizedBox(width: 8),
                  Text(
                    "Profil Saya",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black),
                onPressed: () async {
                  await _auth.logout();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
              )
            ],
          ),
        ),

        const SizedBox(height: 10),

        // PROFILE CARD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 45, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.name ?? "No Name",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Email: ${_currentUser?.email ?? '-'}",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          "Member sejak 2025",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // MENU LIST
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildMenuCard(
                icon: Icons.calendar_view_day,
                title: "Nipl Saya",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NiplPage(),));
                },
              ),
              _buildMenuCard(
                icon: Icons.history_rounded,
                title: "Riwayat Lelang",
                onTap: () {},
              ),
              _buildMenuCard(
                icon: Icons.favorite_rounded,
                title: "Barang Favorit",
                onTap: () {},
              ),
              _buildMenuCard(
                icon: Icons.settings_rounded,
                title: "Pengaturan Akun",
                onTap: () {},
              ),
              _buildMenuCard(
                icon: Icons.help_center_rounded,
                title: "Bantuan",
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.indigo),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}
