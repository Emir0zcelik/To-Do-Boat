import 'dart:math' as math;

import 'package:flutter/material.dart';

class SizeConfig {
  static double screenHeight = 0.0;
  static double screenWidth = 0.0;
  static double shortestSide = 0.0;

  /// iPad / tablet eşiği (Material compact/medium).
  static const double tabletBreakpoint = 600;
  static const double formMaxWidth = 520;
  static const double contentMaxWidth = 760;
  static const double wideContentMaxWidth = 1000;
  static const double dialogMaxWidth = 560;

  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    screenWidth = size.width;
    screenHeight = size.height;
    shortestSide = size.shortestSide;
  }

  static bool get isTablet => shortestSide >= tabletBreakpoint;

  static bool isTabletOf(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;

  static double contentWidthOf(
    BuildContext context, {
    double maxWidth = contentMaxWidth,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    return math.min(width, maxWidth);
  }

  static EdgeInsets pagePaddingOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint) {
      final horizontal = math.max(24.0, (width - contentMaxWidth) / 2);
      return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  static double getProportionateHeight(double inputHeight) {
    if (screenHeight <= 0) return inputHeight;
    final scaled = (inputHeight / 812) * screenHeight;
    // Tablette font/spacing şişmesin diye sınırla
    if (isTablet) {
      return scaled.clamp(inputHeight * 0.9, inputHeight * 1.15);
    }
    return scaled;
  }

  static double getProportionateWidth(double inputWidth) {
    if (screenWidth <= 0) return inputWidth;
    final scaled = (inputWidth / 375) * screenWidth;
    if (isTablet) {
      return scaled.clamp(inputWidth * 0.9, inputWidth * 1.2);
    }
    return scaled;
  }
}

/// Form / liste içeriğini ortalayıp max genişlikle sınırlar.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = SizeConfig.contentMaxWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
