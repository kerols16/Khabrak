import 'package:flutter/material.dart';

class AppResponsive {
  AppResponsive._();

  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Screen horizontal padding
  static const double screenHorizontal = 16.0;

  // Radii
  static const double radiusCard = 16.0;
  static const double radiusButton = 12.0;
  static const double radiusInput = 12.0;
  static const double radiusChip = 999.0;

  static final BorderRadius cardBorderRadius =
      BorderRadius.circular(radiusCard);
  static final BorderRadius buttonBorderRadius =
      BorderRadius.circular(radiusButton);
  static final BorderRadius inputBorderRadius =
      BorderRadius.circular(radiusInput);
  static final BorderRadius chipBorderRadius =
      BorderRadius.circular(radiusChip);

  // Soft ambient card shadow
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
}