import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // عشان الاهتزاز
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/customer.dart';
import '../../../models/route_stop.dart';
import '../../../services/route_service.dart';
import '../../driver/driver_visit_screen.dart';
import 'manage_order_screen.dart';

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
        title: Text(isAdmin ? 'تفاصيل الخط (مدير)' : 'خط سير اليوم'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.publish, color: Colors.white),
              onPressed: () async {
                await RouteService().publishRoute(routeId);
                if (context.mounted) {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النشر! السائق سيراه الآن'), backgroundColor: AppTheme.success));
                }
              },
            ),
          if (!isAdmin)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.white),
              tooltip: 'إنهاء خط السير',
              onPressed: () async {
                // التحقق من وجود عملاء لم تتم زيارتهم
                final snapshot = await FirebaseDatabase.instance.ref('route_stops').orderByChild('route_id').equalTo(routeId).get();
                if (snapshot.exists) {
                  final data = snapshot.value as Map;
                  int pendingCount = 0;
                  for (var stop in data.values) {
                    if (stop['status'] == 'pending') pendingCount++;
                  }
                  
                  if (pendingCount > 0) {
                    HapticFeedback.heavyImpact(); // اهتزاز تنبيه
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('لا يمكن إنهاء الخط! متبقي $pendingCount عميل لم يتم زيارته.'), backgroundColor: AppTheme.danger)
                      );
                    }
                    return;
                  }
                }

                await RouteService().completeRoute(routeId);
                HapticFeedback.mediumImpact();
                if (context.mounted) Navigator.pop(context);
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
            padding: const EdgeInsets.all(12),
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              final isDone = stop.status != 'pending';
              
              return Card(
                elevation: 4,
                shadowColor: Colors.black26,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isDone ? AppTheme.success.withOpacity(0.3) : AppTheme.primary.withOpacity(0.3), width: 1.5)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isDone ? AppTheme.success.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
                            child: Text('${stop.orderIndex}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDone ? AppTheme.success : AppTheme.primary)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stop.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: AppTheme.textLight),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(stop.customerAddress.isEmpty ? 'عنوان غير مسجل' : stop.customerAddress, style: const TextStyle(fontSize: 13, color: AppTheme.textLight))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: AppTheme.success),
                            onPressed: () {
                              HapticFeedback.selectionClick(); // اهتزاز خفيف عند الاتصال
                              launchUrl(Uri.parse('tel:${stop.customerPhone}'));
                            },
                          )
                        ],
                      ),
                      const Divider(height: 24),
                      
                      if (stop.orderItems.isNotEmpty) ...[
                        const Text('تفاصيل الطلب:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: stop.orderItems.map((item) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                            child: Text('${item['name']} × ${item['quantity']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          )).toList(),
                        ),
                      ] else if (isAdmin) ...[
                        TextButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('إضافة منتجات للطلب'),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageOrderScreen(stopId: stop.id, existingItems: stop.orderItems))),
                        )
                      ] else ...[
                        const Text('لا يوجد طلب مسجل', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      ],

                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDone ? Colors.grey.shade200 : AppTheme.primary,
                            foregroundColor: isDone ? Colors.grey.shade700 : Colors.white,
                          ),
                          onPressed: isDone ? null : () {
                            if (isAdmin) {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => ManageOrderScreen(stopId: stop.id, existingItems: stop.orderItems)));
                            } else {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => DriverVisitScreen(stop: stop)));
                            }
                          },
                          child: Text(isAdmin ? 'إدارة الطلب' : (isDone ? 'تمت الزيارة' : 'تسجيل زيارة وتحصيل')),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () async {
           final snap = await FirebaseDatabase.instance.ref('route_stops').orderByChild('route_id').equalTo(routeId).get();
           final list = snap.exists ? (snap.value as Map).entries.map((e) => RouteStop.fromMap(e.key, e.value)).toList() : <RouteStop>[];
           if (context.mounted) _showAddCustomerDialog(context, list);
        },
        child: const Icon(Icons.person_add),
      ) : null,
    );
  }
}
