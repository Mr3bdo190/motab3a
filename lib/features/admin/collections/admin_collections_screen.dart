import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/theme/app_theme.dart';

class AdminCollectionsScreen extends StatelessWidget {
  const AdminCollectionsScreen({super.key});

  void _editCollection(BuildContext context, String key, Map<dynamic, dynamic> col) {
    final amountCtrl = TextEditingController(text: col['amount'].toString());
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل التحصيل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ الجديد')),
            const SizedBox(height: 16),
            TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'سبب التعديل')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final newAmount = double.tryParse(amountCtrl.text);
              if (newAmount == null || reasonCtrl.text.isEmpty) return;
              
              final oldAmount = col['amount'];
              // 1. تحديث التحصيل
              await FirebaseDatabase.instance.ref('collections').child(key).update({'amount': newAmount, 'is_edited': true});
              // 2. تسجيل في سجل التدقيق
              await FirebaseDatabase.instance.ref('audit_logs').push().set({
                'collection_id': key,
                'old_amount': oldAmount,
                'new_amount': newAmount,
                'reason': reasonCtrl.text.trim(),
                'edited_at': ServerValue.timestamp,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل التحصيلات'), flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark])))),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('collections').onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return const Center(child: Text('لا يوجد تحصيلات حتى الآن'));

          final entries = data.entries.toList();
          entries.sort((a, b) => ((b.value as Map)['timestamp'] ?? 0).compareTo((a.value as Map)['timestamp'] ?? 0));

          double total = 0;
          for (var c in entries) { total += ((c.value as Map)['amount'] ?? 0).toDouble(); }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24), margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.success, Color(0xFF0B7A43)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppTheme.success.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
                child: Column(children: [const Text('إجمالي التحصيلات', style: TextStyle(color: Colors.white70, fontSize: 16)), const SizedBox(height: 8), Text('$total ج.م', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final key = entries[index].key;
                    final col = entries[index].value as Map<dynamic, dynamic>;
                    final date = DateTime.fromMillisecondsSinceEpoch(col['timestamp'] ?? 0);
                    final isEdited = col['is_edited'] == true;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _editCollection(context, key, col),
                        leading: CircleAvatar(backgroundColor: isEdited ? AppTheme.warning : AppTheme.success, child: const Icon(Icons.money, color: Colors.white)),
                        title: Text('${col['amount']} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success)),
                        subtitle: Text('${col['customer_name'] ?? 'عميل'}\n${date.day}/${date.month} - ${date.hour}:${date.minute}'),
                        trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
