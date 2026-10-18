class Product {
  final String id;
  final String name;
  final String code;
  final String unit;
  final double price;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.unit,
    required this.price,
    required this.isActive,
  });

  factory Product.fromMap(String id, Map<dynamic, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      unit: map['unit'] ?? 'قطعة',
      price: (map['price'] ?? 0).toDouble(),
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'unit': unit,
      'price': price,
      'is_active': isActive,
    };
  }
}
