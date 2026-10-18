import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('خطوط السير'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [ Tab(text: 'الجارية'), Tab(text: 'الأرشيف') ],
          ),
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]))),
        ),
        body: TabBarView(
          children: [
            _buildRouteList(routeService, false, context),
            _buildRouteList(routeService, true, context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRouteScreen())),
          backgroundColor: AppTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRouteList(RouteService service, bool showCompleted, BuildContext context) {
    return StreamBuilder<List<DailyRoute>>(
      stream: service.getAllRoutes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        // فلترة: لو الأرشيف نعرض المكتمل، ولو الجارية نعرض غير المكتمل
        final routes = snapshot.data!.where((r) => showCompleted ? r.status == 'completed' : r.status != 'completed').toList();
        
        if (routes.isEmpty) return Center(child: Text(showCompleted ? 'لا يوجد أرشيف' : 'لا يوجد خطوط جارية'));
        
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
                leading: CircleAvatar(backgroundColor: route.isPublished ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1), child: Icon(Icons.route, color: route.isPublished ? AppTheme.success : AppTheme.warning)),
                title: Text('تاريخ: ${route.date}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('السائق: ${route.driverName}\nالحالة: ${route.isPublished ? "منشور" : "مسودة"}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RouteDetailsScreen(routeId: route.id, isAdmin: true))),
              ),
            ).animate().fadeIn(delay: (index * 50).ms).slideX();
          },
        );
      },
    );
  }
}
