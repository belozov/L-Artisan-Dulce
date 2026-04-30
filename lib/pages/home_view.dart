import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product_model.dart';
import '../state/app_state.dart';
import '../widgets/tactile_wrapper.dart';
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
    final state = AppStateProvider.of(context);
    final products = state.selectedChipIndex == 0
        ? [...kPopularDesserts, ...kExploreProducts]
        : [...kPopularDesserts, ...kExploreProducts]
            .where((p) => p.category.toLowerCase() == kFilterChips[state.selectedChipIndex].toLowerCase())
            .toList();

    // Deduplicate
    final seen = <String>{};
    final deduplicated = products.where((p) {
      if (seen.contains(p.id)) return false;
      seen.add(p.id);
      return true;
    }).toList();

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(child: _buildHeader(context, state)),
        // Search
        SliverToBoxAdapter(child: _buildSearchBar(context, state)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Categories
        SliverToBoxAdapter(child: _buildCategories(state)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Promo banner
        SliverToBoxAdapter(child: _buildPromoBanner(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        // Popular picks header
        SliverToBoxAdapter(child: _buildPopularHeader(state)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Grid
        deduplicated.isEmpty
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No items in this category',
                        style: TextStyle(color: AppColors.textTertiary)),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ProductCard(
                      product: deduplicated[i],
                      bgColor: _cardColors[i % _cardColors.length],
                    ),
                    childCount: deduplicated.length,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting(),
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text('${state.userName} 🍬',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
              ],
            ),
          ),
          TactileWrapper(
            onTap: () => state.switchTab(3),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  state.userInitials,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TactileWrapper(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _QuickSearch(state: state),
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
              Text('Search sweets, cakes...',
                  style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kFilterChips.length,
            separatorBuilder: (_, _a) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final selected = state.selectedChipIndex == i;
              return TactileWrapper(
                onTap: () => state.selectChip(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.chipSelectedBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.chipSelectedBg : AppColors.chipBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    kFilterChips[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.chipSelectedText : AppColors.textSecondary,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TactileWrapper(
        onTap: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Promo applied! 20% off cakes this week 🎂',
                style: TextStyle(color: AppColors.toastText, fontWeight: FontWeight.w600)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.toastBg,
          ));
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
                    Text('LIMITED OFFER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.promoAccent,
                          letterSpacing: 1.2,
                        )),
                    const SizedBox(height: 6),
                    const Text('Birthday Cake Bundle',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Get 20% off custom cakes this week',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Order now',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.background)),
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

  Widget _buildPopularHeader(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Popular picks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          TactileWrapper(
            onTap: () => state.navigateToExplore(),
            child: Text('See all',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

// ── Product Card ──

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color bgColor;
  const _ProductCard({required this.product, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    return TactileWrapper(
      onTap: () {
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, _a, _b) => DetailView(product: product),
          transitionsBuilder: (_, anim, _a2, child) => FadeTransition(opacity: anim, child: child),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Hero(
                  tag: 'product_${product.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _a, _b) => Center(
                        child: Text(_productEmoji(product.category), style: const TextStyle(fontSize: 48)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('\$${product.price.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.accent)),
                      ],
                    ),
                  ),
                  TactileWrapper(
                    onTap: () {
                      state.addToCart(product, 1);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${product.name} added to cart',
                            style: const TextStyle(color: AppColors.toastText, fontWeight: FontWeight.w600)),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppColors.toastBg,
                        duration: const Duration(seconds: 2),
                      ));
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
      case 'macarons': return '🍪';
      case 'chocolates': return '🍫';
      case 'tarts': return '🥧';
      case 'croissants': return '🥐';
      case 'eclairs': return '🧁';
      case 'pastries': return '🍰';
      default: return '🍬';
    }
  }
}

// ── Quick Search (reused from app_shell pattern) ──

class _QuickSearch extends StatefulWidget {
  final AppState state;
  const _QuickSearch({required this.state});
  @override
  State<_QuickSearch> createState() => _QuickSearchState();
}

class _QuickSearchState extends State<_QuickSearch> {
  final _ctrl = TextEditingController();
  List<Product> _results = [];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _search(String q) {
    widget.state.setSearchQuery(q);
    setState(() => _results = widget.state.searchResults);
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
        child: Column(children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl, autofocus: true, onChanged: _search,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search sweets, cakes...',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
              suffixIcon: _ctrl.text.isNotEmpty ? IconButton(
                icon: const Icon(Icons.close, size: 20, color: AppColors.textTertiary),
                onPressed: () { _ctrl.clear(); _search(''); },
              ) : null,
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _results.isEmpty
                ? Center(child: Text(
                    _ctrl.text.isEmpty ? 'Start typing...' : 'No results',
                    style: const TextStyle(color: AppColors.textTertiary)))
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, _a) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (_, i) {
                      final p = _results[i];
                      return TactileWrapper(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailView(product: p)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(p.imageUrl, width: 44, height: 44, fit: BoxFit.cover,
                                  errorBuilder: (_, _a, _b) => Container(width: 44, height: 44, color: AppColors.background,
                                      child: const Icon(Icons.cake, color: AppColors.accent))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              Text(p.category, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ])),
                            Text('\$${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ]),
                        ),
                      );
                    }),
          ),
        ]),
      ),
    );
  }
}
