import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product_model.dart';
import '../widgets/tactile_wrapper.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/navigation_viewmodel.dart';
import 'detail_view.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final favVM = context.watch<FavoritesViewModel>();
    final favorites = favVM.favoriteProducts;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: AppColors.accentPink),
            const SizedBox(height: 16),
            const Text('No favorites yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Tap the heart on any dessert to save it here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
            const SizedBox(height: 24),
            TactileWrapper(
              onTap: () {
                context.read<NavigationViewModel>().switchTab(1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightPink,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.ctaBorder),
                ),
                child: const Text('Explore Desserts',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryPink)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: favorites.length,
      separatorBuilder: (_, a) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final product = favorites[index];
        return _FavoriteCard(product: product);
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Product product;
  const _FavoriteCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final favVM = context.read<FavoritesViewModel>();

    return TactileWrapper(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailView(product: product)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 24, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.imageUrl,
                width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, a, b) => Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppColors.lightPink, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.cake, color: AppColors.accentPink),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.ratingGold),
                      const SizedBox(width: 4),
                      Text('${product.rating}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            TactileWrapper(
              onTap: () {
                favVM.toggleFavorite(product.id);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} removed from favorites'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.toastBg,
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      textColor: AppColors.accentPink,
                      onPressed: () => favVM.toggleFavorite(product.id),
                    ),
                  ),
                );
              },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.heartRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite, color: AppColors.heartRed, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
