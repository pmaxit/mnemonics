import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../domain/timer_models.dart';
import '../../providers/timer_provider.dart';
import '../widgets/animated_timer_widgets.dart';
import '../widgets/animated_flash_card.dart';
import '../widgets/animated_progress_utils.dart';
import '../../../profile/providers/user_info_provider.dart';
import '../../../profile/domain/user_info.dart';
import '../../../../common/widgets/animated_wave_background.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: AnimatedProgressUtils.pageTransition,
      vsync: this,
    );
    
    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: AnimatedProgressUtils.entryEasing,
    ));
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _pageController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(timerSessionProvider);
    final sessionNotifier = ref.watch(timerSessionProvider.notifier);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        AnimatedWaveBackground(height: screenHeight),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(sessionState),
          body: _buildBody(sessionState, sessionNotifier),
        ),
      ],
    );
  }

  PreferredSizeWidget? _buildAppBar(TimerSessionState sessionState) {
    switch (sessionState.currentPhase) {
      case SessionPhase.setup:
        return null;
      case SessionPhase.active:
      case SessionPhase.paused:
        return AppBar(
          title: const Text('Timer Session'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(sessionState.isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: () {
                final notifier = ref.read(timerSessionProvider.notifier);
                if (sessionState.isPaused) {
                  notifier.resumeSession();
                } else {
                  notifier.pauseSession();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                _showEndSessionDialog();
              },
            ),
          ],
        );
      case SessionPhase.countdown:
        return AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        );
      case SessionPhase.completed:
        return AppBar(
          title: const Text('Session Complete'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        );
    }
  }

  Widget _buildBody(TimerSessionState sessionState, TimerSessionNotifier notifier) {
    switch (sessionState.currentPhase) {
      case SessionPhase.setup:
        return _buildSetupScreen(sessionState, notifier);
      case SessionPhase.countdown:
        return _buildCountdownScreen(notifier);
      case SessionPhase.active:
      case SessionPhase.paused:
        return _buildActiveSession(sessionState, notifier);
      case SessionPhase.completed:
        return _buildCompletedScreen(sessionState, notifier);
    }
  }

  Widget _buildSetupScreen(TimerSessionState sessionState, TimerSessionNotifier notifier) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    return AnimatedBuilder(
      animation: _pageAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pageAnimation.value,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: MnemonicsSpacing.l,
              right: MnemonicsSpacing.l,
              bottom: MnemonicsSpacing.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header matching Profile style
                _buildAnimatedHeader(sessionState, isDarkMode),
                
                const SizedBox(height: MnemonicsSpacing.xl),
                
                // Time Selection
                AnimatedTimeSelector(
                  presetMinutes: const [5, 10, 15, 30],
                  selectedMinutes: sessionState.selectedMinutes,
                  onTimeSelected: notifier.updateSelectedMinutes,
                  animationDelay: 200,
                ),
                
                const SizedBox(height: MnemonicsSpacing.xl),
                
                // Mode Selection
                AnimatedModeSelector(
                  modes: const [TimerMode.allWords, TimerMode.difficultOnly, TimerMode.newWords],
                  selectedMode: sessionState.studyMode,
                  onModeSelected: notifier.updateStudyMode,
                  animationDelay: 400,
                ),
                
                const SizedBox(height: MnemonicsSpacing.xl),
                
                // Start Button
                AnimatedProgressUtils.buildStaggeredAnimation(
                  animation: _pageAnimation,
                  index: 5,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => notifier.startSession(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MnemonicsColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: MnemonicsSpacing.l),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, size: 24),
                          const SizedBox(width: MnemonicsSpacing.s),
                          Text(
                            'Start ${sessionState.selectedMinutes}-Minute Session',
                            style: MnemonicsTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownScreen(TimerSessionNotifier notifier) {
    return AnimatedCountdown(
      onComplete: () {
        // Countdown complete, session will start automatically
      },
    );
  }

  Widget _buildActiveSession(TimerSessionState sessionState, TimerSessionNotifier notifier) {
    if (sessionState.sessionWords.isEmpty) {
      return const Center(
        child: Text('No words available for this session'),
      );
    }

    final currentWord = sessionState.sessionWords[sessionState.currentWordIndex];
    final remainingTime = ref.watch(sessionTimeRemainingProvider);
    
    return Column(
      children: [
        // Timer and progress
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          child: Column(
            children: [
              remainingTime.when(
                data: (duration) => AnimatedProgressTimer(
                  totalDuration: Duration(minutes: sessionState.selectedMinutes),
                  remainingDuration: duration,
                  isWarning: duration.inMinutes < 2,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: MnemonicsSpacing.s),
              
              // Progress indicator
              Row(
                children: [
                  Text(
                    'Current Word: ${sessionState.sessionWords[sessionState.currentWordIndex].word}',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: MnemonicsColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${sessionState.completedReviews.length} reviews',
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: MnemonicsColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${notifier.getUniqueWordsReviewed().length} unique words',
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: MnemonicsColors.secondaryOrange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Flash card
        Expanded(
          child: AnimatedFlashCard(
            word: currentWord,
            userWordData: null, // TODO: Get actual user word data if needed
            isRevealed: sessionState.isCardRevealed,
            onTap: () => notifier.revealCard(),
            onRate: (difficulty) => notifier.rateCurrentWord(difficulty),
            onSkip: () => notifier.skipCurrentWord(),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedScreen(TimerSessionState sessionState, TimerSessionNotifier notifier) {
    final summary = notifier.getSessionSummary();
    
    return AnimatedBuilder(
      animation: _pageAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pageAnimation.value,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            child: Column(
              children: [
                // Completion celebration
                AnimatedProgressUtils.buildStaggeredAnimation(
                  animation: _pageAnimation,
                  index: 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(MnemonicsSpacing.l),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MnemonicsColors.primaryGreen.withOpacity(0.1),
                          MnemonicsColors.secondaryOrange.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.celebration,
                          color: MnemonicsColors.primaryGreen,
                          size: 48,
                        ),
                        const SizedBox(height: MnemonicsSpacing.m),
                        Text(
                          'Session Complete!',
                          style: MnemonicsTypography.headingMedium.copyWith(
                            color: MnemonicsColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Great job on completing your study session!',
                          style: MnemonicsTypography.bodyRegular.copyWith(
                            color: MnemonicsColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: MnemonicsSpacing.xl),
                
                // Summary stats
                _buildSummaryStats(summary),
                
                const SizedBox(height: MnemonicsSpacing.xl),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => notifier.resetSession(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MnemonicsColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: MnemonicsSpacing.m),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                          ),
                        ),
                        child: const Text('New Session'),
                      ),
                    ),
                    const SizedBox(width: MnemonicsSpacing.m),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: MnemonicsSpacing.m),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                          ),
                        ),
                        child: const Text('Back to Progress'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStats(SessionSummary summary) {
    return Column(
      children: [
        // Main stats
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Words Reviewed',
                summary.wordsReviewed.toString(),
                Icons.book,
                MnemonicsColors.primaryGreen,
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(
              child: _buildSummaryCard(
                'Words/Min',
                summary.wordsPerMinute.toStringAsFixed(1),
                Icons.speed,
                MnemonicsColors.secondaryOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        // Difficulty breakdown
        _buildDifficultyBreakdown(summary.difficultyBreakdown),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: AnimatedProgressUtils.restingShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            value,
            style: MnemonicsTypography.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: MnemonicsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBreakdown(Map<ReviewDifficulty, int> breakdown) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: AnimatedProgressUtils.restingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Difficulty Breakdown',
            style: MnemonicsTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          Row(
            children: [
              Expanded(
                child: _buildDifficultyItem(
                  ReviewDifficulty.easy,
                  breakdown[ReviewDifficulty.easy] ?? 0,
                  Colors.green,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: _buildDifficultyItem(
                  ReviewDifficulty.medium,
                  breakdown[ReviewDifficulty.medium] ?? 0,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: _buildDifficultyItem(
                  ReviewDifficulty.hard,
                  breakdown[ReviewDifficulty.hard] ?? 0,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyItem(ReviewDifficulty difficulty, int count, Color color) {
    return Column(
      children: [
        Text(
          difficulty.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: MnemonicsSpacing.xs),
        Text(
          count.toString(),
          style: MnemonicsTypography.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          difficulty.displayName,
          style: MnemonicsTypography.bodyRegular.copyWith(
            fontSize: 12,
            color: MnemonicsColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to end this session early?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(timerSessionProvider.notifier).resetSession();
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(TimerSessionState sessionState, bool isDarkMode) {
    final userInfoAsync = ref.watch(currentUserProvider);
    
    return AnimatedBuilder(
      animation: _pageAnimation,
      builder: (context, child) {
        return AnimatedProgressUtils.buildStaggeredAnimation(
          animation: _pageAnimation,
          index: 0,
          child: Transform.translate(
            offset: Offset(0, -30 * (1 - _pageAnimation.value)),
            child: FadeTransition(
              opacity: _pageAnimation,
              child: Container(
                padding: const EdgeInsets.all(MnemonicsSpacing.l),
                decoration: BoxDecoration(
                  color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                  boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
                  border: isDarkMode
                      ? Border.all(
                          color: MnemonicsColors.darkBorder.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    // Animated timer icon
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, animation, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * animation),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  MnemonicsColors.secondaryOrange,
                                  MnemonicsColors.secondaryOrange.withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: MnemonicsColors.secondaryOrange.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.flash_on,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: MnemonicsSpacing.m),
                    // Content section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Study Session',
                            style: MnemonicsTypography.headingMedium.copyWith(
                              color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: MnemonicsSpacing.xs),
                          Text(
                            'Boost your vocabulary with focused flash cards',
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Time indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MnemonicsSpacing.s,
                        vertical: MnemonicsSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            color: MnemonicsColors.primaryGreen,
                            size: 16,
                          ),
                          const SizedBox(width: MnemonicsSpacing.xs),
                          Text(
                            '${sessionState.selectedMinutes}m',
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              color: MnemonicsColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}