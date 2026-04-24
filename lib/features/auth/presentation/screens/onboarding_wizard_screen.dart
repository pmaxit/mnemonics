import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../features/study_session/providers/study_session_providers.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedGoal;
  int _correctAnswers = 0;
  final int _totalQuizQuestions = 5;
  int _questionsAnswered = 0;
  bool _isGeneratingPlan = false;

  final List<Map<String, String>> _goals = [
    {'id': 'sat', 'title': 'SAT Prep', 'desc': 'Master high-frequency college entrance words.'},
    {'id': 'gre', 'title': 'GRE Prep', 'desc': 'Advanced academic vocabulary for grad school.'},
    {'id': 'phrases', 'title': 'Common Phrases', 'desc': 'Useful collocations & phrasal verbs.'},
    {'id': 'emotions', 'title': 'Emotions', 'desc': 'Words about feelings & emotional states.'},
    {'id': 'character', 'title': 'Character', 'desc': 'Words about personality & traits.'},
    {'id': 'intellect', 'title': 'Intellect', 'desc': 'Words about thinking & knowledge.'},
    {'id': 'power', 'title': 'Power', 'desc': 'Words about authority & control.'},
    {'id': 'morality', 'title': 'Morality', 'desc': 'Words about ethics & right vs wrong.'},
  ];

  // Mock quiz questions for assessment
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

    // 2. Update Profile & Curate Words via Agent
    await profileNotifier.curateAndCompleteOnboarding(
      userId: userId,
      goal: _selectedGoal ?? 'sat',
      score: _correctAnswers,
    );

    // 3. Create Study Plan
    try {
      final studyPlanRepo = ref.read(studyPlanRepositoryProvider);
      await studyPlanRepo.createStudyPlan(
        totalWords: 100,
        numDays: 20,
        wordsPerDay: 5,
        title: 'My First ${_selectedGoal?.toUpperCase()} Plan',
      );
    } catch (e) {
      // Log the error
    }

    if (mounted) {
      context.go('/main/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Welcome! Your plan is ready.', style: TextStyle(fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: MnemonicsColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(MnemonicsSpacing.m),
              child: _buildProgressBar(isDarkMode),
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
                  : (isDarkMode ? MnemonicsColors.darkBorder : Colors.grey.shade300),
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
          const Icon(Icons.auto_awesome_rounded, size: 80, color: MnemonicsColors.primaryGreen),
          const SizedBox(height: MnemonicsSpacing.xl),
          Text(
            'Master Your Vocabulary',
            style: MnemonicsTypography.headingLarge.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Text(
            'Personalized word lists, AI-powered study plans, and interactive practice sessions tailored to your level.',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
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
              color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Text(
            'We will tailor your word lists and plans based on your objective.',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.xl),
          Expanded(
            child: ListView.separated(
              itemCount: _goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: MnemonicsSpacing.m),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _selectedGoal == goal['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedGoal = goal['id']),
                  child: Container(
                    padding: const EdgeInsets.all(MnemonicsSpacing.m),
                    decoration: BoxDecoration(
                      color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                      border: Border.all(
                        color: isSelected
                            ? MnemonicsColors.primaryGreen
                            : (isDarkMode ? MnemonicsColors.darkBorder : Colors.transparent),
                        width: 2,
                      ),
                      boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
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
                                  color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                goal['desc']!,
                                style: MnemonicsTypography.bodyRegular.copyWith(
                                  color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: MnemonicsColors.primaryGreen),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildPrimaryButton('Continue', _selectedGoal != null ? _nextPage : null),
        ],
      ),
    );
  }

  Widget _buildQuizStep(bool isDarkMode) {
    final question = _quizQuestions[_questionsAnswered];
    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Assessment',
            style: MnemonicsTypography.headingMedium.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            'Question ${_questionsAnswered + 1} of $_totalQuizQuestions',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: MnemonicsColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.xl),
          Center(
            child: Text(
              'What is the best synonym for:',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
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
          const SizedBox(height: MnemonicsSpacing.xxl),
          ... (question['options'] as List<String>).map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDarkMode ? MnemonicsColors.darkBorder : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                    ),
                  ),
                  onPressed: () {
                    if (option == question['answer']) {
                      _correctAnswers++;
                    }
                    setState(() {
                      if (_questionsAnswered < _totalQuizQuestions - 1) {
                        _questionsAnswered++;
                      } else {
                        _nextPage();
                      }
                    });
                  },
                  child: Text(
                    option,
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultStep(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isGeneratingPlan) ...[
            const CircularProgressIndicator(color: MnemonicsColors.primaryGreen),
            const SizedBox(height: MnemonicsSpacing.xl),
            Text(
              'Creating your personalized plan...',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
              ),
            ),
          ] else ...[
            const Icon(Icons.emoji_events_rounded, size: 80, color: Color(0xFFFFD700)),
            const SizedBox(height: MnemonicsSpacing.xl),
            Text(
              'Assessment Complete!',
              style: MnemonicsTypography.headingLarge.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Text(
              'We have identified your level and prepared a custom roadmap for you.',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            _buildPrimaryButton('Enter Dashboard', _completeOnboarding),
          ],
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
          disabledBackgroundColor: MnemonicsColors.primaryGreen.withOpacity(0.5),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
