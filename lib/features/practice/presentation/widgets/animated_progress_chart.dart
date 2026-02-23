import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/statistics_data.dart';
import '../../../../common/design/design_system.dart';
import 'animated_progress_utils.dart';
import 'animated_stat_card.dart';

class AnimatedProgressChart extends StatefulWidget {
  final List<DailyProgress> weeklyProgress;
  final int animationDelay;

  const AnimatedProgressChart({
    super.key,
    required this.weeklyProgress,
    this.animationDelay = 0,
  });

  @override
  State<AnimatedProgressChart> createState() => _AnimatedProgressChartState();
}

class _AnimatedProgressChartState extends State<AnimatedProgressChart>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _drawController;
  late AnimationController _interactionController;

  late Animation<double> _containerAnimation;
  late Animation<double> _lineDrawAnimation;
  late Animation<double> _pointsAnimation;
  late Animation<double> _gradientAnimation;

  final int _hoveredIndex = -1;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Entry animation for container
    _entryController = AnimationController(
      duration: AnimatedProgressUtils.dataAnimation,
      vsync: this,
    );

    // Drawing animation for chart elements
    _drawController = AnimationController(
      duration: Duration(
          milliseconds:
              AnimatedProgressUtils.dataAnimation.inMilliseconds + 600),
      vsync: this,
    );

    // Interaction animation
    _interactionController = AnimationController(
      duration: AnimatedProgressUtils.microInteraction,
      vsync: this,
    );

    // Container entry animation
    _containerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: AnimatedProgressUtils.entryEasing,
    ));

    // Line drawing animation
    _lineDrawAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _drawController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    // Points reveal animation
    _pointsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _drawController,
      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
    ));

    // Gradient fill animation
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _drawController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeInOut),
    ));

    // Start animations with delay
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _entryController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _drawController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _drawController.dispose();
    _interactionController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _interactionController.forward();
    } else {
      _interactionController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _containerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset.zero, // Disabled slide animation
          child: Opacity(
            opacity: _containerAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: TweenAnimationBuilder<double>(
                duration: AnimatedProgressUtils.microInteraction,
                tween: Tween<double>(
                  begin: 1.0,
                  end: _isHovered ? 1.02 : 1.0,
                ),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      height: 240,
                      padding: const EdgeInsets.all(MnemonicsSpacing.l),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(MnemonicsSpacing.radiusXL),
                        boxShadow: _isHovered
                            ? AnimatedProgressUtils.hoverShadow
                            : AnimatedProgressUtils.restingShadow,
                        border: Border.all(
                          color: _isHovered
                              ? MnemonicsColors.primaryGreen.withOpacity(0.3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with animation
                          AnimatedBuilder(
                            animation: _containerAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _containerAnimation.value,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Weekly Progress',
                                      style: MnemonicsTypography.bodyLarge
                                          .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                      ),
                                    ),
                                    // Animated sparkle icon
                                    TweenAnimationBuilder<double>(
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      tween:
                                          Tween<double>(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.rotate(
                                          angle: value * 2 * 3.14159,
                                          child: Icon(
                                            Icons.auto_graph,
                                            color: MnemonicsColors.primaryGreen
                                                .withOpacity(0.7),
                                            size: 20,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: MnemonicsSpacing.m),

                          // Chart with drawing animations
                          Expanded(
                            child: AnimatedBuilder(
                              animation: Listenable.merge([
                                _lineDrawAnimation,
                                _pointsAnimation,
                                _gradientAnimation,
                              ]),
                              builder: (context, child) {
                                return LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 1,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.shade300,
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index >= 0 &&
                                                index <
                                                    widget.weeklyProgress
                                                        .length) {
                                              final date = widget
                                                  .weeklyProgress[index].date;
                                              return AnimatedBuilder(
                                                animation: _containerAnimation,
                                                builder: (context, child) {
                                                  return Opacity(
                                                    opacity: _containerAnimation
                                                        .value,
                                                    child: SideTitleWidget(
                                                      axisSide: meta.axisSide,
                                                      child: Text(
                                                        _formatDay(date),
                                                        style:
                                                            MnemonicsTypography
                                                                .bodyRegular
                                                                .copyWith(
                                                          color: MnemonicsColors
                                                              .textSecondary,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                            return Container();
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            return AnimatedBuilder(
                                              animation: _containerAnimation,
                                              builder: (context, child) {
                                                return Opacity(
                                                  opacity:
                                                      _containerAnimation.value,
                                                  child: SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    child: Text(
                                                      value.toInt().toString(),
                                                      style: MnemonicsTypography
                                                          .bodyRegular
                                                          .copyWith(
                                                        color: MnemonicsColors
                                                            .textSecondary,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border(
                                        left: BorderSide(
                                            color: Colors.grey.shade300),
                                        bottom: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                    ),
                                    lineTouchData: LineTouchData(
                                      enabled: true,
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (touchedSpot) =>
                                            MnemonicsColors.primaryGreen
                                                .withOpacity(0.8),
                                        tooltipRoundedRadius: 8,
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map((spot) {
                                            final index = spot.x.toInt();
                                            if (index >= 0 &&
                                                index <
                                                    widget.weeklyProgress
                                                        .length) {
                                              final progress =
                                                  widget.weeklyProgress[index];
                                              return LineTooltipItem(
                                                '${progress.wordsLearned} words\n${_formatDate(progress.date)}',
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            }
                                            return null;
                                          }).toList();
                                        },
                                      ),
                                    ),
                                    minX: 0,
                                    maxX: (widget.weeklyProgress.length - 1)
                                        .toDouble(),
                                    minY: 0,
                                    maxY: _getMaxY(),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _getAnimatedSpots(),
                                        isCurved: true,
                                        color: MnemonicsColors.primaryGreen,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter:
                                              (spot, percent, barData, index) {
                                            final scale =
                                                _pointsAnimation.value;
                                            return FlDotCirclePainter(
                                              radius: 6 * scale,
                                              color:
                                                  MnemonicsColors.primaryGreen,
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            );
                                          },
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              MnemonicsColors.primaryGreen
                                                  .withOpacity(0.3 *
                                                      _gradientAnimation.value),
                                              MnemonicsColors.primaryGreen
                                                  .withOpacity(0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _getAnimatedSpots() {
    final spots = <FlSpot>[];
    final progress = _lineDrawAnimation.value;
    final totalPoints = widget.weeklyProgress.length;
    final visiblePoints = (totalPoints * progress).ceil();

    for (int i = 0;
        i < visiblePoints && i < widget.weeklyProgress.length;
        i++) {
      spots.add(FlSpot(
        i.toDouble(),
        widget.weeklyProgress[i].wordsLearned.toDouble(),
      ));
    }

    return spots;
  }

  String _formatDay(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  double _getMaxY() {
    if (widget.weeklyProgress.isEmpty) return 5;
    final max = widget.weeklyProgress
        .map((p) => p.wordsLearned)
        .reduce((a, b) => a > b ? a : b);
    return (max + 2).toDouble();
  }
}

// Enhanced breakdown section with animations
class AnimatedBreakdownSection extends StatefulWidget {
  final String title;
  final Map<String, int> data;
  final int animationDelay;
  final Function(String)? onCategoryTap;

  const AnimatedBreakdownSection({
    super.key,
    required this.title,
    required this.data,
    this.animationDelay = 0,
    this.onCategoryTap,
  });

  @override
  State<AnimatedBreakdownSection> createState() =>
      _AnimatedBreakdownSectionState();
}

class _AnimatedBreakdownSectionState extends State<AnimatedBreakdownSection>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<double> _headerAnimation;
  late List<Animation<double>> _itemAnimations;
  bool _hasAnimated = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 800 + (widget.data.length * 100)),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _itemAnimations = List.generate(
      widget.data.length,
      (index) {
        final maxItems = widget.data.length;
        final itemDelay =
            0.2 + (index / maxItems) * 0.6; // Start from 0.2, spread over 0.6
        final itemEnd =
            (itemDelay + 0.3).clamp(0.0, 1.0); // Ensure it doesn't exceed 1.0

        return Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(
            itemDelay.clamp(0.0, 1.0),
            itemEnd,
            curve: Curves.easeOut,
          ),
        ));
      },
    );

    if (!_hasAnimated) {
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted && !_hasAnimated) {
          _hasAnimated = true;
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated header
        AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset.zero, // Disabled slide animation
              child: Opacity(
                opacity: _headerAnimation.value,
                child: Text(
                  widget.title,
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: MnemonicsSpacing.m),

        // Animated breakdown items
        if (widget.data.isEmpty)
          AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _headerAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(MnemonicsSpacing.l),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                        BorderRadius.circular(MnemonicsSpacing.radiusL),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text(
                      'No data available',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: MnemonicsColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        else
          Wrap(
            spacing: MnemonicsSpacing.m,
            runSpacing: MnemonicsSpacing.s,
            children: widget.data.entries.map((entry) {
              final index = widget.data.keys.toList().indexOf(entry.key);
              return AnimatedBuilder(
                animation: _itemAnimations[index],
                builder: (context, child) {
                  return AnimatedProgressUtils.buildStaggeredAnimation(
                    animation: _itemAnimations[index],
                    index: index,
                    totalItems: widget.data.length,
                    child: AnimatedStatCard(
                      label: entry.key,
                      value: entry.value,
                      accentColor: _getColorForCategory(entry.key),
                      animationDelay: 0, // Already handled by parent
                      onTap: widget.onCategoryTap != null
                          ? () => widget.onCategoryTap!(entry.key)
                          : null,
                    ),
                  );
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Color _getColorForCategory(String category) {
    final colors = [
      MnemonicsColors.primaryGreen,
      MnemonicsColors.secondaryOrange,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[category.hashCode % colors.length];
  }
}
