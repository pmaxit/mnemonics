import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';

class AuthSocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final BorderSide? border;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = MnemonicsColors.textPrimary,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: border ?? BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widgets for common social icons
class GoogleIconWidget extends StatelessWidget {
  const GoogleIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.blue.shade600,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
