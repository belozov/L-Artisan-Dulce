

class CartItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;
}
