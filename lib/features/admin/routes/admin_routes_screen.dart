import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/daily_route.dart';
import '../../../services/route_service.dart';
import '../../shared/add_route_screen.dart';
import 'route_details_screen.dart';

class AdminRoutesScreen extends StatelessWidget {
  const AdminRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routeService = RouteService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطوط السير'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
          ),
        ),
      ),
      body: StreamBuilder<List<DailyRoute>>(
        stream: routeService.getAllRoutes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final routes = snapshot.data!;
          if (routes.isEmpty) {
            return const Center(child: Text('لا يوجد خطوط سير، اضغط + للإضافة'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: route.isPublished ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
                    child: Icon(Icons.route, color: route.isPublished ? AppTheme.success : AppTheme.warning),
                  ),
                  title: Text('تاريخ: ${route.date}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('السائق: ${route.driverName}\nالحالة: ${route.isPublished ? "منشور" : "مسودة"}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RouteDetailsScreen(routeId: route.id, isAdmin: true))),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideX();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRouteScreen())),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
