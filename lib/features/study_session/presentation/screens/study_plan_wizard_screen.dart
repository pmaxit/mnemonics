import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/study_session_providers.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';

// ---------------------------------------------------------------------------
// Goal presets the user can pick — each maps to (totalWords, numDays)
// ---------------------------------------------------------------------------
class _GoalPreset {
  final String emoji;
  final String title;
  final String subtitle;
  final int words;
  final int days;
  final int color;

  const _GoalPreset({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.words,
    required this.days,
    required this.color,
  });
}

final _goalPresets = [
  const _GoalPreset(
    emoji: '🚀',
    title: 'Quick Start',
    subtitle: '30 words in 5 days',
    words: 30,
    days: 5,
    color: 0xFF4CAF8F,
  ),
  const _GoalPreset(
    emoji: '📚',
    title: 'SAT Prep',
    subtitle: '100 words in 14 days',
    words: 100,
    days: 14,
    color: 0xFFF4A261,
  ),
  const _GoalPreset(
    emoji: '🎓',
    title: 'GRE Mastery',
    subtitle: '200 words in 30 days',
    words: 200,
    days: 30,
    color: 0xFF4CAF8F,
  ),
  const _GoalPreset(
    emoji: '⚡',
    title: 'Intensive',
    subtitle: '50 words in 3 days',
    words: 50,
    days: 3,
    color: 0xFFF4A261,
  ),
  const _GoalPreset(
    emoji: '🎯',
    title: 'Steady Builder',
    subtitle: '75 words in 10 days',
    words: 75,
    days: 10,
    color: 0xFFF8BBD0,
  ),
  const _GoalPreset(
    emoji: '🏆',
    title: 'Marathon',
    subtitle: '300 words in 45 days',
    words: 300,
    days: 45,
    color: 0xFF4CAF8F,
  ),
];

class _DifficultyOption {
  final String emoji;
  final String title;
  final String subtitle;
  final String value;
  final int color;

  const _DifficultyOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
  });
}

final _difficultyOptions = [
  const _DifficultyOption(
    emoji: '🌱',
    title: 'Gentle Start',
    subtitle: 'Easy words first, ramp up gradually',
    value: 'easy_start',
    color: 0xFF4CAF8F,
  ),
  const _DifficultyOption(
    emoji: '⚖️',
    title: 'Balanced',
    subtitle: 'Steady mix of all levels each day',
    value: 'balanced',
    color: 0xFFF4A261,
  ),
  const _DifficultyOption(
    emoji: '🔥',
    title: 'Challenging',
    subtitle: 'Hard words early, push your limits',
    value: 'challenging',
    color: 0xFFF8BBD0,
  ),
];

class _CommitmentOption {
  final String emoji;
  final String title;
  final String subtitle;
  final String value;
  final int color;

  const _CommitmentOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
  });
}

final _commitmentOptions = [
  const _CommitmentOption(
    emoji: '🍃',
    title: 'Light',
    subtitle: '~5 words/day — casual pace',
    value: 'light',
    color: 0xFF4CAF8F,
  ),
  const _CommitmentOption(
    emoji: '📖',
    title: 'Standard',
    subtitle: '~10 words/day — steady pace',
    value: 'standard',
    color: 0xFFF4A261,
  ),
  const _CommitmentOption(
    emoji: '💪',
    title: 'Intensive',
    subtitle: '~20 words/day — deep dive',
    value: 'intensive',
    color: 0xFFF8BBD0,
  ),
];

class StudyPlanWizardScreen extends ConsumerStatefulWidget {
  const StudyPlanWizardScreen({super.key});

  @override
  ConsumerState<StudyPlanWizardScreen> createState() =>
      _StudyPlanWizardScreenState();
}

class _StudyPlanWizardScreenState
    extends ConsumerState<StudyPlanWizardScreen> {
  int _step = 0;
  int _totalWords = 50;
  int _numDays = 7;
  String _difficultyPref = 'balanced';
  String _dailyCommitment = 'standard';
  bool _useCustomGoal = false;
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  int get _wordsPerDay => (_totalWords / _numDays).ceil();

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _createPlan();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _selectGoal(_GoalPreset preset) {
    setState(() {
      _totalWords = preset.words;
      _numDays = preset.days;
      _useCustomGoal = false;
    });
  }

  void _selectCustomGoal() {
    setState(() {
      _useCustomGoal = true;
    });
  }

  Future<void> _createPlan() async {
    await ref.read(studyPlanCreationProvider.notifier).createPlan(
          totalWords: _totalWords,
          numDays: _numDays,
          wordsPerDay: _wordsPerDay,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          difficultyPref: _difficultyPref,
          dailyCommitment: _dailyCommitment,
        );
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(studyPlanCreationProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    // Navigate to Practice tab and show success once plan is created
    ref.listen(studyPlanCreationProvider, (_, next) {
      if (next.createdPlan != null) {
        final planName = next.createdPlan!.title;

        context.go('/main/practice');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Study plan "$planName" created! Start practising below.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: MnemonicsColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );

        ref.read(studyPlanCreationProvider.notifier).reset();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(studyPlanCreationProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor:
          isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
            size: 20,
          ),
          onPressed: () => _step > 0 ? _back() : context.pop(),
        ),
        title: Text(
          'Create Study Plan',
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: creationState.isLoading
            ? _buildLoadingState(isDarkMode)
            : Column(
                children: [
                  // Fixed step indicator
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      MnemonicsSpacing.l,
                      MnemonicsSpacing.m,
                      MnemonicsSpacing.l,
                      MnemonicsSpacing.xl,
                    ),
                    child: _buildStepIndicator(),
                  ),
                  // Scrollable content — takes all remaining space
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(
                            MnemonicsSpacing.l,
                            0,
                            MnemonicsSpacing.l,
                            MnemonicsSpacing.l +
                                MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight -
                                  MnemonicsSpacing.l -
                                  MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: _buildStepContent(isDarkMode),
                          ),
                        );
                      },
                    ),
                  ),
                  // Fixed bottom bar — always visible, never overflows
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? MnemonicsColors.darkBackground
                          : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDarkMode
                              ? MnemonicsColors.darkBorder.withOpacity(0.2)
                              : MnemonicsColors.textSecondary.withOpacity(0.1),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      MnemonicsSpacing.l,
                      MnemonicsSpacing.m,
                      MnemonicsSpacing.l,
                      MnemonicsSpacing.m +
                          MediaQuery.of(context).viewPadding.bottom,
                    ),
                    child: _buildBottomButtons(isDarkMode),
                  ),
                ],
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading state — animated
  // ---------------------------------------------------------------------------
  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
              boxShadow: isDarkMode
                  ? MnemonicsColors.darkCardShadow
                  : MnemonicsColors.cardShadow,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: MnemonicsColors.primaryGreen,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.xl),
          Text(
            'AI is crafting your plan…',
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextPrimary
                  : MnemonicsColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.xl),
            child: Text(
              'Analyzing vocabulary, mixing difficulty levels, and building your personalized schedule.',
              textAlign: TextAlign.center,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: MnemonicsColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step indicator — 4 steps
  // ---------------------------------------------------------------------------
  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(4, (i) {
        final active = i == _step;
        final done = i < _step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
            decoration: BoxDecoration(
              color: done || active
                  ? MnemonicsColors.primaryGreen
                  : MnemonicsColors.textSecondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Step content
  // ---------------------------------------------------------------------------
  Widget _buildStepContent(bool isDarkMode) {
    switch (_step) {
      case 0:
        return _buildGoalSelection(isDarkMode);
      case 1:
        return _buildDifficultySelection(isDarkMode);
      case 2:
        return _buildCommitmentSelection(isDarkMode);
      case 3:
      default:
        return _buildSummary(isDarkMode);
    }
  }

  // ── Step 0: Goal Selection ──────────────────────────────────────────────
  Widget _buildGoalSelection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          isDarkMode,
          icon: Icons.flag_rounded,
          title: 'What\'s your goal?',
          subtitle: 'Choose a preset or customize your own plan.',
        ),
        const SizedBox(height: MnemonicsSpacing.l),
        // Preset cards
        ..._goalPresets.map((preset) {
          final isSelected = !_useCustomGoal &&
              _totalWords == preset.words &&
              _numDays == preset.days;
          return Padding(
            padding: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
            child: _GoalCard(
              preset: preset,
              isSelected: isSelected,
              isDarkMode: isDarkMode,
              onTap: () => _selectGoal(preset),
            ),
          );
        }),
        const SizedBox(height: MnemonicsSpacing.m),
        // Custom goal section
        GestureDetector(
          onTap: _selectCustomGoal,
          child: Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.m),
            decoration: BoxDecoration(
              color: _useCustomGoal
                  ? MnemonicsColors.primaryGreen.withOpacity(0.08)
                  : (isDarkMode
                      ? MnemonicsColors.darkSurface
                      : Colors.white),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
              border: Border.all(
                color: _useCustomGoal
                    ? MnemonicsColors.primaryGreen
                    : (isDarkMode
                        ? MnemonicsColors.darkBorder.withOpacity(0.3)
                        : MnemonicsColors.textSecondary.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _useCustomGoal
                      ? Icons.check_circle_rounded
                      : Icons.tune_rounded,
                  color: _useCustomGoal
                      ? MnemonicsColors.primaryGreen
                      : (isDarkMode
                          ? MnemonicsColors.darkTextSecondary
                          : MnemonicsColors.textSecondary),
                  size: 24,
                ),
                const SizedBox(width: MnemonicsSpacing.m),
                Expanded(
                  child: Text(
                    'Custom Plan',
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: _useCustomGoal
                          ? MnemonicsColors.primaryGreen
                          : (isDarkMode
                              ? MnemonicsColors.darkTextPrimary
                              : MnemonicsColors.textPrimary),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$_totalWords words / $_numDays days',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: MnemonicsColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_useCustomGoal) ...[
          const SizedBox(height: MnemonicsSpacing.l),
          // Word count slider
          _buildSlider(
            isDarkMode: isDarkMode,
            label: 'Total Words',
            value: _totalWords.toDouble(),
            min: 10,
            max: 300,
            divisions: 29,
            onChanged: (v) => setState(() => _totalWords = v.round()),
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          // Days slider
          _buildSlider(
            isDarkMode: isDarkMode,
            label: 'Duration (days)',
            value: _numDays.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            onChanged: (v) => setState(() => _numDays = v.round()),
          ),
        ],
      ],
    );
  }

  // ── Step 1: Difficulty Selection ────────────────────────────────────────
  Widget _buildDifficultySelection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          isDarkMode,
          icon: Icons.trending_up_rounded,
          title: 'Difficulty Curve',
          subtitle: 'How should the plan ramp up over time?',
        ),
        const SizedBox(height: MnemonicsSpacing.l),
        ..._difficultyOptions.map((option) {
          final isSelected = _difficultyPref == option.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
            child: _OptionCard(
              emoji: option.emoji,
              title: option.title,
              subtitle: option.subtitle,
              isSelected: isSelected,
              color: Color(option.color),
              isDarkMode: isDarkMode,
              onTap: () => setState(() => _difficultyPref = option.value),
            ),
          );
        }),
      ],
    );
  }

  // ── Step 2: Commitment Level ────────────────────────────────────────────
  Widget _buildCommitmentSelection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          isDarkMode,
          icon: Icons.schedule_rounded,
          title: 'Daily Commitment',
          subtitle: 'How many words per day feels right?',
        ),
        const SizedBox(height: MnemonicsSpacing.l),
        ..._commitmentOptions.map((option) {
          final isSelected = _dailyCommitment == option.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
            child: _OptionCard(
              emoji: option.emoji,
              title: option.title,
              subtitle: option.subtitle,
              isSelected: isSelected,
              color: Color(option.color),
              isDarkMode: isDarkMode,
              onTap: () => setState(() => _dailyCommitment = option.value),
            ),
          );
        }),
        const SizedBox(height: MnemonicsSpacing.l),
        // Estimated XP preview
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          decoration: BoxDecoration(
            color: MnemonicsColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            border: Border.all(
                color: MnemonicsColors.primaryGreen.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars_rounded,
                  color: MnemonicsColors.primaryGreen, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potential XP: ~${_estimateXp()} XP',
                      style: MnemonicsTypography.bodyLarge.copyWith(
                        color: MnemonicsColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Review days every 4th day give bonus XP!',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: MnemonicsColors.primaryGreen,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _estimateXp() {
    return _totalWords * 2 + _numDays * 10;
  }

  // ── Step 3: Summary ──────────────────────────────────────────────────────
  Widget _buildSummary(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          isDarkMode,
          icon: Icons.auto_awesome_rounded,
          title: 'Your Plan Summary',
          subtitle: 'Review and generate your personalized study plan.',
        ),
        const SizedBox(height: MnemonicsSpacing.l),
        // Stats grid
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.l),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            boxShadow: isDarkMode
                ? MnemonicsColors.darkCardShadow
                : MnemonicsColors.cardShadow,
          ),
          child: Column(
            children: [
              _summaryRow(isDarkMode, Icons.book_rounded,
                  'Total Words', '$_totalWords'),
              const SizedBox(height: MnemonicsSpacing.s),
              _summaryRow(isDarkMode, Icons.calendar_today_rounded,
                  'Duration', '$_numDays days'),
              const SizedBox(height: MnemonicsSpacing.s),
              _summaryRow(isDarkMode, Icons.today_rounded,
                  'Words per Day', '~$_wordsPerDay'),
              const SizedBox(height: MnemonicsSpacing.s),
              _summaryRow(isDarkMode, Icons.trending_up_rounded,
                  'Difficulty', _difficultyPrefLabel),
              const SizedBox(height: MnemonicsSpacing.s),
              _summaryRow(isDarkMode, Icons.stars_rounded,
                  'Potential XP', '~${_estimateXp()} XP'),
            ],
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.l),
        // Title field
        Text(
          'Plan Title (Optional)',
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: isDarkMode
                ? MnemonicsColors.darkTextSecondary
                : MnemonicsColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        TextField(
          controller: _titleController,
          style: TextStyle(
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkMode
                ? MnemonicsColors.darkBackground
                : MnemonicsColors.surface,
            hintText: 'e.g. TOEFL Prep, SAT Vocab...',
            hintStyle: TextStyle(
              color: isDarkMode
                  ? MnemonicsColors.darkTextSecondary.withOpacity(0.5)
                  : MnemonicsColors.textSecondary.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.l),
        // AI insight box
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          decoration: BoxDecoration(
            color: MnemonicsColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            border: Border.all(
                color: MnemonicsColors.primaryGreen.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  color: MnemonicsColors.primaryGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI will mix difficulty levels, insert review days every 4th day, and assign XP rewards to keep you motivated.',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: MnemonicsColors.primaryGreen,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _difficultyPrefLabel {
    switch (_difficultyPref) {
      case 'easy_start':
        return 'Gentle Start';
      case 'challenging':
        return 'Challenging';
      default:
        return 'Balanced';
    }
  }

  // ── Reusable widgets ─────────────────────────────────────────────────────
  Widget _buildStepHeader(bool isDarkMode,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: MnemonicsColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          ),
          child: Icon(icon, color: MnemonicsColors.primaryGreen, size: 24),
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
                  fontSize: 18,
                  color: isDarkMode
                      ? MnemonicsColors.darkTextPrimary
                      : MnemonicsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: MnemonicsColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required bool isDarkMode,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode
                    ? MnemonicsColors.darkTextSecondary
                    : MnemonicsColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${value.round()}',
              style: MnemonicsTypography.bodyLarge.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDarkMode
                    ? MnemonicsColors.darkTextPrimary
                    : MnemonicsColors.textPrimary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: MnemonicsColors.primaryGreen,
            inactiveTrackColor:
                MnemonicsColors.textSecondary.withOpacity(0.1),
            thumbColor: MnemonicsColors.primaryGreen,
            overlayColor: MnemonicsColors.primaryGreen.withOpacity(0.12),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
      bool isDarkMode, IconData icon, String label, String value) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.m, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? MnemonicsColors.darkBackground.withOpacity(0.5)
            : MnemonicsColors.surface,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      ),
      child: Row(
        children: [
          Icon(icon, color: MnemonicsColors.primaryGreen, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode
                    ? MnemonicsColors.darkTextSecondary
                    : MnemonicsColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextPrimary
                  : MnemonicsColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(bool isDarkMode) {
    final isLast = _step == 3;
    return Row(
      children: [
        if (_step > 0) ...[
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: isDarkMode
                          ? MnemonicsColors.darkBorder
                          : MnemonicsColors.textSecondary.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(MnemonicsSpacing.radiusXL),
                  ),
                ),
                onPressed: _back,
                child: Text(
                  'Back',
                  style: TextStyle(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextPrimary
                          : MnemonicsColors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MnemonicsColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(MnemonicsSpacing.radiusXL),
                ),
              ),
              onPressed: _next,
              child: Text(
                isLast ? 'Generate Plan ✨' : 'Next',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Goal preset card widget
// ---------------------------------------------------------------------------
class _GoalCard extends StatelessWidget {
  final _GoalPreset preset;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _GoalCard({
    required this.preset,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(preset.color).withOpacity(0.08)
              : (isDarkMode ? MnemonicsColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          border: Border.all(
            color: isSelected
                ? Color(preset.color)
                : (isDarkMode
                    ? MnemonicsColors.darkBorder.withOpacity(0.3)
                    : MnemonicsColors.textSecondary.withOpacity(0.15)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(preset.color).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(preset.color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
              ),
              alignment: Alignment.center,
              child: Text(
                preset.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.title,
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: isSelected
                          ? Color(preset.color)
                          : (isDarkMode
                              ? MnemonicsColors.darkTextPrimary
                              : MnemonicsColors.textPrimary),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    preset.subtitle,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: MnemonicsColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: Color(preset.color), size: 24)
            else
              Icon(Icons.radio_button_unchecked_rounded,
                  color: MnemonicsColors.textSecondary.withOpacity(0.4),
                  size: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic option card
// ---------------------------------------------------------------------------
class _OptionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _OptionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : (isDarkMode ? MnemonicsColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          border: Border.all(
            color: isSelected
                ? color
                : (isDarkMode
                    ? MnemonicsColors.darkBorder.withOpacity(0.3)
                    : MnemonicsColors.textSecondary.withOpacity(0.15)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: isSelected
                          ? color
                          : (isDarkMode
                              ? MnemonicsColors.darkTextPrimary
                              : MnemonicsColors.textPrimary),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: MnemonicsColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 24)
            else
              Icon(Icons.radio_button_unchecked_rounded,
                  color: MnemonicsColors.textSecondary.withOpacity(0.4),
                  size: 24),
          ],
        ),
      ),
    );
  }
}
