import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'favorites_view.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),
            const Expanded(child: FavoritesView()),
          ],
        ),
      ),
    );
  }
}
