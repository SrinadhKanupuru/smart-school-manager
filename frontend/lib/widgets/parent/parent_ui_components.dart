import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens specific to Parent Portal
class ParentDesignTokens {
  // Brand & Accent Colors
  static const Color brand = Color(0xFF1E40AF); // Enterprise Deep Royal Blue
  static const Color brandLight = Color(0xFF3B82F6);
  static const Color brandTint = Color(0xFFEFF6FF); // #EFF6FF
  
  // Warm Primary Accent (Parent Warmth & Care)
  static const Color warmAccent = Color(0xFFD97706); // Amber Ochre
  static const Color warmAccentDark = Color(0xFFB45309);
  static const Color warmAccentLight = Color(0xFFFEF3C7);
  static const Color warmAccentBorder = Color(0xFFFDE68A);

  // Status & Categorical Tints
  static const Color emerald = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFFECFDF5);
  static const Color emeraldBorder = Color(0xFFA7F3D0);

  static const Color rose = Color(0xFFE11D48);
  static const Color roseLight = Color(0xFFFFF1F2);
  static const Color roseBorder = Color(0xFFFECDD3);

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFF5F3FF);
  static const Color purpleBorder = Color(0xFFDDD6FE);

  static const Color sky = Color(0xFF0284C7);
  static const Color skyLight = Color(0xFFF0F9FF);
  static const Color skyBorder = Color(0xFFBAE6FD);

  // Neutral Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Border Radii
  static final BorderRadius radiusSm = BorderRadius.circular(8);
  static final BorderRadius radiusMd = BorderRadius.circular(12);
  static final BorderRadius radiusLg = BorderRadius.circular(16);
  static final BorderRadius radiusXl = BorderRadius.circular(20);

  // Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowHover => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Standard Parent Portal Card with stable hover
class ParentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final BorderRadius? borderRadius;
  final bool enableHover;

  const ParentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.enableHover = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widgetBorderRadius(borderRadius);
    final isClickable = onTap != null;

    Widget cardContent = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? ParentDesignTokens.surface,
        borderRadius: effectiveRadius,
        border: border ?? Border.all(color: ParentDesignTokens.border),
        boxShadow: ParentDesignTokens.shadowSm,
      ),
      child: child,
    );

    if (isClickable) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          hoverColor: ParentDesignTokens.surfaceHover,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  static BorderRadius widgetBorderRadius(BorderRadius? r) => r ?? ParentDesignTokens.radiusLg;
}

/// Status and category badge pill
class ParentBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const ParentBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  factory ParentBadge.success({required String label, IconData? icon}) {
    return ParentBadge(
      label: label,
      color: ParentDesignTokens.emerald,
      backgroundColor: ParentDesignTokens.emeraldLight,
      borderColor: ParentDesignTokens.emeraldBorder,
      icon: icon ?? Icons.check_circle_rounded,
    );
  }

  factory ParentBadge.warning({required String label, IconData? icon}) {
    return ParentBadge(
      label: label,
      color: ParentDesignTokens.warmAccentDark,
      backgroundColor: ParentDesignTokens.warmAccentLight,
      borderColor: ParentDesignTokens.warmAccentBorder,
      icon: icon ?? Icons.schedule_rounded,
    );
  }

  factory ParentBadge.danger({required String label, IconData? icon}) {
    return ParentBadge(
      label: label,
      color: ParentDesignTokens.rose,
      backgroundColor: ParentDesignTokens.roseLight,
      borderColor: ParentDesignTokens.roseBorder,
      icon: icon ?? Icons.error_outline_rounded,
    );
  }

  factory ParentBadge.info({required String label, IconData? icon}) {
    return ParentBadge(
      label: label,
      color: ParentDesignTokens.brand,
      backgroundColor: ParentDesignTokens.brandTint,
      borderColor: const Color(0xFFBFDBFE),
      icon: icon,
    );
  }

  factory ParentBadge.neutral({required String label, IconData? icon}) {
    return ParentBadge(
      label: label,
      color: ParentDesignTokens.textSecondary,
      backgroundColor: ParentDesignTokens.surfaceMuted,
      borderColor: ParentDesignTokens.border,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fg = color ?? ParentDesignTokens.brand;
    final bg = backgroundColor ?? ParentDesignTokens.brandTint;
    final bc = borderColor ?? fg.withValues(alpha: 0.25);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: bc),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Header with standardized typography and optional trailing widget
class ParentSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;

  const ParentSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: ParentDesignTokens.warmAccentLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: ParentDesignTokens.warmAccentDark),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: ParentDesignTokens.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: ParentDesignTokens.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Staggered Entrance Container
class ParentAnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final double slideOffset;

  const ParentAnimatedEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 320),
    this.slideOffset = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Standard Empty State Component
class ParentEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color iconColor;

  const ParentEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.iconColor = const Color(0xFF94A3B8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ParentDesignTokens.surface,
        borderRadius: ParentDesignTokens.radiusLg,
        border: Border.all(color: ParentDesignTokens.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: iconColor),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ParentDesignTokens.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: ParentDesignTokens.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: ParentDesignTokens.brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(actionLabel!, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmering Skeleton Placeholder for Parent Portal
class ParentSkeletonLoader extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const ParentSkeletonLoader({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, opacity, _) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0).withValues(alpha: opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(10),
          ),
        );
      },
    );
  }
}

enum ParentButtonVariant { primary, secondary, outline, text, danger }

/// Standardized Parent Button with micro-interactions
class ParentButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ParentButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final double fontSize;

  const ParentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ParentButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
    this.fontSize = 13.5,
  });

  @override
  State<ParentButton> createState() => _ParentButtonState();
}

class _ParentButtonState extends State<ParentButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    Border? border;

    switch (widget.variant) {
      case ParentButtonVariant.primary:
        bg = isEnabled
            ? (_isHovered ? ParentDesignTokens.brandLight : ParentDesignTokens.brand)
            : const Color(0xFFCBD5E1);
        fg = Colors.white;
        break;
      case ParentButtonVariant.secondary:
        bg = isEnabled
            ? (_isHovered ? const Color(0xFFE2E8F0) : ParentDesignTokens.surfaceMuted)
            : const Color(0xFFF1F5F9);
        fg = isEnabled ? ParentDesignTokens.textPrimary : ParentDesignTokens.textMuted;
        break;
      case ParentButtonVariant.outline:
        bg = _isHovered && isEnabled ? ParentDesignTokens.brandTint : Colors.transparent;
        fg = isEnabled ? ParentDesignTokens.brand : ParentDesignTokens.textMuted;
        border = Border.all(
          color: isEnabled
              ? (_isHovered ? ParentDesignTokens.brand : ParentDesignTokens.border)
              : ParentDesignTokens.border,
          width: 1.2,
        );
        break;
      case ParentButtonVariant.danger:
        bg = isEnabled
            ? (_isHovered ? const Color(0xFFBE123C) : ParentDesignTokens.rose)
            : const Color(0xFFCBD5E1);
        fg = Colors.white;
        break;
      case ParentButtonVariant.text:
        bg = Colors.transparent;
        fg = isEnabled ? ParentDesignTokens.brand : ParentDesignTokens.textMuted;
        break;
    }

    Widget buttonChild = Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Row(
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isLoading) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fg),
              ),
            ),
            const SizedBox(width: 8),
          ] else if (widget.icon != null) ...[
            Icon(widget.icon, size: widget.fontSize + 3, color: fg),
            const SizedBox(width: 7),
          ],
          Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );

    if (!isEnabled) {
      return widget.fullWidth
          ? SizedBox(width: double.infinity, child: buttonChild)
          : buttonChild;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(10),
        child: widget.fullWidth
            ? SizedBox(width: double.infinity, child: buttonChild)
            : buttonChild,
      ),
    );
  }
}

