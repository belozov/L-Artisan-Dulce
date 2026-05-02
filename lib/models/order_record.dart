enum OrderStatus { preparing, onTheWay, delivered, cancelled }

class OrderRecord {
  final String id;
  final String date;
  final List<String> items;
  final double total;
  final OrderStatus status;

  const OrderRecord({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
