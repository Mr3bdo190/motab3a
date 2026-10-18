class DailyRoute {
  final String id;
  final String date;
  final String driverId;
  final String driverName;
  final bool isPublished;
  final String status;

  DailyRoute({
    required this.id,
    required this.date,
    required this.driverId,
    required this.driverName,
    required this.isPublished,
    required this.status,
  });

  factory DailyRoute.fromMap(String id, Map<dynamic, dynamic> map) {
    return DailyRoute(
      id: id,
      date: map['date'] ?? '',
      driverId: map['driver_id'] ?? '',
      driverName: map['driver_name'] ?? '',
      isPublished: map['is_published'] ?? false,
      status: map['status'] ?? 'draft',
    );
  }
}
