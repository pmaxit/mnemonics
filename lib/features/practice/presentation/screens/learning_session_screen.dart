import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../domain/learning_session_models.dart';
import '../../providers/learning_session_provider.dart';
import '../widgets/session_setup_widget.dart';
import '../widgets/session_countdown_widget.dart';
import '../widgets/learning_flashcard_widget.dart';
import '../widgets/session_completion_widget.dart';
import '../../../../common/widgets/animated_wave_background.dart';

class LearningSessionScreen extends ConsumerStatefulWidget {
  const LearningSessionScreen({super.key});

  @override
  ConsumerState<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends ConsumerState<LearningSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeInOut,
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
    final sessionState = ref.watch(learningSessionProvider);
    final sessionNotifier = ref.watch(learningSessionProvider.notifier);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Stack(
      children: [
        AnimatedWaveBackground(height: screenHeight),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(sessionState, sessionNotifier),
          body: _buildBody(sessionState, sessionNotifier, isDarkMode),
        ),
      ],
    );
  }

  PreferredSizeWidget? _buildAppBar(LearningSessionState sessionState, LearningSession sessionNotifier) {
    switch (sessionState.phase) {
      case LearningSessionPhase.setup:
        return null;
      case LearningSessionPhase.active:
      case LearningSessionPhase.paused:
        return AppBar(
          title: const Text('Learning Session'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(sessionState.isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: () {
                if (sessionState.isPaused) {
                  sessionNotifier.resumeSession();
                } else {
                  sessionNotifier.pauseSession();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                _showEndSessionDialog(sessionNotifier);
              },
            ),
          ],
        );
      case LearningSessionPhase.countdown:
        return AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        );
      case LearningSessionPhase.completed:
        return AppBar(
          title: const Text('Session Complete'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        );
    }
  }

  Widget _buildBody(LearningSessionState sessionState, LearningSession sessionNotifier, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _pageAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pageAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _pageAnimation.value)),
            child: _buildCurrentPhase(sessionState, sessionNotifier, isDarkMode),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPhase(LearningSessionState sessionState, LearningSession sessionNotifier, bool isDarkMode) {
    switch (sessionState.phase) {
      case LearningSessionPhase.setup:
        return SessionSetupWidget(
          sessionState: sessionState,
          onDurationChanged: sessionNotifier.updateDuration,
          onModeChanged: sessionNotifier.updateMode,
          onStartSession: sessionNotifier.startSession,
          isDarkMode: isDarkMode,
        );
      case LearningSessionPhase.countdown:
        return SessionCountdownWidget(
          countdownSeconds: sessionState.countdownSeconds,
        );
      case LearningSessionPhase.active:
      case LearningSessionPhase.paused:
        return _buildActiveSession(sessionState, sessionNotifier);
      case LearningSessionPhase.completed:
        return SessionCompletionWidget(
          summary: sessionNotifier.getSessionSummary(),
          onNewSession: sessionNotifier.resetSession,
          onBackToProgress: () => Navigator.of(context).pop(),
        );
    }
  }

  Widget _buildActiveSession(LearningSessionState sessionState, LearningSession sessionNotifier) {
    if (sessionState.sessionWords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: MnemonicsColors.textSecondary,
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Text(
              'No words available for this session',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: MnemonicsColors.textSecondary,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.l),
            ElevatedButton(
              onPressed: sessionNotifier.resetSession,
              child: const Text('Back to Setup'),
            ),
          ],
        ),
      );
    }

    final currentWord = sessionState.currentWord!;
    final remainingTime = ref.watch(sessionRemainingTimeProvider);
    
    return Column(
      children: [
        // Timer and progress header
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          child: Column(
            children: [
              // Remaining time display
              remainingTime.when(
                data: (duration) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MnemonicsSpacing.m,
                    vertical: MnemonicsSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: duration.inMinutes < 2 
                        ? Colors.red.withOpacity(0.1)
                        : MnemonicsColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                    border: Border.all(
                      color: duration.inMinutes < 2 
                          ? Colors.red.withOpacity(0.3)
                          : MnemonicsColors.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        color: duration.inMinutes < 2 
                            ? Colors.red
                            : MnemonicsColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: MnemonicsSpacing.s),
                      Text(
                        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: MnemonicsTypography.headingMedium.copyWith(
                          color: duration.inMinutes < 2 
                              ? Colors.red
                              : MnemonicsColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: MnemonicsSpacing.m),
              
              // Progress indicators
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style: MnemonicsTypography.bodyRegular.copyWith(
                            color: MnemonicsColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: MnemonicsSpacing.xs),
                        LinearProgressIndicator(
                          value: sessionState.progress,
                          backgroundColor: MnemonicsColors.textSecondary.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(MnemonicsColors.primaryGreen),
                        ),
                        const SizedBox(height: MnemonicsSpacing.xs),
                        Text(
                          '${sessionState.currentWordIndex + 1} of ${sessionState.sessionWords.length}',
                          style: MnemonicsTypography.bodyRegular.copyWith(
                            color: MnemonicsColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: MnemonicsSpacing.l),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${sessionState.completedReviews.length}',
                        style: MnemonicsTypography.headingMedium.copyWith(
                          color: MnemonicsColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'reviewed',
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: MnemonicsColors.textSecondary,
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
        
        // Main flashcard area
        Expanded(
          child: LearningFlashcardWidget(
            word: currentWord,
            currentSide: sessionState.currentSide,
            onFlip: sessionNotifier.flipCard,
            onRate: sessionNotifier.rateCurrentWord,
            onSkip: sessionNotifier.skipCurrentWord,
            isRevealed: sessionState.isCardRevealed,
          ),
        ),
      ],
    );
  }

  void _showEndSessionDialog(LearningSession sessionNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to end this learning session early?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              sessionNotifier.resetSession();
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}