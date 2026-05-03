import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/navigation_viewmodel.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/fade_slide_animation.dart';

import '../theme/app_colors.dart';
import '../widgets/tactile_wrapper.dart';

import 'favorites_page.dart';
import 'payment_page.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    final ordersVM = context.watch<OrdersViewModel>();
    final favVM = context.watch<FavoritesViewModel>();
    final navVM = context.watch<NavigationViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),

          FadeSlideAnimation(index: 0, child: _buildHeader(context)),

          const SizedBox(height: 24),

          FadeSlideAnimation(index: 1, child: _buildStats(context)),

          const SizedBox(height: 24),

          FadeSlideAnimation(
            index: 2,
            child: _section('My Orders', [
              _item(
                Icons.shopping_bag_outlined,
                'Active Orders',
                trailing: ordersVM.activeOrders.isNotEmpty
                    ? _badge('${ordersVM.activeOrders.length}')
                    : null,
                onTap: () => navVM.switchTab(2),
              ),
              _item(
                Icons.history,
                'Order History',
                onTap: () => navVM.switchTab(2),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          FadeSlideAnimation(
            index: 3,
            child: _section('Preferences', [
              _item(
                Icons.favorite_border,
                'Favorites',
                trailing: favVM.favoriteCount > 0
                    ? _badge('${favVM.favoriteCount}')
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesPage()),
                  );
                },
              ),
              _item(
                Icons.location_on_outlined,
                'Delivery Address',
                subtitle: profileVM.deliveryAddress,
                onTap: () => _editAddress(context),
              ),
              _item(
                Icons.credit_card_outlined,
                'Payment Methods',
                subtitle: profileVM.paymentDisplay,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentPage()),
                  );
                },
              ),
              _item(
                Icons.notifications_none,
                'Notifications',
                trailing: _toggle(profileVM.notificationsEnabled),
                onTap: () {
                  profileVM.toggleNotifications();
                  _snack(
                    context,
                    'Notifications ${profileVM.notificationsEnabled ? 'enabled' : 'disabled'}',
                  );
                },
              ),
            ]),
          ),

          const SizedBox(height: 16),

          FadeSlideAnimation(
            index: 4,
            child: _section('About', [
              _item(
                Icons.info_outline,
                "About L'Artisan Dulce",
                onTap: () => _showAbout(context),
              ),
              _item(
                Icons.help_outline,
                'Help & Support',
                onTap: () => _showHelp(context),
              ),
              _item(
                Icons.star_border,
                'Rate the App',
                onTap: () => _showRating(context),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          FadeSlideAnimation(
            index: 5,
            child: TactileWrapper(
              onTap: () => _confirmSignOut(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.heartRed.withValues(alpha: 0.3),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.heartRed,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.heroGradientTop, AppColors.accentPink],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: profileVM.profilePhotoPath.isNotEmpty
                    ? Image.file(
                        File(profileVM.profilePhotoPath),
                        key: ValueKey(profileVM.profilePhotoPath),
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            profileVM.userInitials,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          profileVM.userInitials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: TactileWrapper(
                onTap: () => _showPhotoPicker(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profileVM.userName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        TactileWrapper(
          onTap: () => _editProfile(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profileVM.userEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.lightPink,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 12,
                  color: AppColors.primaryPink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final favVM = context.watch<FavoritesViewModel>();
    final ordersVM = context.watch<OrdersViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat(
            Icons.shopping_bag_outlined,
            '${cartVM.cartItemCount}',
            'In Cart',
          ),
          Container(width: 1, height: 40, color: AppColors.accentPink),
          _stat(Icons.favorite_border, '${favVM.favoriteCount}', 'Favorites'),
          Container(width: 1, height: 40, color: AppColors.accentPink),
          _stat(
            Icons.receipt_long_outlined,
            '${ordersVM.orderHistory.length + ordersVM.activeOrders.length}',
            'Orders',
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryPink),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 1,
              ),
            ),
          ),
          ...children.asMap().entries.map(
            (e) => Column(
              children: [
                e.value,
                if (e.key < children.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 1, color: AppColors.divider),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String label, {
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return TactileWrapper(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.lightPink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primaryPink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryPink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _toggle(bool value) {
    return Container(
      width: 44,
      height: 26,
      decoration: BoxDecoration(
        color: value ? AppColors.primaryPink : AppColors.divider,
        borderRadius: BorderRadius.circular(13),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _showPhotoPicker(BuildContext context) {
    final profileVM = context.read<ProfileViewModel>();
    final picker = ImagePicker();

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
            _handle(),
            const SizedBox(height: 20),
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _photoOption(ctx, Icons.camera_alt, 'Take Photo', () async {
              Navigator.pop(ctx);
              final image = await picker.pickImage(
                source: ImageSource.camera,
                maxWidth: 512,
                imageQuality: 80,
              );
              if (image != null) {
                await profileVM.setProfilePhoto(image.path);
                if (context.mounted) {
                  _snack(context, 'Profile photo updated');
                }
              }
            }),
            _photoOption(
              ctx,
              Icons.photo_library,
              'Choose from Gallery',
              () async {
                Navigator.pop(ctx);
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  imageQuality: 80,
                );
                if (image != null) {
                  await profileVM.setProfilePhoto(image.path);
                  if (context.mounted) {
                    _snack(context, 'Profile photo updated');
                  }
                }
              },
            ),
            if (profileVM.profilePhotoPath.isNotEmpty)
              _photoOption(ctx, Icons.delete_outline, 'Remove Photo', () async {
                Navigator.pop(ctx);
                await profileVM.removeProfilePhoto();
                if (context.mounted) {
                  _snack(context, 'Profile photo removed');
                }
              }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(
    BuildContext ctx,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return TactileWrapper(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primaryPink),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    final profileVM = context.read<ProfileViewModel>();
    final nameCtrl = TextEditingController(text: profileVM.userName);
    final emailCtrl = TextEditingController(text: profileVM.userEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            const SizedBox(height: 20),
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _field('Name', nameCtrl),
            const SizedBox(height: 12),
            _field('Email', emailCtrl, type: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _primaryButton('Save Changes', () async {
              await profileVM.updateProfile(
                name: nameCtrl.text,
                email: emailCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) _snack(context, 'Profile updated');
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _editAddress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer<ProfileViewModel>(
        builder: (context, profileVM, _) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _handle(),
                const SizedBox(height: 20),

                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 20),

                // 📍 ПОКАЗЫВАЕМ АДРЕС
                if (profileVM.deliveryAddress.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.lightPink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      profileVM.deliveryAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // 🔥 КНОПКА GPS
                TactileWrapper(
                  onTap: profileVM.isGettingLocation
                      ? () {}
                      : () async {
                          await profileVM.useCurrentLocationAsAddress();

                          if (context.mounted) {
                            _snack(context, 'Address updated from GPS');
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryPink, AppColors.accentPink],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: profileVM.isGettingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.my_location,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Get My Location',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 💾 СОХРАНИТЬ
                if (profileVM.deliveryAddress.isNotEmpty)
                  _primaryButton('Save Address', () async {
                    await profileVM.updateDeliveryAddress(
                      profileVM.deliveryAddress,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      _snack(context, 'Address saved');
                    }
                  }),

                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showHelp(BuildContext context) {
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
            _handle(),
            const SizedBox(height: 20),
            const Text(
              'Help & Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _sheetOption(ctx, Icons.chat_bubble_outline, 'Live Chat'),
            _sheetOption(ctx, Icons.email_outlined, 'Email Support'),
            _sheetOption(ctx, Icons.phone_outlined, 'Call Us'),
            _sheetOption(ctx, Icons.description_outlined, 'FAQ'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRating(BuildContext context) {
    int rating = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Rate L'Artisan Dulce",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How was your experience?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => TactileWrapper(
                    onTap: () => setLocal(() => rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        size: 36,
                        color: AppColors.ratingGold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),
            ElevatedButton(
              onPressed: rating > 0
                  ? () {
                      Navigator.pop(ctx);
                      _snack(context, 'Thanks for rating us $rating stars!');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "L'Artisan Dulce",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Handcrafted confections made with the finest ingredients.\n\n'
          'Every macaron, every pastry, every chocolate - a small work of art, created with passion in our atelier.\n\n'
          'Inspired by French pâtisserie traditions.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryPink),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final authVM = context.read<AuthViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authVM.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.heartRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.lightPink,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryPink),
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return TactileWrapper(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryPink, AppColors.accentPink],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetOption(BuildContext ctx, IconData icon, String label) {
    return TactileWrapper(
      onTap: () {
        Navigator.pop(ctx);
        _snack(ctx, '$label selected');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primaryPink),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.toastBg,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
