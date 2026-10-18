import 'package:firebase_database/firebase_database.dart';
import '../models/product.dart';

class ProductService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('products');

  Stream<List<Product>> getProducts() {
    return _db.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) => Product.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
    });
  }

  Future<void> addProduct(Product product) async {
    await _db.push().set({
      ...product.toMap(),
      'created_at': ServerValue.timestamp,
    });
  }

  Future<void> updateProduct(Product product) async {
    await _db.child(product.id).update({
      ...product.toMap(),
      'updated_at': ServerValue.timestamp,
    });
  }

  Future<void> deleteProduct(String id) async {
    await _db.child(id).remove();
  }
}
