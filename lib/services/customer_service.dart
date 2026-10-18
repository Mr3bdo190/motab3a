import 'package:firebase_database/firebase_database.dart';
import '../models/customer.dart';

class CustomerService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('customers');

  Stream<List<Customer>> getCustomers() {
    return _db.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) => Customer.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
    });
  }

  Future<void> addCustomer(Customer customer) async {
    await _db.push().set({
      ...customer.toMap(),
      'created_at': ServerValue.timestamp,
    });
  }

  Future<void> deleteCustomer(String id) async {
    await _db.child(id).remove();
  }
}
