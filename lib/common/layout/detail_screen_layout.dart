import 'package:flutter/material.dart';
import '../design/design_system.dart';

/// Shared geometry for pushed detail screens (My Words, Study Plan, etc.).
class DetailScreenLayout {
  DetailScreenLayout._();

  /// Gap between app bar bottom and the first summary card.
  static const double topGap = MnemonicsSpacing.s;

  /// Horizontal inset for the summary card and scroll body.
  static const double horizontalPadding = MnemonicsSpacing.l;

  /// Gap between the summary card and the next block of content.
  static const double afterSummaryGap = MnemonicsSpacing.m;

  static const Key summaryCardKey = Key('detail-summary-card');
  static const Key nextBlockKey = Key('detail-next-block');

  static const EdgeInsets summaryCardOuterPadding = EdgeInsets.fromLTRB(
    horizontalPadding,
    topGap,
    horizontalPadding,
    0,
  );

  static const EdgeInsets scrollBodyPadding = EdgeInsets.fromLTRB(
    horizontalPadding,
    afterSummaryGap,
    horizontalPadding,
    40,
  );

  static const EdgeInsets summaryCardInnerPadding = EdgeInsets.all(
    MnemonicsSpacing.m,
  );

  static BoxDecoration summaryCardDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
      boxShadow: isDarkMode
          ? MnemonicsColors.darkCardShadow
          : MnemonicsColors.cardShadow,
      border: isDarkMode
          ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
          : null,
    );
  }
}

/// App bar used on pushed detail screens — matches [MyWordsListScreen].
class DetailScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isDarkMode;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const DetailScreenAppBar({
    super.key,
    required this.title,
    required this.isDarkMode,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: isDarkMode
              ? MnemonicsColors.darkTextPrimary
              : MnemonicsColors.textPrimary,
        ),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        title,
        style: MnemonicsTypography.headingMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: isDarkMode
              ? MnemonicsColors.darkTextPrimary
              : MnemonicsColors.textPrimary,
        ),
      ),
      actions: actions,
    );
  }
}

/// White summary card — matches the first card on [MyWordsListScreen].
class DetailSummaryCard extends StatelessWidget {
  final bool isDarkMode;
  final Widget child;

  const DetailSummaryCard({
    super.key,
    required this.isDarkMode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: DetailScreenLayout.summaryCardKey,
      width: double.infinity,
      padding: DetailScreenLayout.summaryCardInnerPadding,
      decoration: DetailScreenLayout.summaryCardDecoration(isDarkMode),
      child: child,
    );
  }
}

/// Standard two-line summary row with a fixed-width green CTA on the right.
class DetailSummaryRow extends StatelessWidget {
  final bool isDarkMode;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const DetailSummaryRow({
    super.key,
    required this.isDarkMode,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDarkMode
        ? MnemonicsColors.darkTextPrimary
        : MnemonicsColors.textPrimary;
    final subtitleColor = isDarkMode
        ? MnemonicsColors.darkTextSecondary
        : MnemonicsColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MnemonicsTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: MnemonicsSpacing.m),
        DetailSummaryActionButton(
          label: actionLabel,
          onTap: onAction,
        ),
      ],
    );
  }
}

/// Fixed-width CTA so summary cards stay the same size across detail screens.
class DetailSummaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DetailSummaryActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  static const double width = 120;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(
          horizontal: MnemonicsSpacing.m,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: MnemonicsColors.primaryGreen,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
