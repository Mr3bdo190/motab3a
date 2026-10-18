import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/theme/app_theme.dart';
import 'route_collections_screen.dart';

class AdminCollectionsScreen extends StatelessWidget {
  const AdminCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل التحصيلات (بالخطوط)'), flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark])))),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('daily_routes').onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return const Center(child: Text('لا يوجد خطوط سير'));

          final routes = data.entries.toList();
          routes.sort((a, b) => ((b.value as Map)['date'] ?? '').toString().compareTo(((a.value as Map)['date'] ?? '').toString()));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final routeId = routes[index].key;
              final route = routes[index].value as Map;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.money, color: Colors.white)),
                  title: Text('تاريخ: ${route['date']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('السائق: ${route['driver_name']}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RouteCollectionsScreen(routeId: routeId, routeDate: route['date']))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
