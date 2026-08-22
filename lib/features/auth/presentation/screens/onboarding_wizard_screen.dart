import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../features/study_session/providers/study_session_providers.dart';
import '../../../home/providers.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState
    extends ConsumerState<OnboardingWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedGoal;
  int _correctAnswers = 0;
  final int _totalQuizQuestions = 5;
  int _questionsAnswered = 0;
  bool _isGeneratingPlan = false;
  bool _isShowingFeedback = false;
  String? _selectedOption;

  final List<Map<String, String>> _goals = [
    {
      'id': 'character',
      'title': 'Character',
      'desc': 'Words about personality & traits.'
    },
    {
      'id': 'speech',
      'title': 'Speech',
      'desc': 'Words about communication & language.'
    },
    {
      'id': 'intellect',
      'title': 'Intellect',
      'desc': 'Words about thinking & knowledge.'
    },
    {
      'id': 'morality',
      'title': 'Morality',
      'desc': 'Words about ethics & right vs wrong.'
    },
    {
      'id': 'conflict',
      'title': 'Conflict',
      'desc': 'Words about opposition & struggle.'
    },
    {
      'id': 'change',
      'title': 'Change',
      'desc': 'Words about transformation & transition.'
    },
  ];

  // Assessment questions, ordered from beginner to advanced. The number of
  // correct answers determines the user's starting level:
  //   0-1 → Level 1 (Beginner), 2-3 → Level 2 (Intermediate),
  //   4-5 → Level 3 (Advanced).
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'level': 1,
      'word': 'Benevolent',
      'options': ['Kind', 'Angry', 'Fast', 'Broken'],
      'answer': 'Kind'
    },
    {
      'level': 2,
      'word': 'Diligent',
      'options': ['Lazy', 'Hardworking', 'Smart', 'Quiet'],
      'answer': 'Hardworking'
    },
    {
      'level': 3,
      'word': 'Ephemeral',
      'options': ['Eternal', 'Short-lived', 'Beautiful', 'Heavy'],
      'answer': 'Short-lived'
    },
    {
      'level': 4,
      'word': 'Sagacious',
      'options': ['Angry', 'Wise', 'Fragile', 'Talkative'],
      'answer': 'Wise'
    },
    {
      'level': 5,
      'word': 'Loquacious',
      'options': ['Silent', 'Greedy', 'Talkative', 'Brave'],
      'answer': 'Talkative'
    },
  ];

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Level derived from the assessment score (kept in sync with the backend
  /// /onboarding/curate thresholds).
  int get _assessedLevel {
    if (_correctAnswers >= 4) return 3;
    if (_correctAnswers >= 2) return 2;
    return 1;
  }

  String get _levelName {
    switch (_assessedLevel) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      default:
        return 'Advanced';
    }
  }

  void _answer(String? option) {
    if (_isShowingFeedback) return;
    final question = _quizQuestions[_questionsAnswered];
    final isCorrect = option == question['answer'];
    setState(() {
      _isShowingFeedback = true;
      _selectedOption = option;
      if (isCorrect) _correctAnswers++;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isShowingFeedback = false;
        _selectedOption = null;
        if (_questionsAnswered < _totalQuizQuestions - 1) {
          _questionsAnswered++;
        } else {
          _nextPage();
        }
      });
    });
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isGeneratingPlan = true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isGeneratingPlan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not authenticated')),
      );
      return;
    }

    final profileNotifier = ref.read(userProfileProvider.notifier);

    // 1. Update Profile & persist goal + assessed level on the server.
    await profileNotifier.curateAndCompleteOnboarding(
      userId: userId,
      goal: _selectedGoal ?? 'character',
      score: _correctAnswers,
    );

    // 2. Refresh cached data so Home + "My Words" reflect the new level.
    ref.invalidate(vocabularyListProvider);
    ref.invalidate(recommendedWordsProvider);
    ref.invalidate(activePlansProvider);

    // 3. Create a study plan scaled to the assessed level.
    final planSize = _planForLevel(_assessedLevel);
    try {
      final studyPlanRepo = ref.read(studyPlanRepositoryProvider);
      await studyPlanRepo.createStudyPlan(
        totalWords: planSize['totalWords']!,
        numDays: planSize['numDays']!,
        wordsPerDay: planSize['wordsPerDay']!,
        title: 'My First ${(_selectedGoal ?? 'character').toUpperCase()} Plan',
        difficultyPref: planSize['difficultyPref']!,
      );
    } catch (e) {
      // Plan creation is best-effort; the word list still works without it.
      print('Study plan creation failed: $e');
    }
    ref.invalidate(activePlansProvider);

    if (mounted) {
      context.go('/main/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Welcome! You start at $_levelName level — your words are ready.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          backgroundColor: MnemonicsColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// Plan size/difficulty scaled to the assessed level so beginners are not
  /// overwhelmed and advanced users get a real challenge.
  Map<String, dynamic> _planForLevel(int level) {
    switch (level) {
      case 1:
        return {
          'totalWords': 50,
          'numDays': 15,
          'wordsPerDay': 4,
          'difficultyPref': 'easy_start',
        };
      case 2:
        return {
          'totalWords': 75,
          'numDays': 15,
          'wordsPerDay': 5,
          'difficultyPref': 'balanced',
        };
      default:
        return {
          'totalWords': 100,
          'numDays': 20,
          'wordsPerDay': 5,
          'difficultyPref': 'challenging',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor:
          isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(MnemonicsSpacing.m),
              child: Row(
                children: [
                  if (_currentPage > 0 && _currentPage < 3)
                    IconButton(
                      onPressed: _isShowingFeedback ? null : _previousPage,
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: isDarkMode
                            ? MnemonicsColors.darkTextSecondary
                            : MnemonicsColors.textSecondary,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(child: _buildProgressBar(isDarkMode)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomeStep(isDarkMode),
                  _buildGoalStep(isDarkMode),
                  _buildQuizStep(isDarkMode),
                  _buildResultStep(isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isDarkMode) {
    return Row(
      children: List.generate(4, (index) {
        bool isActive = index <= _currentPage;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isActive
                  ? MnemonicsColors.primaryGreen
                  : (isDarkMode
                      ? MnemonicsColors.darkBorder
                      : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeStep(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 80, color: MnemonicsColors.primaryGreen),
          const SizedBox(height: MnemonicsSpacing.xl),
          Text(
            'Master Your Vocabulary',
            style: MnemonicsTypography.headingLarge.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextPrimary
                  : MnemonicsColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Text(
            'Personalized word lists, AI-powered study plans, and interactive practice sessions tailored to your level.',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextSecondary
                  : MnemonicsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _buildPrimaryButton('Get Started', _nextPage),
        ],
      ),
    );
  }

  Widget _buildGoalStep(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your goal?',
            style: MnemonicsTypography.headingMedium.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextPrimary
                  : MnemonicsColors.textPrimary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Text(
            'We will tailor your word lists and plans based on your objective.',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextSecondary
                  : MnemonicsColors.textSecondary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.xl),
          Expanded(
            child: ListView.separated(
              itemCount: _goals.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: MnemonicsSpacing.m),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _selectedGoal == goal['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedGoal = goal['id']),
                  child: Container(
                    padding: const EdgeInsets.all(MnemonicsSpacing.m),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? MnemonicsColors.darkSurface
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(MnemonicsSpacing.radiusXL),
                      border: Border.all(
                        color: isSelected
                            ? MnemonicsColors.primaryGreen
                            : (isDarkMode
                                ? MnemonicsColors.darkBorder
                                : Colors.transparent),
                        width: 2,
                      ),
                      boxShadow: isDarkMode
                          ? MnemonicsColors.darkCardShadow
                          : MnemonicsColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal['title']!,
                                style: MnemonicsTypography.bodyLarge.copyWith(
                                  color: isDarkMode
                                      ? MnemonicsColors.darkTextPrimary
                                      : MnemonicsColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                goal['desc']!,
                                style: MnemonicsTypography.bodyRegular.copyWith(
                                  color: isDarkMode
                                      ? MnemonicsColors.darkTextSecondary
                                      : MnemonicsColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: MnemonicsColors.primaryGreen),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildPrimaryButton(
              'Continue', _selectedGoal != null ? _nextPage : null),
        ],
      ),
    );
  }

  Widget _buildQuizStep(bool isDarkMode) {
    final question = _quizQuestions[_questionsAnswered];
    final correctAnswer = question['answer'] as String;
    final options = question['options'] as List<String>;
    final textColor = isDarkMode
        ? MnemonicsColors.darkTextPrimary
        : MnemonicsColors.textPrimary;
    final secondaryColor = isDarkMode
        ? MnemonicsColors.darkTextSecondary
        : MnemonicsColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Assessment',
            style: MnemonicsTypography.headingMedium.copyWith(
              color: textColor,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            'Answer honestly — this sets your starting level.',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _questionsAnswered / _totalQuizQuestions,
                    minHeight: 4,
                    backgroundColor: isDarkMode
                        ? MnemonicsColors.darkBorder
                        : Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(
                        MnemonicsColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Text(
                '${_questionsAnswered + 1} of $_totalQuizQuestions',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: MnemonicsColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.xl),
          Center(
            child: Text(
              'What is the best synonym for:',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Center(
            child: Text(
              question['word'],
              style: MnemonicsTypography.headingLarge.copyWith(
                color: MnemonicsColors.primaryGreen,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.xl),
          ...options.map((option) {
            final isSelected = _selectedOption == option;
            final isCorrect = option == correctAnswer;

            // Feedback colours once an answer is picked: green on the right
            // answer, red on a wrong pick.
            Color? borderColor;
            Color? fillColor;
            Color labelColor = textColor;
            if (_isShowingFeedback) {
              if (isCorrect) {
                borderColor = MnemonicsColors.primaryGreen;
                fillColor = MnemonicsColors.primaryGreen.withOpacity(0.1);
                labelColor = MnemonicsColors.primaryGreen;
              } else if (isSelected) {
                borderColor = Colors.redAccent;
                fillColor = Colors.redAccent.withOpacity(0.1);
                labelColor = Colors.redAccent;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: fillColor,
                    side: BorderSide(
                      color: borderColor ??
                          (isDarkMode
                              ? MnemonicsColors.darkBorder
                              : Colors.grey.shade300),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MnemonicsSpacing.radiusXL),
                    ),
                  ),
                  onPressed: _isShowingFeedback ? null : () => _answer(option),
                  child: Text(
                    option,
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: labelColor,
                      fontWeight: _isShowingFeedback && (isSelected || isCorrect)
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: MnemonicsSpacing.xs),
          // "I don't know" keeps the quiz honest and moving — counts as a
          // miss, exactly like a wrong answer.
          Center(
            child: TextButton(
              onPressed: _isShowingFeedback ? null : () => _answer(null),
              child: Text(
                'I don\'t know yet',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep(bool isDarkMode) {
    final textColor = isDarkMode
        ? MnemonicsColors.darkTextPrimary
        : MnemonicsColors.textPrimary;
    final secondaryColor = isDarkMode
        ? MnemonicsColors.darkTextSecondary
        : MnemonicsColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isGeneratingPlan) ...[
            const CircularProgressIndicator(
                color: MnemonicsColors.primaryGreen),
            const SizedBox(height: MnemonicsSpacing.xl),
            Text(
              'Creating your personalized plan...',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: textColor,
              ),
            ),
          ] else ...[
            const Icon(Icons.emoji_events_rounded,
                size: 72, color: Color(0xFFFFD700)),
            const SizedBox(height: MnemonicsSpacing.l),
            Text(
              'You\'re at $_levelName level',
              style: MnemonicsTypography.headingLarge.copyWith(
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: MnemonicsSpacing.l, vertical: MnemonicsSpacing.s),
              decoration: BoxDecoration(
                color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(MnemonicsSpacing.radiusXL),
              ),
              child: Text(
                'Score: $_correctAnswers of $_totalQuizQuestions correct',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: MnemonicsColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.l),
            Text(
              'Here\'s what we prepared for you:',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            _resultBullet(
              Icons.school_rounded,
              'My Words',
              'A word list matched to your ${_levelName.toLowerCase()} level, ready to practice.',
              secondaryColor,
            ),
            _resultBullet(
              Icons.calendar_month_rounded,
              'Study plan',
              'A ${_planForLevel(_assessedLevel)['totalWords']}-word roadmap across ${_planForLevel(_assessedLevel)['numDays']} days.',
              secondaryColor,
            ),
            _resultBullet(
              Icons.tune_rounded,
              'Full control',
              'Adjust your level and word sets anytime in Settings.',
              secondaryColor,
            ),
            const Spacer(),
            _buildPrimaryButton('Enter Dashboard', _completeOnboarding),
          ],
        ],
      ),
    );
  }

  Widget _resultBullet(
      IconData icon, String title, String desc, Color secondaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.s),
            decoration: BoxDecoration(
              color: MnemonicsColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            ),
            child: Icon(icon, color: MnemonicsColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: MnemonicsSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  desc,
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: secondaryColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MnemonicsColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          ),
          disabledBackgroundColor:
              MnemonicsColors.primaryGreen.withOpacity(0.4),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
