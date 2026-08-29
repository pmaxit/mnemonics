import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/design_system.dart';

/// Enum for navigation tabs
enum AppTab { home, progress, focus, profile }

/// Callback type for tab selection
typedef OnTabSelected = void Function(AppTab tab);

/// Custom Bottom Navigation Bar with Robinhood-style micro-animations:
/// a pill highlight slides between tabs while the active icon scales up
/// with an overshoot bounce and its label fades/slides into place.
class CustomBottomNavBar extends StatelessWidget {
  final AppTab currentTab;
  final OnTabSelected onTabSelected;
  final bool showNotificationDot;

  const CustomBottomNavBar({
    Key? key,
    required this.currentTab,
    required this.onTabSelected,
    this.showNotificationDot = false,
  }) : super(key: key);

  static const double barHeight = 72;
  static const double barRadius = 32;
  static const Color activeColor = Color(0xFF4CAF50); // Green
  static const Color inactiveColor = Color(0xFF757575);

  static const Duration pillDuration = Duration(milliseconds: 350);
  static const Duration itemDuration = Duration(milliseconds: 250);
  static const Curve pillCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.easeOutBack;

  static const List<AppTab> _tabs = AppTab.values;

  int get _currentIndex => _tabs.indexOf(currentTab);

  /// X-alignment of the pill center for [index], in a Row of equal slots.
  /// The pill spans `1/total` of the bar width via [FractionallySizedBox],
  /// so Alignment positions are projected against the leftover slack, not the
  /// full width. For a child width of `1/total`, slot centers land at
  /// `(2*index + 1 - total) / (total - 1)`.
  static double _slotAlignment(int index, int total) =>
      (2 * index + 1 - total) / (total - 1);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? MnemonicsColors.darkSurface.withOpacity(0.7)
        : Colors.white.withOpacity(0.7);
    final pillColor = activeColor.withOpacity(isDarkMode ? 0.18 : 0.12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(barRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(barRadius),
              border: Border.all(
                color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Sliding pill highlight behind the active tab.
                Positioned.fill(
                  child: AnimatedAlign(
                    duration: pillDuration,
                    curve: pillCurve,
                    alignment: Alignment(
                      _slotAlignment(_currentIndex, _tabs.length),
                      0,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 1 / _tabs.length,
                      heightFactor: 1,
                      child: AnimatedContainer(
                        duration: pillDuration,
                        curve: pillCurve,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: pillColor,
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _NavBarItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      tab: AppTab.home,
                      isActive: currentTab == AppTab.home,
                      onTap: () => onTabSelected(AppTab.home),
                      activeColor: activeColor,
                      inactiveColor: isDarkMode ? Colors.white70 : inactiveColor,
                    ),
                    _NavBarItem(
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      label: 'Progress',
                      tab: AppTab.progress,
                      isActive: currentTab == AppTab.progress,
                      onTap: () => onTabSelected(AppTab.progress),
                      activeColor: activeColor,
                      inactiveColor: isDarkMode ? Colors.white70 : inactiveColor,
                    ),
                    _NavBarItem(
                      icon: Icons.timer_outlined,
                      activeIcon: Icons.timer,
                      label: 'Focus',
                      tab: AppTab.focus,
                      isActive: currentTab == AppTab.focus,
                      onTap: () => onTabSelected(AppTab.focus),
                      activeColor: activeColor,
                      inactiveColor: isDarkMode ? Colors.white70 : inactiveColor,
                    ),
                    _NavBarItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profile',
                      tab: AppTab.profile,
                      isActive: currentTab == AppTab.profile,
                      onTap: () => onTabSelected(AppTab.profile),
                      showNotificationDot: showNotificationDot,
                      activeColor: activeColor,
                      inactiveColor: isDarkMode ? Colors.white70 : inactiveColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final AppTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final bool showNotificationDot;
  final Color activeColor;
  final Color inactiveColor;

  const _NavBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.tab,
    required this.isActive,
    required this.onTap,
    this.showNotificationDot = false,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon lifts a few px and scales with an overshoot bounce.
            SizedBox(
              height: 40,
              child: AnimatedAlign(
                duration: CustomBottomNavBar.itemDuration,
                curve: CustomBottomNavBar.bounceCurve,
                alignment: Alignment(0, isActive ? -0.6 : 0.3),
                child: AnimatedScale(
                duration: CustomBottomNavBar.itemDuration,
                curve: CustomBottomNavBar.bounceCurve,
                scale: isActive ? 1.15 : 1.0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: Stack(
                    key: ValueKey(isActive),
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        isActive ? (activeIcon ?? icon) : icon,
                        color: isActive ? activeColor : inactiveColor,
                        size: 28,
                      ),
                      if (showNotificationDot && tab == AppTab.profile)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF1744),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                 ),
               ),
              ),
            ),
            // Label fades + slides in under the active icon, settles when not.
            AnimatedSlide(
              duration: CustomBottomNavBar.itemDuration,
              curve: CustomBottomNavBar.pillCurve,
              offset: isActive ? Offset.zero : const Offset(0, 0.25),
              child: AnimatedOpacity(
                duration: CustomBottomNavBar.itemDuration,
                curve: Curves.easeOut,
                opacity: isActive ? 1.0 : 0.55,
                child: AnimatedDefaultTextStyle(
                  duration: CustomBottomNavBar.itemDuration,
                  curve: Curves.easeOut,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  child: Text(label),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
