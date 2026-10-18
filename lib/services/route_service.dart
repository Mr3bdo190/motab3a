import 'package:firebase_database/firebase_database.dart';
import '../models/daily_route.dart';
import '../models/route_stop.dart';
import '../models/customer.dart';

class RouteService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // جلب كل الخطوط (للمدير)
  Stream<List<DailyRoute>> getAllRoutes() {
    return _db.child('daily_routes').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      final list = data.entries.map((e) => DailyRoute.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  // جلب خط السير الخاص بسائق معين
  Stream<List<DailyRoute>> getDriverRoutes(String driverId) {
    return _db.child('daily_routes').orderByChild('driver_id').equalTo(driverId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) => DailyRoute.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
    });
  }

  // إنشاء خط سير جديد
  Future<String> createRoute(String date, String driverId, String driverName) async {
    final ref = _db.child('daily_routes').push();
    await ref.set({
      'date': date,
      'driver_id': driverId,
      'driver_name': driverName,
      'is_published': false,
      'status': 'draft',
      'created_at': ServerValue.timestamp,
    });
    return ref.key!;
  }

  // نشر خط السير
  Future<void> publishRoute(String routeId) async {
    await _db.child('daily_routes').child(routeId).update({'is_published': true});
  }

  // جلب عملاء خط السير
  Stream<List<RouteStop>> getRouteStops(String routeId) {
    return _db.child('route_stops').orderByChild('route_id').equalTo(routeId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      final list = data.entries.map((e) => RouteStop.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return list;
    });
  }

  // إضافة عميل لخط السير
  Future<void> addStopToRoute(String routeId, Customer customer, int index) async {
    await _db.child('route_stops').push().set({
      'route_id': routeId,
      'customer_id': customer.id,
      'customer_name': customer.name,
      'customer_phone': customer.phone,
      'order_index': index,
      'status': 'pending',
      'collected_amount': 0.0,
      'required_amount': 0.0,
    });
  }

  // تسجيل تحصيل وتحديث حالة الزيارة
  Future<void> recordCollection(String stopId, double amount, String status) async {
    await _db.child('route_stops').child(stopId).update({
      'collected_amount': amount,
      'status': status,
      'updated_at': ServerValue.timestamp,
    });
    
    // إضافة سجل تحصيل مستقل (للأرشيف)
    await _db.child('collections').push().set({
      'stop_id': stopId,
      'amount': amount,
      'timestamp': ServerValue.timestamp,
    });
  }
}
