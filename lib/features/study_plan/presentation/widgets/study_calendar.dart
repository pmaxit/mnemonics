import 'package:flutter/material.dart';
import '../../domain/study_plan.dart';
import '../../../../common/design/design_system.dart';

/// LeetCode-style calendar heatmap for study plan days
class StudyCalendar extends StatelessWidget {
  final StudyPlan plan;
  final void Function(StudyPlanDay day) onDayTapped;

  const StudyCalendar({super.key, required this.plan, required this.onDayTapped});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = plan.days;
    if (days.isEmpty) return const SizedBox.shrink();

    final startDate = DateTime.parse(plan.startDate);
    // Calculate grid: 7 columns (Mon-Sun), rows based on weeks spanned
    final startWeekday = startDate.weekday; // 1=Mon, 7=Sun
    final totalCells = (startWeekday - 1) + days.length;
    final totalRows = (totalCells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day-of-week headers
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? MnemonicsColors.darkTextSecondary
                                  : MnemonicsColors.textSecondary)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Grid of day cells
        ...List.generate(totalRows, (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayIndex = cellIndex - (startWeekday - 1);

                if (dayIndex < 0 || dayIndex >= days.length) {
                  // Empty cell (before start or after end)
                  return Expanded(child: _EmptyCell(isDark: isDark));
                }

                final day = days[dayIndex];
                return Expanded(
                  child: _DayCell(
                    day: day,
                    isDark: isDark,
                    onTap: () => onDayTapped(day),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

class _EmptyCell extends StatelessWidget {
  final bool isDark;
  const _EmptyCell({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final StudyPlanDay day;
  final bool isDark;
  final VoidCallback onTap;

  const _DayCell({required this.day, required this.isDark, required this.onTap});

  Color get _cellColor {
    switch (day.status) {
      case 'completed':
        return MnemonicsColors.primaryGreen;
      case 'in_progress':
        return const Color(0xFFFFC107);
      default:
        return isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);
    }
  }

  Color get _textColor {
    switch (day.status) {
      case 'completed':
        return Colors.white;
      case 'in_progress':
        return Colors.black87;
      default:
        return isDark ? Colors.white54 : Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _cellColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: day.status != 'not_started'
                ? [BoxShadow(color: _cellColor.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${day.dayNumber}',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: _textColor),
                ),
                if (day.totalWords > 0)
                  Text(
                    '${day.completedWords}/${day.totalWords}',
                    style: TextStyle(fontSize: 8, color: _textColor.withValues(alpha: 0.8)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
