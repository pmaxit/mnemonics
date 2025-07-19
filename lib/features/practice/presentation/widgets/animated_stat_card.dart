import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import 'animated_progress_utils.dart';

class AnimatedStatCard extends StatefulWidget {
  final String label;
  final int value;
  final String? suffix;
  final Color? accentColor;
  final IconData? icon;
  final bool isAchievement;
  final VoidCallback? onTap;
  final int animationDelay;

  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
    this.accentColor,
    this.icon,
    this.isAchievement = false,
    this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _entryController;
  late AnimationController _hoverController;
  late AnimationController _achievementController;
  
  late Animation<double> _entryAnimation;
  late Animation<double> _countUpAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _achievementAnimation;

  bool _isHovered = false;
  bool _hasAnimated = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    // Entry animation controller
    _entryController = AnimationController(
      duration: AnimatedProgressUtils.dataAnimation,
      vsync: this,
    );
    
    // Hover animation controller
    _hoverController = AnimationController(
      duration: AnimatedProgressUtils.microInteraction,
      vsync: this,
    );
    
    // Achievement animation controller
    _achievementController = AnimationController(
      duration: AnimatedProgressUtils.celebration,
      vsync: this,
    );

    // Entry animation with delay
    _entryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: AnimatedProgressUtils.entryEasing,
    ));

    // Count-up animation
    _countUpAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // Hover animation
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: AnimatedProgressUtils.interactionEasing,
    ));

    // Achievement animation
    _achievementAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _achievementController,
      curve: AnimatedProgressUtils.celebrationEasing,
    ));

    // Start entry animation with delay - only once
    if (!_hasAnimated) {
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted && !_hasAnimated) {
          _hasAnimated = true;
          _entryController.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger achievement animation if value increased significantly
    if (widget.value > oldWidget.value && widget.isAchievement) {
      _achievementController.forward().then((_) {
        _achievementController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _hoverController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryAnimation,
        _hoverAnimation,
        _achievementAnimation,
      ]),
      builder: (context, child) {
        // Calculate transformations
        final entrySlide = Offset(0, 50 * (1 - _entryAnimation.value));
        final hoverScale = 1.0 + (_hoverAnimation.value * 0.02);
        final achievementScale = 1.0 + (_achievementAnimation.value * 0.1);
        
        // Calculate shadow
        final shadowProgress = _hoverAnimation.value;
        final boxShadow = BoxShadow.lerp(
          AnimatedProgressUtils.restingShadow.first,
          AnimatedProgressUtils.hoverShadow.first,
          shadowProgress,
        );

        return Transform.translate(
          offset: entrySlide,
          child: Transform.scale(
            scale: hoverScale * achievementScale,
            child: Opacity(
              opacity: _entryAnimation.value,
              child: MouseRegion(
                onEnter: (_) => _onHover(true),
                onExit: (_) => _onHover(false),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: TweenAnimationBuilder<Color?>(
                    duration: AnimatedProgressUtils.microInteraction,
                    tween: ColorTween(
                      begin: Colors.white,
                      end: _isHovered 
                          ? (widget.accentColor ?? MnemonicsColors.primaryGreen).withOpacity(0.02)
                          : Colors.white,
                    ),
                    builder: (context, color, child) {
                      return Container(
                        padding: const EdgeInsets.all(MnemonicsSpacing.l),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                          boxShadow: boxShadow != null ? [boxShadow] : null,
                          border: Border.all(
                            color: _isHovered
                                ? (widget.accentColor ?? MnemonicsColors.primaryGreen).withOpacity(0.3)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon with subtle animation
                            if (widget.icon != null) ...[
                              TweenAnimationBuilder<double>(
                                duration: AnimatedProgressUtils.microInteraction,
                                tween: Tween<double>(
                                  begin: 1.0,
                                  end: _isHovered ? 1.1 : 1.0,
                                ),
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: Icon(
                                      widget.icon!,
                                      size: 32,
                                      color: (widget.accentColor ?? MnemonicsColors.primaryGreen)
                                          .withOpacity(0.8),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: MnemonicsSpacing.s),
                            ],
                            
                            // Animated value with achievement glow
                            AnimatedProgressUtils.buildPulsingWidget(
                              animation: _achievementAnimation,
                              glowColor: widget.accentColor ?? MnemonicsColors.primaryGreen,
                              child: AnimatedProgressUtils.buildCountUpAnimation(
                                animation: _countUpAnimation,
                                targetValue: widget.value,
                                suffix: widget.suffix,
                                style: MnemonicsTypography.headingLarge.copyWith(
                                  color: widget.accentColor ?? MnemonicsColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: MnemonicsSpacing.s),
                            
                            // Label with subtle fade-in
                            AnimatedBuilder(
                              animation: _entryAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _entryAnimation.value,
                                  child: Text(
                                    widget.label,
                                    style: MnemonicsTypography.bodyRegular.copyWith(
                                      color: MnemonicsColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Special streak card with fire animation
class StreakCard extends StatefulWidget {
  final int streakCount;
  final int animationDelay;

  const StreakCard({
    super.key,
    required this.streakCount,
    this.animationDelay = 0,
  });

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _fireController;
  late Animation<double> _fireAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    _fireController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fireAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fireController,
      curve: Curves.easeInOut,
    ));

    // Start fire animation if streak is active
    if (widget.streakCount > 0) {
      _fireController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.streakCount > 0 && oldWidget.streakCount == 0) {
      _fireController.repeat(reverse: true);
    } else if (widget.streakCount == 0 && oldWidget.streakCount > 0) {
      _fireController.stop();
    }
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return AnimatedStatCard(
      label: '🔥 Day Streak',
      value: widget.streakCount,
      suffix: widget.streakCount == 1 ? ' day' : ' days',
      accentColor: widget.streakCount > 0 ? Colors.orange : Colors.grey,
      icon: widget.streakCount > 0 ? Icons.local_fire_department : Icons.local_fire_department_outlined,
      isAchievement: true,
      animationDelay: widget.animationDelay,
    );
  }
}

// Progress percentage card with circular progress
class ProgressPercentageCard extends StatefulWidget {
  final String label;
  final double percentage;
  final Color? accentColor;
  final int animationDelay;

  const ProgressPercentageCard({
    super.key,
    required this.label,
    required this.percentage,
    this.accentColor,
    this.animationDelay = 0,
  });

  @override
  State<ProgressPercentageCard> createState() => _ProgressPercentageCardState();
}

class _ProgressPercentageCardState extends State<ProgressPercentageCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: AnimatedProgressUtils.dataAnimation,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percentage / 100,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    Future.delayed(Duration(milliseconds: widget.animationDelay + 400), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return AnimatedStatCard(
      label: widget.label,
      value: widget.percentage.round(),
      suffix: '%',
      accentColor: widget.accentColor,
      animationDelay: widget.animationDelay,
    );
  }
}