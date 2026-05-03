import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../models/product_model.dart';
import '../widgets/tactile_wrapper.dart';
import '../widgets/fade_slide_animation.dart';
import '../viewmodels/products_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/navigation_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../utils/responsive.dart';
import 'detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  static const _cardColors = [
    AppColors.cardPeach,
    AppColors.cardLavender,
    AppColors.cardMint,
    AppColors.cardSky,
    AppColors.cardRose,
    AppColors.cardLemon,
  ];

  @override
  Widget build(BuildContext context) {
    final productsVM = context.watch<ProductsViewModel>();

    final products = productsVM.selectedChipIndex == 0
        ? [...kPopularDesserts, ...kExploreProducts]
        : [...kPopularDesserts, ...kExploreProducts]
              .where(
                (p) =>
                    p.category.toLowerCase() ==
                    kFilterChips[productsVM.selectedChipIndex].toLowerCase(),
              )
              .toList();

    final seen = <String>{};
    final deduplicated = products.where((p) {
      if (seen.contains(p.id)) return false;
      seen.add(p.id);
      return true;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FadeSlideAnimation(index: 0, child: _buildHeader(context)),
        ),
        SliverToBoxAdapter(
          child: FadeSlideAnimation(index: 1, child: _buildSearchBar(context)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: FadeSlideAnimation(
            index: 2,
            child: _buildCategories(context, productsVM),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: FadeSlideAnimation(
            index: 3,
            child: _buildPromoBanner(context),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: FadeSlideAnimation(
            index: 4,
            child: _buildPopularHeader(context),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        deduplicated.isEmpty
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No items in this category',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                ),
              )
            : SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.horizontalPadding(context),
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.productGridCount(context),
                    mainAxisSpacing: Responsive.cardSpacing(context),
                    crossAxisSpacing: Responsive.cardSpacing(context),
                    childAspectRatio: Responsive.productAspectRatio(context),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => FadeSlideAnimation(
                      index: i,
                      child: _ProductCard(
                        product: deduplicated[i],
                        bgColor: _cardColors[i % _cardColors.length],
                      ),
                    ),
                    childCount: deduplicated.length,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    final navVM = context.read<NavigationViewModel>();
    final avatarSize = Responsive.avatarSize(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.horizontalPadding(context),
        20,
        Responsive.horizontalPadding(context),
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profileVM.userName} 🍬',
                  style: TextStyle(
                    fontSize: Responsive.titleFontSize(context),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          TactileWrapper(
            onTap: () => navVM.switchTab(3),
            child: Consumer<ProfileViewModel>(
              builder: (context, profileVM, _) {
                final hasPhoto =
                    profileVM.profilePhotoPath.isNotEmpty &&
                    File(profileVM.profilePhotoPath).existsSync();

                return Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasPhoto
                      ? Image.file(
                          File(profileVM.profilePhotoPath),
                          key: ValueKey(profileVM.profilePhotoPath),
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            profileVM.userInitials,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
      ),
      child: TactileWrapper(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const _QuickSearch(),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, size: 20, color: AppColors.textTertiary),
              SizedBox(width: 10),
              Text(
                'Search sweets, cakes...',
                style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, ProductsViewModel productsVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.horizontalPadding(context),
          ),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: Responsive.sectionTitleFontSize(context),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.horizontalPadding(context),
            ),
            itemCount: kFilterChips.length,
            separatorBuilder: (_, a) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final selected = productsVM.selectedChipIndex == i;
              return TactileWrapper(
                onTap: () => productsVM.selectChip(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.chipSelectedBg
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.chipSelectedBg
                          : AppColors.chipBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    kFilterChips[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColors.chipSelectedText
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
      ),
      child: TactileWrapper(
        onTap: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Promo applied! 20% off cakes this week 🎂',
                style: TextStyle(
                  color: AppColors.toastText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppColors.toastBg,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.promoBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIMITED OFFER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.promoAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Birthday Cake Bundle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Get 20% off custom cakes this week',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Order now',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text('🎂', style: TextStyle(fontSize: 56)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Popular picks',
            style: TextStyle(
              fontSize: Responsive.sectionTitleFontSize(context) + 2,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          TactileWrapper(
            onTap: () {
              final navVM = context.read<NavigationViewModel>();
              final productsVM = context.read<ProductsViewModel>();
              productsVM.navigateToExplore();
              navVM.switchTab(1);
            },
            child: Text(
              'See all',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color bgColor;

  const _ProductCard({required this.product, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final cartVM = context.read<CartViewModel>();

    return TactileWrapper(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, a, b) => DetailView(product: product),
            transitionsBuilder: (_, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: Hero(
                  tag: 'product_${product.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, a, b) => Center(
                        child: Text(
                          _productEmoji(product.category),
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TactileWrapper(
                    onTap: () {
                      cartVM.addToCart(product, 1);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.name} added to cart',
                            style: const TextStyle(
                              color: AppColors.toastText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppColors.toastBg,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 18, color: AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _productEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'macarons':
        return '🍪';
      case 'chocolates':
        return '🍫';
      case 'tarts':
        return '🥧';
      case 'croissants':
        return '🥐';
      case 'eclairs':
        return '🧁';
      case 'pastries':
        return '🍰';
      default:
        return '🍬';
    }
  }
}

class _QuickSearch extends StatefulWidget {
  const _QuickSearch();

  @override
  State<_QuickSearch> createState() => _QuickSearchState();
}

class _QuickSearchState extends State<_QuickSearch> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsVM = context.watch<ProductsViewModel>();
    final results = productsVM.searchResults;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Responsive.horizontalPadding(context),
          16,
          Responsive.horizontalPadding(context),
          0,
        ),
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
              controller: _ctrl,
              autofocus: true,
              onChanged: (q) => productsVM.setSearchQuery(q),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search sweets, cakes...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () {
                          _ctrl.clear();
                          productsVM.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        _ctrl.text.isEmpty ? 'Start typing...' : 'No results',
                        style: const TextStyle(color: AppColors.textTertiary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, a) =>
                          const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (_, i) {
                        final p = results[i];
                        return FadeSlideAnimation(
                          index: i,
                          child: TactileWrapper(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailView(product: p),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      p.imageUrl,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, a, b) => Container(
                                        width: 44,
                                        height: 44,
                                        color: AppColors.background,
                                        child: const Icon(
                                          Icons.cake,
                                          color: AppColors.accent,
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
                                          p.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          p.category,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${p.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
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
