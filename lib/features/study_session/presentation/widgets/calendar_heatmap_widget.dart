import 'package:flutter/material.dart';
import '../../domain/study_plan.dart';
import '../../domain/study_plan_day.dart';
import '../../../../common/design/design_system.dart';

/// A LeetCode-style calendar heatmap for a study plan.
/// Each day cell shows the day number, status colour, XP value, and
/// a special indicator for review days.
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
        _buildLegend(context, isDark),
        const SizedBox(height: 12),
        _buildGrid(context, startDate, today, isDark),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _legendItem(_cellColor(DayStatus.notAttempted, isDark), 'Not started'),
        _legendItem(_cellColor(DayStatus.inProgress, isDark), 'In progress'),
        _legendItem(_cellColor(DayStatus.done, isDark), 'Done'),
        _legendItem(const Color(0xFF6366F1), 'Review day'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: MnemonicsColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGrid(
      BuildContext context, DateTime startDate, DateTime today, bool isDark) {
    const cellSize = 42.0;
    const cellSpacing = 6.0;
    const cellsPerRow = 7;

    final totalDays = plan.numDays;
    final rows = (totalDays / cellsPerRow).ceil();

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
                return const SizedBox(width: cellSize + cellSpacing);
              }

              final planDay = dayMap[dayNumber];
              final thisDate =
                  startDate.add(Duration(days: dayNumber - 1));
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
                  xpValue: planDay?.xpValue ?? 10,
                  isReviewDay: planDay?.isReviewDay ?? false,
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
        return const Color(0xFF22C55E);
      case DayStatus.inProgress:
        return const Color(0xFFEAB308);
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
  final int xpValue;
  final bool isReviewDay;
  final VoidCallback? onTap;

  const _DayCell({
    required this.dayNumber,
    required this.status,
    required this.isToday,
    required this.isPast,
    required this.cellSize,
    required this.isDark,
    required this.xpValue,
    required this.isReviewDay,
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
    if (widget.isReviewDay) return const Color(0xFF6366F1);
    if (widget.isToday) return const Color(0xFF6366F1);
    return widget.isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  }

  Color get _textColor {
    if (widget.status == DayStatus.done ||
        widget.status == DayStatus.inProgress ||
        widget.isReviewDay ||
        widget.isToday) {
      return Colors.white;
    }
    return widget.isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
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
            borderRadius: BorderRadius.circular(10),
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
          child: Stack(
            children: [
              // Day number
              Center(
                child: Text(
                  '${widget.dayNumber}',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 13,
                    fontWeight: widget.isToday ||
                            widget.status != DayStatus.notAttempted
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
              // XP badge (top-right)
              if (widget.status == DayStatus.done)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+${widget.xpValue}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              // Review day indicator (bottom-right)
              if (widget.isReviewDay && widget.status == DayStatus.notAttempted)
                Positioned(
                  bottom: 3,
                  right: 3,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white70,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
