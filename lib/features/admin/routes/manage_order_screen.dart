import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/theme/app_theme.dart';

class ManageOrderScreen extends StatefulWidget {
  final String stopId;
  final List<Map<String, dynamic>> existingItems;
  const ManageOrderScreen({super.key, required this.stopId, required this.existingItems});

  @override
  State<ManageOrderScreen> createState() => _ManageOrderScreenState();
}

class _ManageOrderScreenState extends State<ManageOrderScreen> {
  List<Map<String, dynamic>> _items = [];
  Map<String, Map<dynamic, dynamic>> _products = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.existingItems);
    _loadProducts();
  }

  void _loadProducts() async {
    final snap = await FirebaseDatabase.instance.ref('products').get();
    if (snap.exists) {
      final data = snap.value as Map;
      for(var e in data.entries) { _products[e.key] = e.value; }
    }
    setState(() => _isLoading = false);
  }

  void _addProduct(String id, String name, double price) {
    setState(() {
      final index = _items.indexWhere((element) => element['productId'] == id);
      if (index >= 0) {
        _items[index]['quantity'] = (_items[index]['quantity'] as int) + 1;
      } else {
        _items.add({'productId': id, 'name': name, 'price': price, 'quantity': 1});
      }
    });
  }

  void _removeProduct(int index) {
    setState(() {
      if (_items[index]['quantity'] > 1) {
        _items[index]['quantity'] = (_items[index]['quantity'] as int) - 1;
      } else {
        _items.removeAt(index);
      }
    });
  }

  void _save() async {
    double totalRequired = 0;
    for (var item in _items) {
      totalRequired += (item['price'] as double) * (item['quantity'] as int);
    }

    final itemsMap = { for (var item in _items) DateTime.now().microsecondsSinceEpoch.toString() + item['productId'].toString() : item };
    await FirebaseDatabase.instance.ref('route_stops').child(widget.stopId).update({
      'order_items': itemsMap,
      'required_amount': totalRequired,
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double currentTotal = 0;
    for (var item in _items) { currentTotal += (item['price'] as double) * (item['quantity'] as int); }

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('المنتجات المتاحة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ..._products.entries.map((e) => Card(
                  child: ListTile(
                    title: Text(e.value['name']),
                    subtitle: Text('${e.value['price']} ج.م'),
                    trailing: IconButton(icon: const Icon(Icons.add_circle, color: AppTheme.success), onPressed: () => _addProduct(e.key, e.value['name'], (e.value['price']).toDouble())),
                  ),
                ))
              ],
            ),
          ),
          const Divider(thickness: 2),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('الطلب الحالي (الإجمالي: $currentTotal ج.م):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.success)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item['name']),
                        subtitle: Text('${item['price']} ج.م'),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove_circle, color: AppTheme.danger), onPressed: () => _removeProduct(index)),
                            Text('${item['quantity']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _save, child: const Text('حفظ الطلب'))),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
