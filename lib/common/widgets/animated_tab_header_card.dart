import 'package:flutter/material.dart';
import '../design/design_system.dart';
import '../layout/tab_screen_layout.dart';

/// Shared animated header used on every top-level tab.
///
/// The card has a fixed height and identical slide/fade animation so it
/// always lands on the same visual position across Home, Practice, Learn,
/// and Profile.
class AnimatedTabHeaderCard extends StatefulWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isDarkMode;
  final EdgeInsetsGeometry? margin;

  const AnimatedTabHeaderCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.isDarkMode,
    this.trailing,
    this.margin,
  });

  @override
  State<AnimatedTabHeaderCard> createState() => _AnimatedTabHeaderCardState();
}

class _AnimatedTabHeaderCardState extends State<AnimatedTabHeaderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.isDarkMode ? MnemonicsColors.darkSurface : Colors.white;
    final titleColor = widget.isDarkMode
        ? MnemonicsColors.darkTextPrimary
        : MnemonicsColors.textPrimary;
    final subtitleColor = widget.isDarkMode
        ? MnemonicsColors.darkTextSecondary
        : MnemonicsColors.textSecondary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        key: TabScreenLayout.headerKey,
        height: TabScreenLayout.headerHeight,
        width: double.infinity,
        margin: widget.margin ?? EdgeInsets.zero,
        padding: TabScreenLayout.headerPadding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          boxShadow: widget.isDarkMode
              ? MnemonicsColors.darkCardShadow
              : MnemonicsColors.cardShadow,
          border: widget.isDarkMode
              ? Border.all(
                  color: MnemonicsColors.darkBorder.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: TabScreenLayout.leadingSize,
              height: TabScreenLayout.leadingSize,
              child: widget.leading,
            ),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MnemonicsTypography.headingMedium.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.xs),
                  Text(
                    widget.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: subtitleColor,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: MnemonicsSpacing.s),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Circular gradient badge used as the header leading widget.
class TabHeaderBadge extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const TabHeaderBadge({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ??
        [
          MnemonicsColors.primaryGreen,
          MnemonicsColors.primaryGreen.withOpacity(0.7),
        ];

    return Container(
      width: TabScreenLayout.leadingSize,
      height: TabScreenLayout.leadingSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

/// Small trailing icon chip used in tab headers.
class TabHeaderTrailingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const TabHeaderTrailingIcon({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.s),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}
