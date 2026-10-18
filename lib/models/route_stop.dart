class RouteStop {
  final String id;
  final String routeId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress; // أضفنا العنوان
  final int orderIndex;
  final String status;
  final double collectedAmount;
  final List<Map<String, dynamic>> orderItems; // أضفنا المنتجات

  RouteStop({
    required this.id,
    required this.routeId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.orderIndex,
    required this.status,
    required this.collectedAmount,
    required this.orderItems,
  });

  factory RouteStop.fromMap(String id, Map<dynamic, dynamic> map) {
    List<Map<String, dynamic>> items = [];
    if (map['order_items'] != null) {
      final rawItems = map['order_items'] as Map<dynamic, dynamic>;
      items = rawItems.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    return RouteStop(
      id: id,
      routeId: map['route_id'] ?? '',
      customerId: map['customer_id'] ?? '',
      customerName: map['customer_name'] ?? '',
      customerPhone: map['customer_phone'] ?? '',
      customerAddress: map['customer_address'] ?? '',
      orderIndex: map['order_index'] ?? 0,
      status: map['status'] ?? 'pending',
      collectedAmount: (map['collected_amount'] ?? 0).toDouble(),
      orderItems: items,
    );
  }
}
