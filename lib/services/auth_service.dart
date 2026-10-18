import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> getUserData(String uid) async {
    final snapshot = await _db.child('users').child(uid).get();
    if (snapshot.exists) {
      return AppUser.fromMap(uid, snapshot.value as Map);
    }
    return null;
  }

  Future<String?> login(String phone, String password) async {
    try {
      String email = phone.contains('@') ? phone : '$phone@app.local';
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        AppUser? user = await getUserData(result.user!.uid);
        if (user == null) {
          await _auth.signOut();
          return 'لا توجد بيانات لهذا الحساب';
        }
        if (!user.isActive) {
          await _auth.signOut();
          return 'هذا الحساب معطل، تواصل مع المدير';
        }
      }
      return null; // Null means success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'رقم الهاتف أو كلمة المرور غير صحيحة';
      }
      return e.message;
    } catch (e) {
      return 'حدث خطأ غير متوقع';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
