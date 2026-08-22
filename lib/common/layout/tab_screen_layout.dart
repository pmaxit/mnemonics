import 'package:flutter/material.dart';
import '../design/design_system.dart';

/// Shared geometry for top-level tab screens so header cards land on the
/// same pixel position and leave the same gap before the next card.
class TabScreenLayout {
  TabScreenLayout._();

  /// Gap between the bottom of the app bar and the header card.
  static const double topGap = MnemonicsSpacing.m;

  /// Horizontal inset shared by the header card and following content.
  static const double horizontalPadding = MnemonicsSpacing.m;

  /// Gap between the header card and the next card.
  static const double afterHeaderGap = MnemonicsSpacing.m;

  /// Fixed outer height of every tab header card.
  static const double headerHeight = 120.0;

  /// Size of the leading avatar/icon inside the header card.
  static const double leadingSize = 48.0;

  /// Inner padding of the header card.
  static const EdgeInsets headerPadding = EdgeInsets.symmetric(
    horizontal: MnemonicsSpacing.m,
    vertical: MnemonicsSpacing.m,
  );

  /// Space reserved for the floating bottom navigation bar.
  static const double bottomNavClearance = 120.0;

  static const Key headerKey = Key('tab-header-card');
  static const Key nextCardKey = Key('tab-next-card');

  /// Y-offset where header cards must start.
  ///
  /// Tab bodies live in a [Scaffold] with `extendBodyBehindAppBar: true`, so
  /// [MediaQuery] top padding already equals the app bar's bottom edge.
  static double contentTop(BuildContext context) {
    return MediaQuery.paddingOf(context).top + topGap;
  }

  /// Standard scroll padding for tab bodies. Horizontal inset is omitted
  /// so individual cards can own their own side margins.
  static EdgeInsets scrollPadding(BuildContext context) {
    return EdgeInsets.only(
      top: contentTop(context),
      bottom: bottomNavClearance,
    );
  }

  /// Scroll padding that also applies the shared horizontal inset.
  static EdgeInsets paddedScrollPadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      horizontalPadding,
      contentTop(context),
      horizontalPadding,
      bottomNavClearance,
    );
  }
}
