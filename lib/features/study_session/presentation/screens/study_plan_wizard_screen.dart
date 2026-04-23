import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/study_session_providers.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';

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
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  int get _wordsPerDay => (_totalWords / _numDays).ceil();

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _createPlan();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _createPlan() async {
    await ref.read(studyPlanCreationProvider.notifier).createPlan(
          totalWords: _totalWords,
          numDays: _numDays,
          wordsPerDay: _wordsPerDay,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
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
        ref.read(studyPlanCreationProvider.notifier).reset();
        context.go('/main/practice');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Study plan created! Start practising below.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: MnemonicsColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor:
          isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
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
      body: creationState.isLoading
          ? _buildLoadingState(isDarkMode)
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.l),
              child: Column(
                children: [
                  const SizedBox(height: MnemonicsSpacing.m),
                  _buildStepIndicator(),
                  const SizedBox(height: MnemonicsSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildStepContent(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.m),
                  _buildBottomButtons(isDarkMode),
                  const SizedBox(height: MnemonicsSpacing.xl),
                ],
              ),
            ),
    );
  }

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
              'Analyzing vocabulary and building your personalized schedule.',
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

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final active = i == _step;
        final done = i < _step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
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

  Widget _buildStepContent(bool isDarkMode) {
    switch (_step) {
      case 0:
        return _StepCard(
          isDarkMode: isDarkMode,
          icon: Icons.format_list_numbered_rounded,
          title: 'How many words?',
          subtitle: 'Choose the total number of vocabulary words to master.',
          child: _buildWordSlider(isDarkMode),
        );
      case 1:
        return _StepCard(
          isDarkMode: isDarkMode,
          icon: Icons.calendar_month_rounded,
          title: 'Over how many days?',
          subtitle: 'Spread your learning at your own pace.',
          child: _buildDaysSlider(isDarkMode),
        );
      case 2:
      default:
        return _StepCard(
          isDarkMode: isDarkMode,
          icon: Icons.auto_awesome_rounded,
          title: 'Your plan summary',
          subtitle:
              'Our AI will assign the best words for each day based on difficulty.',
          child: _buildSummary(isDarkMode),
        );
    }
  }

  Widget _buildWordSlider(bool isDarkMode) {
    return Column(
      children: [
        Text(
          '$_totalWords',
          style: MnemonicsTypography.headingLarge.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
          ),
        ),
        Text(
          'words',
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: MnemonicsColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.xl),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: MnemonicsColors.primaryGreen,
            inactiveTrackColor: MnemonicsColors.textSecondary.withOpacity(0.1),
            thumbColor: MnemonicsColors.primaryGreen,
            overlayColor: MnemonicsColors.primaryGreen.withOpacity(0.12),
            trackHeight: 6,
          ),
          child: Slider(
            value: _totalWords.toDouble(),
            min: 10,
            max: 300,
            divisions: 29,
            onChanged: (v) => setState(() => _totalWords = v.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysSlider(bool isDarkMode) {
    return Column(
      children: [
        Text(
          '$_numDays',
          style: MnemonicsTypography.headingLarge.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
          ),
        ),
        Text(
          'days',
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: MnemonicsColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.xl),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: MnemonicsColors.primaryGreen,
            inactiveTrackColor: MnemonicsColors.textSecondary.withOpacity(0.1),
            thumbColor: MnemonicsColors.primaryGreen,
            overlayColor: MnemonicsColors.primaryGreen.withOpacity(0.12),
            trackHeight: 6,
          ),
          child: Slider(
            value: _numDays.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            onChanged: (v) => setState(() => _numDays = v.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryRow(isDarkMode, Icons.book_rounded, 'Total words', '$_totalWords words'),
        const SizedBox(height: MnemonicsSpacing.s),
        _summaryRow(isDarkMode, Icons.calendar_today_rounded, 'Duration', '$_numDays days'),
        const SizedBox(height: MnemonicsSpacing.s),
        _summaryRow(
            isDarkMode, Icons.today_rounded, 'Words per day', '~$_wordsPerDay words/day'),
        const SizedBox(height: MnemonicsSpacing.l),
        
        Text(
          'Plan Title (Optional)',
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        TextField(
          controller: _titleController,
          style: TextStyle(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
            hintText: 'e.g. TOEFL Prep, SAT Vocab...',
            hintStyle: TextStyle(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary.withOpacity(0.5) : MnemonicsColors.textSecondary.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.l),
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
                  'Gemini AI will mix difficulty levels to keep each day fresh and effective.',
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

  Widget _summaryRow(bool isDarkMode, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.m, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkBackground.withOpacity(0.5) : MnemonicsColors.surface,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      ),
      child: Row(
        children: [
          Icon(icon, color: MnemonicsColors.primaryGreen, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                  fontSize: 14,
                )),
          ),
          Text(value,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              )),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(bool isDarkMode) {
    final isLast = _step == 2;
    return Row(
      children: [
        if (_step > 0) ...[
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDarkMode ? MnemonicsColors.darkBorder : MnemonicsColors.textSecondary.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                  ),
                ),
                onPressed: _back,
                child: Text('Back',
                    style: TextStyle(
                        color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                        fontWeight: FontWeight.w600)),
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
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                ),
              ),
              onPressed: _next,
              child: Text(isLast ? 'Generate Plan ✨' : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final bool isDarkMode;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepCard({
    required this.isDarkMode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: MnemonicsColors.primaryGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          ),
          child: Icon(icon, color: MnemonicsColors.primaryGreen, size: 24),
        ),
        const SizedBox(height: MnemonicsSpacing.l),
        Text(
          title,
          style: MnemonicsTypography.headingMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        Text(
          subtitle,
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: MnemonicsColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.xl),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MnemonicsSpacing.l),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            boxShadow: isDarkMode
                ? MnemonicsColors.darkCardShadow
                : MnemonicsColors.cardShadow,
            border: isDarkMode
                ? Border.all(
                    color: MnemonicsColors.darkBorder.withOpacity(0.3), width: 1)
                : null,
          ),
          child: child,
        ),
      ],
    );
  }
}
