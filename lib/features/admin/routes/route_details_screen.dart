import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/customer.dart';
import '../../../models/route_stop.dart';
import '../../../services/route_service.dart';
import '../../driver/driver_visit_screen.dart';

class RouteDetailsScreen extends StatelessWidget {
  final String routeId;
  final bool isAdmin;
  const RouteDetailsScreen({super.key, required this.routeId, required this.isAdmin});

  void _showAddCustomerDialog(BuildContext context, List<RouteStop> currentStops) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة عميل للخط'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: FutureBuilder(
              future: FirebaseDatabase.instance.ref('customers').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final data = snapshot.data!.value as Map<dynamic, dynamic>?;
                if (data == null) return const Text('لا يوجد عملاء');
                
                final customers = data.entries.map((e) => Customer.fromMap(e.key, e.value)).toList();
                return ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final c = customers[index];
                    final isAdded = currentStops.any((s) => s.customerId == c.id);
                    return ListTile(
                      title: Text(c.name),
                      subtitle: Text(c.phone),
                      trailing: isAdded ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.add),
                      onTap: isAdded ? null : () async {
                        await RouteService().addStopToRoute(routeId, c, currentStops.length + 1);
                        if (context.mounted) Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'تفاصيل الخط (مدير)' : 'خط سيري'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.publish, color: Colors.white),
              tooltip: 'نشر للسائق',
              onPressed: () async {
                await RouteService().publishRoute(routeId);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النشر! السائق سيراه الآن'), backgroundColor: AppTheme.success));
              },
            )
        ],
      ),
      body: StreamBuilder<List<RouteStop>>(
        stream: RouteService().getRouteStops(routeId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final stops = snapshot.data!;
          if (stops.isEmpty) return const Center(child: Text('لا يوجد عملاء في هذا الخط'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              final isDone = stop.status != 'pending';
              
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isDone ? AppTheme.success.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
                    child: Text(stop.orderIndex.toString(), style: TextStyle(color: isDone ? AppTheme.success : AppTheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(stop.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(stop.customerPhone),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(isDone ? 'تم' : 'معلق', style: TextStyle(color: isDone ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.bold)),
                      if (isDone) Text('${stop.collectedAmount} ج.م', style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ),
                  onTap: () {
                    if (!isAdmin) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DriverVisitScreen(stop: stop)));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        onPressed: () async {
           final snap = await FirebaseDatabase.instance.ref('route_stops').orderByChild('route_id').equalTo(routeId).get();
           final list = snap.exists ? (snap.value as Map).entries.map((e) => RouteStop.fromMap(e.key, e.value)).toList() : <RouteStop>[];
           if (context.mounted) _showAddCustomerDialog(context, list);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة عميل'),
      ) : null,
    );
  }
}
