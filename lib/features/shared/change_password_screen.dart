import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_oldPassController.text.isEmpty || _newPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال البيانات بشكل صحيح (الباسورد الجديد 6 أحرف على الأقل)')));
      return;
    }
    setState(() => _isLoading = true);
    final error = await AuthService().changePassword(_oldPassController.text, _newPassController.text);
    setState(() => _isLoading = false);
    
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppTheme.danger));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح'), backgroundColor: AppTheme.success));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تغيير كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _oldPassController, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور الحالية', prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 16),
            TextField(controller: _newPassController, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة', prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('تحديث كلمة المرور'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
