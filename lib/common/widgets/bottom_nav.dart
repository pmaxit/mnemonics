import 'package:flutter/material.dart';
import '../design/design_system.dart';

class MnemonicsBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MnemonicsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MnemonicsSpacing.bottomNavHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: 'Tasks',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.timer_outlined,
            activeIcon: Icons.timer,
            label: 'Timer',
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? MnemonicsColors.primaryGreen
                  : MnemonicsColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isActive
                    ? MnemonicsColors.primaryGreen
                    : MnemonicsColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 