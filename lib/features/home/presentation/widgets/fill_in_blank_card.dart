import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';

/// A single fill-in-the-blank exercise: an example sentence with the target
/// word hidden behind a tappable blank. Tapping reveals the word plus an
/// optional short definition/phrase hint, so learners have to recall the
/// word from context before the answer is given away.
class FillInBlankCard extends StatefulWidget {
  final String sentence;
  final String answer;
  final String? hint;

  const FillInBlankCard({
    Key? key,
    required this.sentence,
    required this.answer,
    this.hint,
  }) : super(key: key);

  @override
  State<FillInBlankCard> createState() => _FillInBlankCardState();
}

class _FillInBlankCardState extends State<FillInBlankCard> {
  bool _revealed = false;

  /// Splits [sentence] into (before, matchedWord, after) around the first
  /// occurrence of [answer], tolerating simple suffixes (-s, -es, -ed, -ing)
  /// so "obfuscated" still matches the base word "obfuscate".
  ({String before, String match, String after})? _locateBlank(
      String sentence, String answer) {
    final pattern = RegExp(
      '\\b(${RegExp.escape(answer)}\\w*)\\b',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(sentence);
    if (match == null) return null;
    return (
      before: sentence.substring(0, match.start),
      match: sentence.substring(match.start, match.end),
      after: sentence.substring(match.end),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = _locateBlank(widget.sentence, widget.answer);
    if (parts == null) {
      // Fall back to showing the plain sentence if we can't safely mask it.
      return _wrapCard(Text(widget.sentence, style: MnemonicsTypography.bodyRegular));
    }

    return GestureDetector(
      onTap: () => setState(() => _revealed = !_revealed),
      child: _wrapCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: MnemonicsTypography.bodyRegular.copyWith(height: 1.6),
                children: [
                  TextSpan(text: parts.before),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _revealed
                          ? Container(
                              key: const ValueKey('answer'),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: MnemonicsColors.primaryGreen
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: MnemonicsColors.primaryGreen),
                              ),
                              child: Text(
                                parts.match,
                                style: MnemonicsTypography.bodyRegular.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: MnemonicsColors.primaryGreen,
                                ),
                              ),
                            )
                          : Container(
                              key: const ValueKey('blank'),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 1),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade500,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: const Text('     '),
                            ),
                    ),
                  ),
                  TextSpan(text: parts.after),
                ],
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.s),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _revealed
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: widget.hint != null && widget.hint!.isNotEmpty
                  ? Text(
                      widget.hint!,
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    )
                  : const SizedBox.shrink(),
              secondChild: Row(
                children: [
                  Icon(Icons.touch_app, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to reveal',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wrapCard(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: MnemonicsColors.surface,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}
