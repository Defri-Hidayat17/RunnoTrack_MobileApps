import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:runnotrack/onboardingpage.dart';
import 'package:runnotrack/homepage.dart';
import 'package:runnotrack/loginpage_user.dart';
import 'package:runnotrack/loginpage.dart';
import 'package:runnotrack/admin_main_scaffold.dart'; // <--- IMPORT INI UNTUK ADMIN

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  static const String _prefsKeyIsLoggedIn = 'is_logged_in';
  static const String _prefsKeyIsOnboarded = 'is_onboarded';
  static const String _prefsKeyAccountType =
      'user_account_type'; // <--- KUNCI BARU

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.1,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(_prefsKeyIsLoggedIn) ?? false;
    final bool isOnboarded = prefs.getBool(_prefsKeyIsOnboarded) ?? false;
    final String? accountType = prefs.getString(
      _prefsKeyAccountType,
    ); // <--- AMBIL TIPE AKUN

    // --- DEBUGGING PRINTS ---
    print('--- SplashScreen Navigation Check ---');
    print('isLoggedIn: $isLoggedIn');
    print('isOnboarded: $isOnboarded');
    print('accountType: $accountType'); // <--- DEBUGGING TIPE AKUN
    print('-----------------------------------');
    // --- END DEBUGGING PRINTS ---

    if (isLoggedIn) {
      if (accountType == 'Admin' || accountType == 'Supervisor') {
        // <--- LOGIKA BARU UNTUK ADMIN/SUPERVISOR
        print(
          'Navigating to AdminMainScaffold (Admin/Supervisor is logged in)',
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminMainScaffold()),
        );
      } else if (accountType == 'User') {
        // <--- LOGIKA UNTUK USER BIASA
        print('Navigating to HomePage (User is logged in)');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Jika isLoggedIn true tapi accountType tidak dikenal/null (ini seharusnya tidak terjadi jika login benar)
        print(
          'Navigating to LoginPage (Logged in but unknown account type, forcing re-login)',
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      if (isOnboarded) {
        print('Navigating to LoginPage (User is onboarded but not logged in)');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        print(
          'Navigating to OnboardingPage (User is neither onboarded nor logged in)',
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final mainLogoWidth = (screenWidth * 0.7).clamp(250.0, 400.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0B3C6F),
                        Color(0xFF021E3C),
                        Color(0xFF000F25),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0x220B3C6F),
                        Color(0x33021E3C),
                        Color(0x44000F25),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: SvgPicture.asset(
                      'assets/images/logolengkap.svg',
                      width: mainLogoWidth,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
