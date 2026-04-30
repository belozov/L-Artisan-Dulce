import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/tactile_wrapper.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final activeOrders = state.activeOrders;
    final history = state.orderHistory;

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

        _summaryCard(state),

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
          _emptyActiveCard(context, state)
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

  Widget _summaryCard(AppState state) {
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
            value: '${state.activeOrders.length}',
          ),
          Container(width: 1, height: 44, color: AppColors.divider),
          _summaryItem(
            icon: Icons.history,
            title: 'History',
            value: '${state.orderHistory.length}',
          ),
          Container(width: 1, height: 44, color: AppColors.divider),
          _summaryItem(
            icon: Icons.shopping_cart_outlined,
            title: 'Cart',
            value: '${state.cartItemCount}',
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

  Widget _emptyActiveCard(BuildContext context, AppState state) {
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
            state.cartItemCount > 0
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
            onTap: () => state.switchTab(1),
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
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _statusBadge(order),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              order.date,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            if (isActive) ...[const SizedBox(height: 18), _progressBar(order)],
            const SizedBox(height: 18),
            ...order.items
                .take(2)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            if (order.items.length > 2)
              Text(
                '+${order.items.length - 2} more items',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Text(
                  'View details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPink,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.accentPink,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(OrderRecord order) {
    final bool isActive =
        order.status == OrderStatus.preparing ||
        order.status == OrderStatus.onTheWay;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPink : AppColors.lightPink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        order.statusLabel,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _progressBar(OrderRecord order) {
    double progress = 0.35;

    if (order.status == OrderStatus.onTheWay) {
      progress = 0.75;
    }

    if (order.status == OrderStatus.delivered) {
      progress = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.lightPink,
            valueColor: const AlwaysStoppedAnimation(AppColors.accentPink),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(
              child: Text(
                'Preparing',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
            Expanded(
              child: Text(
                'On the way',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
            Expanded(
              child: Text(
                'Delivered',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showOrderDetails(BuildContext context, OrderRecord order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _statusBadge(order),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  order.date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cake_outlined,
                          color: AppColors.accentPink,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 28, color: AppColors.divider),

                Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentPink,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Order information is stored in Firebase Firestore and loaded for the current signed-in user.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
