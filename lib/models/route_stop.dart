class RouteStop {
  final String id;
  final String routeId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final int orderIndex;
  final String status;
  final double collectedAmount;
  final double requiredAmount;

  RouteStop({
    required this.id,
    required this.routeId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.orderIndex,
    required this.status,
    required this.collectedAmount,
    required this.requiredAmount,
  });

  factory RouteStop.fromMap(String id, Map<dynamic, dynamic> map) {
    return RouteStop(
      id: id,
      routeId: map['route_id'] ?? '',
      customerId: map['customer_id'] ?? '',
      customerName: map['customer_name'] ?? '',
      customerPhone: map['customer_phone'] ?? '',
      orderIndex: map['order_index'] ?? 0,
      status: map['status'] ?? 'pending',
      collectedAmount: (map['collected_amount'] ?? 0).toDouble(),
      requiredAmount: (map['required_amount'] ?? 0).toDouble(),
    );
  }
}
