import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/daily_route.dart';
import '../../services/route_service.dart';
import '../admin/routes/route_details_screen.dart'; // بنستخدم نفس الشاشة بس بدون زر إضافة

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final driverId = auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('خط سير اليوم'),
        backgroundColor: AppTheme.success,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      body: StreamBuilder<List<DailyRoute>>(
        stream: RouteService().getDriverRoutes(driverId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          // بنفلتر بس اللي منشور ولسه مخلصش
          final routes = snapshot.data!.where((r) => r.isPublished && r.status != 'completed').toList();
          
          if (routes.isEmpty) {
            return const Center(child: Text('لا يوجد خط سير مسند لك اليوم'));
          }

          final route = routes.first;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RouteDetailsScreen(routeId: route.id, isAdmin: false))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_shipping, size: 60, color: AppTheme.success),
                      const SizedBox(height: 16),
                      Text('تاريخ: ${route.date}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('اضغط لفتح تفاصيل الزيارات والتحصيل', style: TextStyle(color: AppTheme.textLight)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
