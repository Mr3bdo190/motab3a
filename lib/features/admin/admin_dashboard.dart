import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'products/product_list_screen.dart';
import 'customers/customer_list_screen.dart';
import 'routes/admin_routes_screen.dart';
import 'collections/admin_collections_screen.dart';
import 'users/admin_users_screen.dart';
import '../shared/change_password_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200, floating: false, pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('مرحباً بك،', style: TextStyle(color: Colors.white70, fontSize: 16)),
                                Text(auth.currentUser?.name ?? 'مدير', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.password, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
                                IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => auth.logout()),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1),
              delegate: SliverChildListDelegate([
                _DashboardCard(title: 'المنتجات', icon: Icons.inventory_2, color: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())), delay: 0, isDark: isDark),
                _DashboardCard(title: 'العملاء', icon: Icons.people, color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())), delay: 100, isDark: isDark),
                _DashboardCard(title: 'خطوط السير', icon: Icons.route, color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRoutesScreen())), delay: 200, isDark: isDark),
                _DashboardCard(title: 'التحصيلات', icon: Icons.account_balance_wallet, color: Colors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCollectionsScreen())), delay: 300, isDark: isDark),
                _DashboardCard(title: 'إدارة السائقين', icon: Icons.manage_accounts, color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen())), delay: 400, isDark: isDark),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int delay;
  final bool isDark;
  
  const _DashboardCard({required this.title, required this.icon, required this.color, required this.onTap, required this.delay, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, 
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [BoxShadow(color: isDark ? Colors.black45 : color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 30)),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
      ).animate().fadeIn(delay: delay.ms).scaleXY(begin: 0.8, curve: Curves.easeOutBack),
    );
  }
}
