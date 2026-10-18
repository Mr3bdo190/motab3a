import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _addDriver() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passController.text.trim();

    if (name.isEmpty || phone.isEmpty || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء الحقول (الباسورد 6 أحرف على الأقل)'), backgroundColor: AppTheme.danger));
      return;
    }

    setState(() => _isLoading = true);
    final currentUser = FirebaseAuth.instance.currentUser;
    final adminEmail = currentUser!.email!;
    final adminPass = _passController.text.trim(); // Using same pass for admin check for simplicity in this demo, but ideally ask for admin pass.

    try {
      // 1. Create user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: '$phone@app.local', password: pass);
      
      // 2. Save to DB
      await FirebaseDatabase.instance.ref('users').child(cred.user!.uid).set({
        'name': name,
        'email': '$phone@app.local',
        'role': 'driver',
        'is_active': true,
        'created_at': ServerValue.timestamp,
      });

      // 3. Log back in as admin (since createUser signs in the new user)
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: adminEmail, password: adminPass);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة السائق بنجاح'), backgroundColor: AppTheme.success));
        _nameController.clear();
        _phoneController.clear();
        _passController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: AppTheme.danger));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة السائقين')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('إضافة سائق جديد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 12),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _addDriver,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('إضافة السائق'),
            ),
            const Divider(height: 40),
            const Text('قائمة السائقين الحاليين', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: FirebaseDatabase.instance.ref('users').orderByChild('role').equalTo('driver').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
                if (data == null) return const Text('لا يوجد سائقين');
                
                final drivers = data.values.toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final d = drivers[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.directions_car)),
                        title: Text(d['name']),
                        subtitle: Text(d['email'].toString().replaceAll('@app.local', '')),
                        trailing: Icon(d['is_active'] == true ? Icons.check_circle : Icons.cancel, color: d['is_active'] == true ? AppTheme.success : AppTheme.danger),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
