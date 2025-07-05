import 'package:flutter/material.dart';
import '../design/design_system.dart';

class MnemonicsTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? errorText;

  const MnemonicsTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: MnemonicsColors.textSecondary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.xs),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: MnemonicsTypography.bodyRegular,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: MnemonicsTypography.bodyRegular.copyWith(
              color: MnemonicsColors.textSecondary.withOpacity(0.5),
            ),
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: MnemonicsColors.textSecondary,
                    size: 24,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: MnemonicsColors.textSecondary,
                      size: 24,
                    ),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class MnemonicsSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hint;

  const MnemonicsSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.hint = 'Search',
  });

  @override
  Widget build(BuildContext context) {
    return MnemonicsTextField(
      controller: controller,
      onChanged: onChanged,
      hint: hint,
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true ? Icons.clear : null,
      onSuffixIconPressed: onClear,
    );
  }
} 