import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_lelang/services/auth.dart';
import 'package:mobile_lelang/view/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  File? _avatar;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatar = File(picked.path);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await _authService.register(
        avatar: _avatar,
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register success: ${response['user']['email']}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register failed: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Elemen garis hiasan di background
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(120),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),

                      // Judul Aplikasi
                      Text(
                        "Lelangin",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Avatar Picker
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
                            backgroundColor: Colors.blue.shade200,
                            child: _avatar == null
                                ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Input Fields
                      _buildInputField(
                        controller: _nameController,
                        icon: Icons.person,
                        label: "Nama Lengkap",
                        validator: (val) => val!.isEmpty ? "Masukkan nama kamu" : null,
                      ),
                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: _emailController,
                        icon: Icons.email,
                        label: "Email",
                        validator: (val) => val!.isEmpty ? "Masukkan email kamu" : null,
                      ),
                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: _passwordController,
                        icon: Icons.lock,
                        label: "Password",
                        obscureText: true,
                        validator: (val) =>
                            val!.length < 8 ? "Password minimal 8 karakter" : null,
                      ),
                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: _confirmPasswordController,
                        icon: Icons.lock_outline,
                        label: "Konfirmasi Password",
                        obscureText: true,
                        validator: (val) =>
                            val != _passwordController.text ? "Password tidak sama" : null,
                      ),

                      const SizedBox(height: 24),

                      // Tombol Register
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Daftar Sekarang",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Ke login page
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const LoginPage()));
                        },
                        child: const Text(
                          "Sudah punya akun? Login di sini",
                          style: TextStyle(
                            color: Color(0xFF2575FC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk input field
  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2575FC), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
