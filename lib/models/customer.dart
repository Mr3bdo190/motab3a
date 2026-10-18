class Customer {
  final String id;
  final String name;
  final String code;
  final String phone;
  final String area;
  final String address;
  final bool isActive;

  Customer({
    required this.id,
    required this.name,
    required this.code,
    required this.phone,
    required this.area,
    required this.address,
    required this.isActive,
  });

  factory Customer.fromMap(String id, Map<dynamic, dynamic> map) {
    return Customer(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      phone: map['phone'] ?? '',
      area: map['area'] ?? '',
      address: map['address'] ?? '',
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'phone': phone,
      'area': area,
      'address': address,
      'is_active': isActive,
    };
  }
}
