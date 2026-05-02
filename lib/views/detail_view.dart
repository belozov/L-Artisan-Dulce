import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product_model.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../widgets/tactile_wrapper.dart';

class DetailView extends StatefulWidget {
  final Product product;
  const DetailView({super.key, required this.product});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> with TickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleFav(FavoritesViewModel favVM) {
    final wasFav = favVM.isFavorite(widget.product.id);
    favVM.toggleFavorite(widget.product.id);
    if (!wasFav) {
      _heartController.forward(from: 0);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} added to favorites ❤️'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.toastBg,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final favVM = context.watch<FavoritesViewModel>();
    final isFav = favVM.isFavorite(product.id);

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: TactileWrapper(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TactileWrapper(
              onTap: () => _showShareSheet(context, product),
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.share_outlined, size: 18, color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(product),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _buildProductInfo(product),
                  ),
                  if (product.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _buildDescription(product),
                    ),
                  if (product.ingredients.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _buildIngredients(product),
                    ),
                  if (product.nutrition.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _buildNutrition(product),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: _buildQuantitySelector(),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(product, isFav),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Share this treat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareIcon(ctx, Icons.message, 'Message', product),
                _shareIcon(ctx, Icons.copy, 'Copy Link', product),
                _shareIcon(ctx, Icons.mail_outline, 'Email', product),
                _shareIcon(ctx, Icons.more_horiz, 'More', product),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _shareIcon(BuildContext ctx, IconData icon, String label, Product product) {
    return TactileWrapper(
      onTap: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shared "${product.name}" via $label'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.toastBg,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryPink),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildHeroImage(Product product) {
    return Container(
      height: 340,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.heroGradientTop, AppColors.heroGradientBottom],
        ),
      ),
      child: Center(
        child: Hero(
          tag: 'product_${product.id}',
          child: Image.network(
            product.imageUrl,
            height: 220,
            width: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, a, b) => Container(
              height: 220, width: 220,
              decoration: BoxDecoration(
                color: AppColors.lightPink,
                borderRadius: BorderRadius.circular(110),
              ),
              child: const Icon(Icons.cake, size: 80, color: AppColors.accentPink),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(product.priceUnit,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        if (product.rating > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: AppColors.ratingGold),
              const SizedBox(width: 4),
              Text('${product.rating} (${product.reviewCount} reviews)',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('THE EXPERIENCE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Text(product.description,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
      ],
    );
  }

  Widget _buildIngredients(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.ingredientBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.restaurant_menu, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text('Ingredients', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 12),
          ...product.ingredients.map((ing) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ing.name, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                    Text(ing.quality, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNutrition(Product product) {
    final entries = product.nutrition.entries.toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.nutritionBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.local_fire_department_outlined, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text('Nutrition', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.5,
            ),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(entries[i].key,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
                    Text(entries[i].value,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.lightPink, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Quantity',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Row(
            children: [
              TactileWrapper(
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.accentPink, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.remove, size: 18, color: Colors.white),
                ),
              ),
              SizedBox(
                width: 48,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '$_quantity',
                      key: ValueKey(_quantity),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
              TactileWrapper(
                onTap: () {
                  if (_quantity < 99) setState(() => _quantity++);
                },
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primaryPink, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Product product, bool isFav) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          TactileWrapper(
            onTap: () => _toggleFav(context.read<FavoritesViewModel>()),
            child: ScaleTransition(
              scale: _heartScale,
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.heartRed : AppColors.textTertiary,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TactileWrapper(
              onTap: () {
                final cartVM = context.read<CartViewModel>();
                cartVM.addToCart(product, _quantity);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $_quantity × ${product.name} to cart'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.toastBg,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryPink, AppColors.accentPink]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryPink.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Order Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
