import 'package:firebase_database/firebase_database.dart';
import '../models/daily_route.dart';
import '../models/route_stop.dart';
import '../models/customer.dart';

class RouteService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Stream<List<DailyRoute>> getAllRoutes() {
    return _db.child('daily_routes').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      final list = data.entries.map((e) => DailyRoute.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Stream<List<DailyRoute>> getDriverRoutes(String driverId) {
    return _db.child('daily_routes').orderByChild('driver_id').equalTo(driverId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) => DailyRoute.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
    });
  }

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

  Future<void> publishRoute(String routeId) async {
    await _db.child('daily_routes').child(routeId).update({'is_published': true});
  }

  Future<void> completeRoute(String routeId) async {
    await _db.child('daily_routes').child(routeId).update({'status': 'completed'});
  }

  Future<void> deleteRoute(String routeId) async {
    await _db.child('daily_routes').child(routeId).remove();
    final stopsSnap = await _db.child('route_stops').orderByChild('route_id').equalTo(routeId).get();
    if (stopsSnap.exists) {
      final data = stopsSnap.value as Map;
      for (var key in data.keys) {
        await _db.child('route_stops').child(key).remove();
      }
    }
  }

  Stream<List<RouteStop>> getRouteStops(String routeId) {
    return _db.child('route_stops').orderByChild('route_id').equalTo(routeId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      final list = data.entries.map((e) => RouteStop.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return list;
    });
  }

  Future<void> addStopToRoute(String routeId, Customer customer, int index) async {
    await _db.child('route_stops').push().set({
      'route_id': routeId,
      'customer_id': customer.id,
      'customer_name': customer.name,
      'customer_phone': customer.phone,
      'customer_address': customer.address,
      'order_index': index,
      'status': 'pending',
      'collected_amount': 0.0,
      'order_items': {},
    });
  }

  Future<void> updateOrderItems(String stopId, List<Map<String, dynamic>> items) async {
    final itemsMap = { for (var item in items) DateTime.now().microsecondsSinceEpoch.toString() + item['productId'] : item };
    await _db.child('route_stops').child(stopId).update({'order_items': itemsMap});
  }

  // هنا التعديل المهم: بناخد بيانات العميل ونحفظها في التحصيل
  Future<void> recordCollection(RouteStop stop, double amount, String status) async {
    await _db.child('route_stops').child(stop.id).update({
      'collected_amount': amount,
      'status': status,
      'updated_at': ServerValue.timestamp,
    });
    
    await _db.child('collections').push().set({
      'stop_id': stop.id,
      'customer_name': stop.customerName, // حفظنا الاسم
      'customer_phone': stop.customerPhone, // حفظنا الرقم
      'customer_address': stop.customerAddress, // حفظنا العنوان
      'amount': amount,
      'timestamp': ServerValue.timestamp,
    });
  }
}
