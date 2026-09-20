import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';


class SourcePlaceholder extends StatelessWidget {
  final String sourceName;
  final double? height;
  final double? width;

  const SourcePlaceholder({
    super.key,
    required this.sourceName,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final String initial = sourceName.trim().isNotEmpty
        ? sourceName.trim().substring(0, 1).toUpperCase()
        : 'K';

    return Container(
      height: height ?? double.infinity,
      width: width ?? double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDim,
      ),
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: GoogleFonts.merriweather(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}