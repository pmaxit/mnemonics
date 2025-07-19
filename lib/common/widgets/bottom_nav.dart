import 'package:flutter/material.dart';

/// Enum for navigation tabs
enum AppTab { home, practice, timer, profile }

/// Callback type for tab selection
typedef OnTabSelected = void Function(AppTab tab);

/// Custom Bottom Navigation Bar Skeleton
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
      child: PhysicalModel(
        color: Colors.white,
        elevation: 8,
        borderRadius: BorderRadius.circular(barRadius),
        shadowColor: Colors.black.withOpacity(0.10),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(barRadius),
          ),
          child: Row(
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
                inactiveColor: inactiveColor,
              ),
              _NavBarItem(
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups,
                label: 'Practice',
                tab: AppTab.practice,
                isActive: currentTab == AppTab.practice,
                onTap: () => onTabSelected(AppTab.practice),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _NavBarItem(
                icon: Icons.school_outlined,
                activeIcon: Icons.school,
                label: 'Learn',
                tab: AppTab.timer,
                isActive: currentTab == AppTab.timer,
                onTap: () => onTabSelected(AppTab.timer),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
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
                inactiveColor: inactiveColor,
              ),
            ],
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
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 