import 'package:flutter/material.dart';
import '../design/design_system.dart';

class MnemonicsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool isLoading;
  final IconData? icon;

  const MnemonicsButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? MnemonicsColors.secondaryOrange
              : MnemonicsColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: MnemonicsSpacing.buttonPaddingHorizontal,
            vertical: MnemonicsSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: MnemonicsSpacing.s),
          Text(text, style: MnemonicsTypography.bodyLarge),
        ],
      );
    }

    return Text(text, style: MnemonicsTypography.bodyLarge);
  }
}

class MnemonicsIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isActive;

  const MnemonicsIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? (color ?? MnemonicsColors.primaryGreen).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? color ?? MnemonicsColors.primaryGreen
                  : MnemonicsColors.textSecondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
} 