import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_record.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../viewmodels/navigation_viewmodel.dart';

import '../theme/app_colors.dart';
import '../widgets/tactile_wrapper.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersVM = context.watch<OrdersViewModel>();
    final activeOrders = ordersVM.activeOrders;
    final history = ordersVM.orderHistory;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Track your current dessert orders and review previous purchases.',
          style: TextStyle(fontSize: 15, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 28),

        _summaryCard(context),

        const SizedBox(height: 30),

        const Text(
          'Active Orders',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        if (activeOrders.isEmpty)
          _emptyActiveCard(context)
        else
          ...activeOrders.map(
            (order) =>
                _orderCard(context: context, order: order, isActive: true),
          ),

        const SizedBox(height: 30),

        const Text(
          'Order History',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        if (history.isEmpty)
          _emptyHistoryCard()
        else
          ...history.map(
            (order) =>
                _orderCard(context: context, order: order, isActive: false),
          ),
      ],
    );
  }

  Widget _summaryCard(BuildContext context) {
    final ordersVM = context.watch<OrdersViewModel>();
    final cartVM = context.watch<CartViewModel>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Active',
            value: '${ordersVM.activeOrders.length}',
          ),
          Container(width: 1, height: 44, color: AppColors.divider),
          _summaryItem(
            icon: Icons.history,
            title: 'History',
            value: '${ordersVM.orderHistory.length}',
          ),
          Container(width: 1, height: 44, color: AppColors.divider),
          _summaryItem(
            icon: Icons.shopping_cart_outlined,
            title: 'Cart',
            value: '${cartVM.cartItemCount}',
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentPink, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _emptyActiveCard(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: AppColors.accentPink,
          ),
          const SizedBox(height: 14),
          const Text(
            'No active orders right now',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cartVM.cartItemCount > 0
                ? 'You have items in your cart. Open the cart and press Checkout to create an order.'
                : 'Add desserts to your cart and checkout to start tracking your order here.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          TactileWrapper(
            onTap: () => context.read<NavigationViewModel>().switchTab(1),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryPink,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Explore Desserts',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history, size: 42, color: AppColors.accentPink),
          SizedBox(height: 14),
          Text(
            'No order history yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Completed and cancelled orders will appear here after checkout.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard({
    required BuildContext context,
    required OrderRecord order,
    required bool isActive,
  }) {
    return TactileWrapper(
      onTap: () => _showOrderDetails(context, order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
                Text(
                  order.date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              order.items.join(', '),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isActive)
                  Row(
                    children: [
                      const Text(
                        'Track',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentPink,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.accentPink,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderRecord order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => _OrderDetailsSheet(order: order),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.onTheWay:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final OrderRecord order;

  const _OrderDetailsSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final isActive =
        order.status == OrderStatus.preparing ||
        order.status == OrderStatus.onTheWay;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow('Order ID', '#${order.id.substring(0, 8)}'),
                  const SizedBox(height: 16),
                  _buildDetailRow('Date', order.date),
                  const SizedBox(height: 16),
                  _buildDetailRow('Status', order.statusLabel),
                  const SizedBox(height: 32),

                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentPink,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  if (isActive) _buildTracker(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTracker() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _buildTrackStep(
            icon: Icons.receipt_long,
            title: 'Order Placed',
            subtitle: 'We have received your order',
            isCompleted: true,
            isLast: false,
          ),
          _buildTrackStep(
            icon: Icons.cookie,
            title: 'Preparing',
            subtitle: 'Your treats are being prepared',
            isCompleted: order.status == OrderStatus.preparing ||
                order.status == OrderStatus.onTheWay,
            isLast: false,
          ),
          _buildTrackStep(
            icon: Icons.delivery_dining,
            title: 'On the Way',
            subtitle: 'Your order is out for delivery',
            isCompleted: order.status == OrderStatus.onTheWay,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.accentPink : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.accentPink : AppColors.divider,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isCompleted ? Colors.white : AppColors.textTertiary,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted ? AppColors.accentPink : AppColors.divider,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isCompleted
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
