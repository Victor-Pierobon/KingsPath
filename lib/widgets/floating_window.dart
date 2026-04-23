import 'dart:math' show min;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FloatingWindow extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const FloatingWindow({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = width != null ? min(width!, screenWidth - 16) : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: effectiveWidth,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A1A).withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.55), width: 1),
            boxShadow: AppColors.borderGlow,
          ),
          child: child,
        ),
      ),
    );
  }
}
