import 'package:flutter/material.dart';
import '../../domain/study_plan.dart';
import '../../domain/study_plan_day.dart';
import '../../../../common/design/design_system.dart';

/// A calendar heatmap for a study plan.
/// Each day cell shows the day number, status colour, XP value, and
/// a special indicator for review days.
class CalendarHeatmapWidget extends StatelessWidget {
  final StudyPlan plan;
  final bool isDarkMode;
  final void Function(StudyPlanDay day) onDayTap;

  const CalendarHeatmapWidget({
    super.key,
    required this.plan,
    required this.isDarkMode,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.tryParse(plan.startDate) ?? DateTime.now();
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegend(),
        const SizedBox(height: 12),
        _buildGrid(startDate, today),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _legendItem(
            _cellColor(DayStatus.notAttempted, isReviewDay: false), 'Not started'),
        _legendItem(_cellColor(DayStatus.inProgress, isReviewDay: false),
            'In progress'),
        _legendItem(_cellColor(DayStatus.done, isReviewDay: false), 'Done'),
        _legendItem(
            _cellColor(DayStatus.notAttempted, isReviewDay: true), 'Review day'),
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
          style: MnemonicsTypography.bodyRegular.copyWith(
            fontSize: 11,
            color: StudyPlanColors.mutedText(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(DateTime startDate, DateTime today) {
    const cellsPerRow = 7;

    final totalDays = plan.numDays;
    final rows = (totalDays / cellsPerRow).ceil();

    final dayMap = <int, StudyPlanDay>{
      for (final d in plan.days) d.dayNumber: d,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        const cellSpacing = 6.0;
        final availableWidth = constraints.maxWidth;
        // Distribute 7 cells evenly within available width, no overflow.
        final cellSize =
            (availableWidth - cellSpacing * (cellsPerRow - 1)) / cellsPerRow;

        return Column(
          children: List.generate(rows, (row) {
            final isLastRow = row == rows - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLastRow ? 0 : cellSpacing),
              child: Row(
                children: List.generate(cellsPerRow, (col) {
                  final dayNumber = row * cellsPerRow + col + 1;
                  final isLastCol = col == cellsPerRow - 1;
                  if (dayNumber > totalDays) {
                    return Expanded(child: SizedBox(height: cellSize));
                  }

                  final planDay = dayMap[dayNumber];
                  final thisDate =
                      startDate.add(Duration(days: dayNumber - 1));
                  final isToday = _isSameDay(thisDate, today);
                  final status = planDay?.status ?? DayStatus.notAttempted;
                  final isPast = thisDate.isBefore(today) && !isToday;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: isLastCol ? 0 : cellSpacing),
                      child: _DayCell(
                        dayNumber: dayNumber,
                        status: status,
                        isToday: isToday,
                        isPast: isPast,
                        cellSize: cellSize,
                        isDarkMode: isDarkMode,
                        xpValue: planDay?.xpValue ?? 10,
                        isReviewDay: planDay?.isReviewDay ?? false,
                        onTap:
                            planDay != null ? () => onDayTap(planDay) : null,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _cellColor(DayStatus status, {required bool isReviewDay}) {
    if (isReviewDay && status == DayStatus.notAttempted) {
      return StudyPlanColors.review;
    }
    switch (status) {
      case DayStatus.done:
        return StudyPlanColors.done;
      case DayStatus.inProgress:
        return StudyPlanColors.inProgress;
      case DayStatus.notAttempted:
        return StudyPlanColors.notStarted(isDarkMode);
    }
  }
}

class _DayCell extends StatefulWidget {
  final int dayNumber;
  final DayStatus status;
  final bool isToday;
  final bool isPast;
  final double cellSize;
  final bool isDarkMode;
  final int xpValue;
  final bool isReviewDay;
  final VoidCallback? onTap;

  const _DayCell({
    required this.dayNumber,
    required this.status,
    required this.isToday,
    required this.isPast,
    required this.cellSize,
    required this.isDarkMode,
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
    if (widget.status == DayStatus.done) return StudyPlanColors.done;
    if (widget.status == DayStatus.inProgress) {
      return StudyPlanColors.inProgress;
    }
    if (widget.isReviewDay) return StudyPlanColors.review;
    return StudyPlanColors.notStarted(widget.isDarkMode);
  }

  bool get _usesLightText {
    return widget.status == DayStatus.done ||
        widget.status == DayStatus.inProgress;
  }

  Color get _textColor {
    if (_usesLightText) return Colors.white;
    if (widget.isReviewDay) {
      return MnemonicsColors.textPrimary;
    }
    return StudyPlanColors.mutedText(widget.isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final showTodayRing = widget.isToday &&
        widget.status == DayStatus.notAttempted &&
        !widget.isReviewDay;

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
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(10),
            border: showTodayRing
                ? Border.all(
                    color: MnemonicsColors.primaryGreen, width: 2)
                : null,
            boxShadow: widget.status != DayStatus.notAttempted ||
                    widget.isToday ||
                    widget.isReviewDay
                ? [
                    BoxShadow(
                      color: _bgColor.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '${widget.dayNumber}',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 13,
                    fontWeight: widget.isToday ||
                            widget.status != DayStatus.notAttempted ||
                            widget.isReviewDay
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
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
              if (widget.isReviewDay &&
                  widget.status == DayStatus.notAttempted)
                Positioned(
                  bottom: 3,
                  right: 3,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MnemonicsColors.textPrimary.withOpacity(0.35),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
