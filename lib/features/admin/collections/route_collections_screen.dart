import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/theme/app_theme.dart';

class RouteCollectionsScreen extends StatelessWidget {
  final String routeId;
  final String routeDate;
  const RouteCollectionsScreen({super.key, required this.routeId, required this.routeDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تحصيلات خط سير: $routeDate')),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('collections').orderByChild('route_id').equalTo(routeId).onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return const Center(child: Text('لا يوجد تحصيلات في هذا الخط'));

          final cols = data.values.toList();
          double total = 0;
          for (var c in cols) { total += (c['amount'] ?? 0).toDouble(); }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20), margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.success, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [const Text('إجمالي هذا الخط', style: TextStyle(color: Colors.white70)), const SizedBox(height: 8), Text('$total ج.م', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cols.length,
                  itemBuilder: (context, index) {
                    final col = cols[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppTheme.success, child: Icon(Icons.person, color: Colors.white)),
                        title: Text(col['customer_name'] ?? 'عميل', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(col['customer_phone'] ?? ''),
                        trailing: Text('${col['amount']} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 16)),
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
