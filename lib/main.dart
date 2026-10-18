import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/driver/driver_home.dart';
import 'core/theme/app_theme.dart';
import 'features/shared/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // تفعيل الحفظ المحلي (عشان لو النت قطع التطبيق يفضل شغال)
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const Motab3aApp(),
    ),
  );
}

class Motab3aApp extends StatelessWidget {
  const Motab3aApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متابعة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: SplashScreen(), // شاشة البداية
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.currentUser == null) {
      return const LoginScreen();
    }

    if (authProvider.currentUser!.role == 'admin') {
      return const AdminDashboard();
    } else {
      return const DriverHome();
    }
  }
}
