import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found': return 'لا يوجد حساب بهذا الرقم';
        case 'wrong-password': return 'كلمة المرور غير صحيحة';
        case 'email-already-in-use': return 'هذا الحساب مسجل بالفعل';
        case 'invalid-email': return 'صيغة البريد الإلكتروني غير صحيحة';
        case 'weak-password': return 'كلمة المرور ضعيفة جداً';
        case 'network-request-failed': return 'لا يوجد اتصال بالإنترنت';
        case 'requires-recent-login': return 'يرجى تسجيل الخروج والدخول مرة أخرى لتغيير كلمة المرور';
        default: return 'حدث خطأ في المصادقة، يرجى المحاولة لاحقاً';
      }
    }
    return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً';
  }
}
