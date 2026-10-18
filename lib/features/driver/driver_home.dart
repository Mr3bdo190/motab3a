import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/daily_route.dart';
import '../../models/route_stop.dart';
import '../../services/route_service.dart';
import '../admin/routes/route_details_screen.dart';
import '../shared/change_password_screen.dart';
import 'package:intl/intl.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final driverId = auth.currentUser?.uid ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('خطوط السير'),
          backgroundColor: AppTheme.success,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'اليوم'), Tab(text: 'الأرشيف')],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.password), tooltip: 'تغيير كلمة المرور', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
            IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
          ],
        ),
        body: TabBarView(
          children: [
            _buildRoutesList(driverId, false), // اليوم
            _buildRoutesList(driverId, true),  // الأرشيف
          ],
        ),
      ),
    );
  }

  Widget _buildRoutesList(String driverId, bool showCompleted) {
    return StreamBuilder<List<DailyRoute>>(
      stream: RouteService().getDriverRoutes(driverId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final routes = snapshot.data!.where((r) => showCompleted ? (r.status == 'completed' && r.isPublished) : (r.status != 'completed' && r.isPublished)).toList();
        
        if (routes.isEmpty) return Center(child: Text(showCompleted ? 'لا يوجد خطوط سابقة' : 'لا يوجد خط سير مسند لك اليوم'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final route = routes[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RouteDetailsScreen(routeId: route.id, isAdmin: false))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(showCompleted ? Icons.archive : Icons.local_shipping, size: 60, color: showCompleted ? Colors.grey : AppTheme.success),
                      const SizedBox(height: 16),
                      Text('تاريخ: ${route.date}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(showCompleted ? 'مكتمل' : 'اضغط لفتح تفاصيل الزيارات', style: TextStyle(color: showCompleted ? AppTheme.primary : AppTheme.textLight)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
}
