import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static BoxDecoration cardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    bool hasHover = false,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: border ?? Border.all(color: AppColors.border, width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: hasHover ? 0.08 : 0.04),
          offset: hasHover ? const Offset(0, 8) : const Offset(0, 2),
          blurRadius: hasHover ? 16 : 6,
          spreadRadius: 0,
        ),
      ],
    );
  }

  static BoxDecoration badgeDecoration({
    required Color bgColor,
    required Color borderColor,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
    );
  }

  static BoxDecoration inputDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border, width: 1),
    );
  }
}
