import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/tactile_wrapper.dart';

import 'detail_view.dart';
import 'explore_view.dart';
import 'home_view.dart';
import 'orders_view.dart';
import 'payment_page.dart';
import 'profile_view.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final currentIndex = state.currentTabIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: currentIndex == 0 ? null : _buildAppBar(context, state),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildPage(currentIndex),
      ),
      bottomNavigationBar: _buildBottomNav(context, state, currentIndex),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeView(key: ValueKey('home'));
      case 1:
        return const ExploreView(key: ValueKey('explore'));
      case 2:
        return const OrdersView(key: ValueKey('orders'));
      case 3:
        return const ProfileView(key: ValueKey('profile'));
      default:
        return const HomeView(key: ValueKey('home'));
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState state) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: TactileWrapper(
          onTap: () => _showSearch(context, state),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.lightPink.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      title: TactileWrapper(
        onTap: () => state.switchTab(0),
        child: const Text(
          "L'Artisan Dulce",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TactileWrapper(
            onTap: () => _showCart(context, state),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.lightPink.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (state.cartItemCount > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryPink,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${state.cartItemCount}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSearch(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSheet(state: state),
    );
  }

  void _showCart(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final items = state.cartItems;

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
                const SizedBox(height: 24),
                const Text(
                  'Your Cart',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'Cart is empty',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}× ${item.productName}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (items.isNotEmpty) ...[
                  const Divider(height: 32, color: AppColors.divider),

                  Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${state.cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentPink,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  TactileWrapper(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.divider.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.lightPink.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: AppColors.accentPink,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Payment Method',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  state.paymentDisplay,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textTertiary,
                            size: 26,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  TactileWrapper(
                    onTap: () async {
                      Navigator.pop(ctx);

                      await state.createOrder();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Order created successfully'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.toastBg,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPink.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    AppState state,
    int currentIndex,
  ) {
    const items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      _NavItem(icon: Icons.search, activeIcon: Icons.search, label: 'Search'),
      _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Orders',
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = currentIndex == i;

              return TactileWrapper(
                onTap: () => state.switchTab(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryPink.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 24,
                            color: isActive
                                ? AppColors.navActive
                                : AppColors.navInactive,
                          ),
                          if (i == 2 && state.activeOrders.isNotEmpty)
                            Positioned(
                              top: -4,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.heartRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${state.activeOrders.length}',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? AppColors.navActive
                              : AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SearchSheet extends StatefulWidget {
  final AppState state;

  const _SearchSheet({required this.state});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _controller = TextEditingController();
  List<Product> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    widget.state.setSearchQuery(query);
    setState(() {
      _results = widget.state.searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search desserts...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.lightPink,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        _controller.text.isEmpty
                            ? 'Start typing to search...'
                            : 'No results found',
                        style: const TextStyle(color: AppColors.textTertiary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, _a) =>
                          const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, index) {
                        final product = _results[index];

                        return TactileWrapper(
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailView(product: product),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _a, _b) => Container(
                                      width: 50,
                                      height: 50,
                                      color: AppColors.lightPink,
                                      child: const Icon(
                                        Icons.cake,
                                        color: AppColors.accentPink,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        product.category,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
