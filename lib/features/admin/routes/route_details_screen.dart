import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            width: double.maxFinite, height: 400,
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
                      title: Text(c.name), subtitle: Text(c.phone),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isAdmin ? 'كشف خط السير (مدير)' : 'كشف خط السير'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.publish, color: Colors.white),
              onPressed: () async {
                await RouteService().publishRoute(routeId);
                if (context.mounted) {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النشر!'), backgroundColor: AppTheme.success));
                }
              },
            ),
          if (!isAdmin)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.white),
              onPressed: () async {
                final snapshot = await FirebaseDatabase.instance.ref('route_stops').orderByChild('route_id').equalTo(routeId).get();
                if (snapshot.exists) {
                  final data = snapshot.value as Map;
                  int pendingCount = 0;
                  for (var stop in data.values) { if (stop['status'] == 'pending') pendingCount++; }
                  if (pendingCount > 0) {
                    HapticFeedback.heavyImpact();
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('متبقي $pendingCount عميل لم يتم زيارته!'), backgroundColor: AppTheme.danger));
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
          
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(AppTheme.primary.withOpacity(0.1)),
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 14),
                dataRowMinHeight: 60, dataRowMaxHeight: 80, columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('العميل')),
                  DataColumn(label: Text('الهاتف')),
                  DataColumn(label: Text('العنوان')),
                  DataColumn(label: Text('الطلب')),
                  DataColumn(label: Text('إجراء')),
                ],
                rows: stops.map((stop) {
                  final isDone = stop.status != 'pending';
                  return DataRow(
                    cells: [
                      DataCell(Text('${stop.orderIndex}', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(stop.customerName, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(stop.customerPhone, style: const TextStyle(fontSize: 12)),
                            IconButton(icon: const Icon(Icons.phone, color: Colors.green, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => launchUrl(Uri.parse('tel:${stop.customerPhone}'))),
                          ],
                        ),
                      ),
                      DataCell(SizedBox(width: 150, child: Text(stop.customerAddress.isEmpty ? 'غير مسجل' : stop.customerAddress, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis))),
                      DataCell(
                        stop.orderItems.isEmpty 
                        ? (isAdmin ? TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageOrderScreen(stopId: stop.id, existingItems: stop.orderItems))), child: const Text('إضافة طلب')) : const Text('لا يوجد'))
                        : SizedBox(width: 120, child: Text(stop.orderItems.map((item) => "${item['name']} (${item['quantity']})").join(' - '), style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
                      ),
                      DataCell(
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDone ? Colors.grey.shade300 : AppTheme.primary,
                            foregroundColor: isDone ? Colors.grey.shade700 : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(60, 30)
                          ),
                          onPressed: isDone ? null : () {
                            if (isAdmin) { Navigator.push(context, MaterialPageRoute(builder: (_) => ManageOrderScreen(stopId: stop.id, existingItems: stop.orderItems))); } 
                            else { Navigator.push(context, MaterialPageRoute(builder: (_) => DriverVisitScreen(stop: stop))); }
                          },
                          child: Text(isAdmin ? 'تعديل' : (isDone ? 'تم' : 'زيارة'), style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
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
