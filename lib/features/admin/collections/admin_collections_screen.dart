import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/theme/app_theme.dart';

class AdminCollectionsScreen extends StatelessWidget {
  const AdminCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل التحصيلات'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]))),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('collections').onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return const Center(child: Text('لا يوجد تحصيلات حتى الآن'));

          final collections = data.entries.map((e) => e.value as Map<dynamic, dynamic>).toList();
          collections.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

          double total = 0;
          for (var c in collections) { total += (c['amount'] ?? 0).toDouble(); }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.success, Color(0xFF0B7A43)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppTheme.success.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    const Text('إجمالي التحصيلات', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('$total ج.م', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final col = collections[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(col['timestamp'] ?? 0);
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppTheme.success, child: Icon(Icons.money, color: Colors.white)),
                        title: Text('${col['amount']} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.success)),
                        subtitle: Text('تاريخ: ${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}'),
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
