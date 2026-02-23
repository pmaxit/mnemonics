import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../widgets/animated_progress_utils.dart';
import '../../domain/timer_models.dart';

class AnimatedTimeSelector extends StatefulWidget {
  final List<int> presetMinutes;
  final int selectedMinutes;
  final Function(int) onTimeSelected;
  final int animationDelay;

  const AnimatedTimeSelector({
    super.key,
    required this.presetMinutes,
    required this.selectedMinutes,
    required this.onTimeSelected,
    this.animationDelay = 0,
  });

  @override
  State<AnimatedTimeSelector> createState() => _AnimatedTimeSelectorState();
}

class _AnimatedTimeSelectorState extends State<AnimatedTimeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AnimatedProgressUtils.dataAnimation,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimatedProgressUtils.entryEasing,
    ));

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _animation.value)),
              child: Opacity(
                opacity: _animation.value,
                child: Text(
                  'How much time do you have?',
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: MnemonicsSpacing.l),

        // Animated time cards
        Wrap(
          spacing: MnemonicsSpacing.m,
          runSpacing: MnemonicsSpacing.m,
          children: widget.presetMinutes.asMap().entries.map((entry) {
            final index = entry.key;
            final minutes = entry.value;
            return AnimatedProgressUtils.buildStaggeredAnimation(
              animation: _animation,
              index: index,
              totalItems: widget.presetMinutes.length,
              child: _buildTimeCard(minutes),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeCard(int minutes) {
    final isSelected = minutes == widget.selectedMinutes;

    return GestureDetector(
      onTap: () => widget.onTimeSelected(minutes),
      child: TweenAnimationBuilder<double>(
        duration: AnimatedProgressUtils.microInteraction,
        tween: Tween<double>(begin: 1.0, end: isSelected ? 1.05 : 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isSelected ? MnemonicsColors.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                border: Border.all(
                  color: isSelected
                      ? MnemonicsColors.primaryGreen
                      : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? AnimatedProgressUtils.achievementShadow(
                        MnemonicsColors.primaryGreen)
                    : AnimatedProgressUtils.restingShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: isSelected
                        ? Colors.white
                        : MnemonicsColors.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(height: MnemonicsSpacing.xs),
                  Text(
                    '${minutes}m',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: isSelected
                          ? Colors.white
                          : MnemonicsColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedModeSelector extends StatefulWidget {
  final List<TimerMode> modes;
  final TimerMode selectedMode;
  final Function(TimerMode) onModeSelected;
  final int animationDelay;

  const AnimatedModeSelector({
    super.key,
    required this.modes,
    required this.selectedMode,
    required this.onModeSelected,
    this.animationDelay = 0,
  });

  @override
  State<AnimatedModeSelector> createState() => _AnimatedModeSelectorState();
}

class _AnimatedModeSelectorState extends State<AnimatedModeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AnimatedProgressUtils.dataAnimation,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimatedProgressUtils.entryEasing,
    ));

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _animation.value)),
              child: Opacity(
                opacity: _animation.value,
                child: Text(
                  'Study Mode',
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

        // Animated mode cards
        ...widget.modes.asMap().entries.map((entry) {
          final index = entry.key;
          final mode = entry.value;
          return AnimatedProgressUtils.buildStaggeredAnimation(
            animation: _animation,
            index: index,
            totalItems: widget.modes.length,
            child: Container(
              margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
              child: _buildModeCard(mode),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildModeCard(TimerMode mode) {
    final isSelected = mode == widget.selectedMode;

    return GestureDetector(
      onTap: () => widget.onModeSelected(mode),
      child: TweenAnimationBuilder<double>(
        duration: AnimatedProgressUtils.microInteraction,
        tween: Tween<double>(begin: 1.0, end: isSelected ? 1.02 : 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MnemonicsSpacing.m),
              decoration: BoxDecoration(
                color: isSelected
                    ? MnemonicsColors.primaryGreen.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                border: Border.all(
                  color: isSelected
                      ? MnemonicsColors.primaryGreen
                      : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? AnimatedProgressUtils.hoverShadow
                    : AnimatedProgressUtils.restingShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(MnemonicsSpacing.s),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MnemonicsColors.primaryGreen
                          : MnemonicsColors.primaryGreen.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(MnemonicsSpacing.radiusM),
                    ),
                    child: Icon(
                      _getModeIcon(mode),
                      color: isSelected
                          ? Colors.white
                          : MnemonicsColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: MnemonicsSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.displayName,
                          style: MnemonicsTypography.bodyRegular.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? MnemonicsColors.primaryGreen
                                : MnemonicsColors.textPrimary,
                          ),
                        ),
                        Text(
                          mode.description,
                          style: MnemonicsTypography.bodyRegular.copyWith(
                            fontSize: 12,
                            color: MnemonicsColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: MnemonicsColors.primaryGreen,
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getModeIcon(TimerMode mode) {
    switch (mode) {
      case TimerMode.allWords:
        return Icons.library_books;
      case TimerMode.difficultOnly:
        return Icons.psychology;
      case TimerMode.newWords:
        return Icons.fiber_new;
      case TimerMode.category:
        return Icons.category;
    }
  }
}

class AnimatedCountdown extends StatefulWidget {
  final VoidCallback onComplete;

  const AnimatedCountdown({
    super.key,
    required this.onComplete,
  });

  @override
  State<AnimatedCountdown> createState() => _AnimatedCountdownState();
}

class _AnimatedCountdownState extends State<AnimatedCountdown>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  int _currentNumber = 3;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AnimatedProgressUtils.celebrationEasing,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 3; i >= 1; i--) {
      setState(() {
        _currentNumber = i;
      });

      _scaleController.forward();
      _pulseController.repeat(reverse: true);

      await Future.delayed(const Duration(milliseconds: 900));

      _scaleController.reset();
      _pulseController.reset();
    }

    widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MnemonicsColors.primaryGreen.withOpacity(0.1),
            MnemonicsColors.primaryGreen.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Ready!',
              style: MnemonicsTypography.headingMedium.copyWith(
                color: MnemonicsColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.xl),
            AnimatedBuilder(
              animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value * _pulseAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: MnemonicsColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentNumber.toString(),
                        style: MnemonicsTypography.headingLarge.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedProgressTimer extends StatefulWidget {
  final Duration totalDuration;
  final Duration remainingDuration;
  final bool isWarning;

  const AnimatedProgressTimer({
    super.key,
    required this.totalDuration,
    required this.remainingDuration,
    this.isWarning = false,
  });

  @override
  State<AnimatedProgressTimer> createState() => _AnimatedProgressTimerState();
}

class _AnimatedProgressTimerState extends State<AnimatedProgressTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _warningController;
  late Animation<double> _warningAnimation;

  @override
  void initState() {
    super.initState();

    _warningController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _warningAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _warningController,
      curve: Curves.easeInOut,
    ));

    if (widget.isWarning) {
      _warningController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedProgressTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isWarning && !oldWidget.isWarning) {
      _warningController.repeat(reverse: true);
    } else if (!widget.isWarning && oldWidget.isWarning) {
      _warningController.stop();
      _warningController.reset();
    }
  }

  @override
  void dispose() {
    _warningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalDuration.inMilliseconds > 0
        ? (widget.totalDuration.inMilliseconds -
                widget.remainingDuration.inMilliseconds) /
            widget.totalDuration.inMilliseconds
        : 0.0;

    return AnimatedBuilder(
      animation: _warningAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isWarning ? _warningAnimation.value : 1.0,
          child: Row(
            children: [
              Icon(
                Icons.timer,
                color: widget.isWarning
                    ? Colors.orange
                    : MnemonicsColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Text(
                _formatDuration(widget.remainingDuration),
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: widget.isWarning
                      ? Colors.orange
                      : MnemonicsColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0.0, end: progress),
                  builder: (context, animatedProgress, child) {
                    return LinearProgressIndicator(
                      value: animatedProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isWarning
                            ? Colors.orange
                            : MnemonicsColors.primaryGreen,
                      ),
                      minHeight: 6,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
