import 'package:flutter/material.dart';
import '../../domain/study_plan.dart';
import '../../domain/study_plan_day.dart';

/// A LeetCode-style calendar heatmap for a study plan.
/// Each day cell is coloured:
///   - Gray   → not_attempted
///   - Yellow → in_progress
///   - Green  → done
///   - Blue   → today (if not yet started)
class CalendarHeatmapWidget extends StatelessWidget {
  final StudyPlan plan;
  final void Function(StudyPlanDay day) onDayTap;

  const CalendarHeatmapWidget({
    super.key,
    required this.plan,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.tryParse(plan.startDate) ?? DateTime.now();
    final today = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegend(context),
        const SizedBox(height: 12),
        _buildGrid(context, startDate, today, isDark),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _legendItem(context, _cellColor(DayStatus.notAttempted, false), 'Not started'),
        const SizedBox(width: 12),
        _legendItem(context, _cellColor(DayStatus.inProgress, false), 'In progress'),
        const SizedBox(width: 12),
        _legendItem(context, _cellColor(DayStatus.done, false), 'Done'),
      ],
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildGrid(
      BuildContext context, DateTime startDate, DateTime today, bool isDark) {
    const cellSize = 38.0;
    const cellSpacing = 6.0;
    const cellsPerRow = 7;

    final totalDays = plan.numDays;
    final rows = (totalDays / cellsPerRow).ceil();

    // Build a map from dayNumber → StudyPlanDay for quick lookup
    final dayMap = <int, StudyPlanDay>{
      for (final d in plan.days) d.dayNumber: d,
    };

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: cellSpacing),
          child: Row(
            children: List.generate(cellsPerRow, (col) {
              final dayNumber = row * cellsPerRow + col + 1;
              if (dayNumber > totalDays) {
                return SizedBox(width: cellSize + cellSpacing);
              }

              final planDay = dayMap[dayNumber];
              final thisDate = startDate.add(Duration(days: dayNumber - 1));
              final isToday = _isSameDay(thisDate, today);
              final status = planDay?.status ?? DayStatus.notAttempted;
              final isPast = thisDate.isBefore(today) && !isToday;

              return Padding(
                padding: const EdgeInsets.only(right: cellSpacing),
                child: _DayCell(
                  dayNumber: dayNumber,
                  status: status,
                  isToday: isToday,
                  isPast: isPast,
                  cellSize: cellSize,
                  isDark: isDark,
                  onTap: planDay != null ? () => onDayTap(planDay) : null,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _cellColor(DayStatus status, bool isDark) {
    switch (status) {
      case DayStatus.done:
        return const Color(0xFF22C55E); // green-500
      case DayStatus.inProgress:
        return const Color(0xFFEAB308); // yellow-500
      case DayStatus.notAttempted:
        return isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    }
  }
}

class _DayCell extends StatefulWidget {
  final int dayNumber;
  final DayStatus status;
  final bool isToday;
  final bool isPast;
  final double cellSize;
  final bool isDark;
  final VoidCallback? onTap;

  const _DayCell({
    required this.dayNumber,
    required this.status,
    required this.isToday,
    required this.isPast,
    required this.cellSize,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bgColor {
    if (widget.status == DayStatus.done) return const Color(0xFF22C55E);
    if (widget.status == DayStatus.inProgress) return const Color(0xFFEAB308);
    if (widget.isToday) return const Color(0xFF6366F1); // indigo for today
    return widget.isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  }

  Color get _textColor {
    if (widget.status == DayStatus.done ||
        widget.status == DayStatus.inProgress ||
        widget.isToday) {
      return Colors.white;
    }
    return widget.isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => _ctrl.forward()
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _ctrl.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.cellSize,
          height: widget.cellSize,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(8),
            border: widget.isToday && widget.status == DayStatus.notAttempted
                ? Border.all(color: const Color(0xFF6366F1), width: 2)
                : null,
            boxShadow: widget.status != DayStatus.notAttempted || widget.isToday
                ? [
                    BoxShadow(
                      color: _bgColor.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${widget.dayNumber}',
            style: TextStyle(
              color: _textColor,
              fontSize: 12,
              fontWeight: widget.isToday || widget.status != DayStatus.notAttempted
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
