import 'package:flutter/material.dart';

class Responsive {
  // 📏 Width & Height
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // 📱 Device types
  static bool isSmallPhone(BuildContext context) {
    return width(context) < 360;
  }

  static bool isPhone(BuildContext context) {
    return width(context) >= 360 && width(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return width(context) >= 600;
  }

  // 📐 Padding
  static double horizontalPadding(BuildContext context) {
    if (isTablet(context)) return 48;
    if (isSmallPhone(context)) return 14;
    return 20;
  }

  static double verticalPadding(BuildContext context) {
    if (isTablet(context)) return 24;
    return 16;
  }

  // 🔤 Font sizes
  static double titleFontSize(BuildContext context) {
    if (isTablet(context)) return 30;
    if (isSmallPhone(context)) return 22;
    return 26;
  }

  static double sectionTitleFontSize(BuildContext context) {
    if (isTablet(context)) return 20;
    return 16;
  }

  static double bodyFontSize(BuildContext context) {
    if (isTablet(context)) return 16;
    return 14;
  }

  // 🧱 Grid
  static int productGridCount(BuildContext context) {
    if (width(context) >= 900) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double productAspectRatio(BuildContext context) {
    if (isSmallPhone(context)) return 0.85;
    if (isTablet(context)) return 0.9;
    return 0.95;
  }

  // 👤 Avatar sizes
  static double avatarSize(BuildContext context) {
    if (isTablet(context)) return 56;
    return 44;
  }

  static double profileAvatarSize(BuildContext context) {
    if (isTablet(context)) return 120;
    return 96;
  }

  // 📦 Card spacing
  static double cardSpacing(BuildContext context) {
    if (isTablet(context)) return 20;
    return 16;
  }

  // 📊 General scale (optional)
  static double scale(BuildContext context) {
    final w = width(context);
    if (w >= 900) return 1.3;
    if (w >= 600) return 1.15;
    if (w < 360) return 0.9;
    return 1.0;
  }
}
