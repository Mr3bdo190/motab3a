import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthWrapper(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // اللوجو
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
                ],
              ),
              child: const Icon(Icons.local_shipping, size: 100, color: AppTheme.primary),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 32),
            
            // اسم التطبيق
            const Text(
              'متابعة',
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
            
            const SizedBox(height: 8),
            
            // الوصف
            const Text(
              'نظام إدارة التوزيع والتحصيل',
              style: TextStyle(fontSize: 16, color: AppTheme.textLight),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
