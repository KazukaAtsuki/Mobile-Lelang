import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:mobile_lelang/services/auth.dart';
import 'package:mobile_lelang/view/login_page.dart';
import 'package:mobile_lelang/view/navbar/bottomNavbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToNextPage();
  }

  Future<void> _goToNextPage() async {
    final auth = AuthService();

    await Future.delayed(const Duration(seconds: 2));

    final loggedIn = await auth.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 600),
        child: loggedIn ? const BottomNavbar() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 54),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset:  Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.gavel_rounded, color: Colors.black, size: 55),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lelangin",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
