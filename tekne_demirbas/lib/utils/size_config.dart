import 'package:flutter/material.dart';

class SizeConfig {
  static double screenHeight = 0.0;
  static double screenWidth = 0.0;
  static double shortestSide = 0.0;

  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    screenWidth = size.width;
    screenHeight = size.height;
    shortestSide = size.shortestSide;
  }

  /// iPad / büyük tablet (Material breakpoint).
  static bool get isTablet => shortestSide >= 600;

  /// Telefon layout'u korunur; tablet'te bileşenler ~%25 büyür.
  static double get uiScale {
    if (!isTablet) return 1.0;
    return 1.25;
  }

  static double sp(double size) => size * uiScale;

  /// Top bar: sadece yükseklik artar (genişlik aynı layout).
  static double get toolbarHeight =>
      isTablet ? kToolbarHeight * 1.4 : kToolbarHeight;

  static double get bottomNavHeight => isTablet ? 78.0 : 56.0;

  static double get iconSm => sp(20);

  static double get iconMd => sp(24);

  static double get iconLg => sp(28);

  static double get buttonHeight =>
      isTablet ? getProportionateHeight(56) : getProportionateHeight(50);

  /// Telefon: ekran yüksekliğine oranla. Tablet: sabit boyut × uiScale
  /// (tam ekran oranlaması iPad'de yazıları/padding'i aşırı bozmasın).
  static double getProportionateHeight(double inputHeight) {
    if (isTablet) return inputHeight * uiScale;
    if (screenHeight <= 0) return inputHeight;
    return (inputHeight / 812) * screenHeight;
  }

  static double getProportionateWidth(double inputWidth) {
    if (isTablet) return inputWidth * uiScale;
    if (screenWidth <= 0) return inputWidth;
    return (inputWidth / 375) * screenWidth;
  }
}
