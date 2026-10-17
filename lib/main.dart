import 'package:flutter/material.dart';

void main() {
  runApp(const Motab3aApp());
}

class Motab3aApp extends StatelessWidget {
  const Motab3aApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متابعة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        useMaterial3: true,
        fontFamily: 'Cairo', // سنضيفه لاحقاً
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 100, color: Color(0xFF0F9D58)),
                SizedBox(height: 20),
                Text(
                  'تم بناء التطبيق بنجاح!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('GitHub Actions يعمل بكفاءة 🚀'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
