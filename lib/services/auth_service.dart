import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/app_user.dart';
import '../core/utils/error_handler.dart';

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
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
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
      return null;
    } catch (e) {
      return ErrorHandler.getMessage(e);
    }
  }

  Future<String?> changePassword(String oldPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) return 'لا يوجد مستخدم مسجل';
      
      // إعادة المصادقة قبل تغيير الباسورد
      AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(credential);
      
      await user.updatePassword(newPassword);
      return null;
    } catch (e) {
      return ErrorHandler.getMessage(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
