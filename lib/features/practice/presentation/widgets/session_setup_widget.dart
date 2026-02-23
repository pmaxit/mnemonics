import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../../domain/learning_session_models.dart';

class SessionSetupWidget extends StatelessWidget {
  final LearningSessionState sessionState;
  final Function(SessionDuration) onDurationChanged;
  final Function(SessionMode) onModeChanged;
  final Future<void> Function() onStartSession;
  final bool isDarkMode;
  final Animation<double>? fadeAnimation;
  final Animation<double>? slideAnimation;

  const SessionSetupWidget({
    super.key,
    required this.sessionState,
    required this.onDurationChanged,
    required this.onModeChanged,
    required this.onStartSession,
    required this.isDarkMode,
    this.fadeAnimation,
    this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (slideAnimation != null && fadeAnimation != null)
            AnimatedBuilder(
              animation: slideAnimation!,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, slideAnimation!.value),
                  child: FadeTransition(
                    opacity: fadeAnimation!,
                    child: child,
                  ),
                );
              },
              child: _buildHeader(),
            )
          else
            _buildHeader(),

          const SizedBox(height: MnemonicsSpacing.xl),

          // Duration Selection
          _buildDurationSelection(),

          const SizedBox(height: MnemonicsSpacing.xl),

          // Mode Selection
          _buildModeSelection(),

          const SizedBox(height: MnemonicsSpacing.xl),

          // Start Button
          _buildStartButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                color: MnemonicsColors.darkBorder.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MnemonicsColors.primaryGreen,
                  MnemonicsColors.primaryGreen.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: MnemonicsSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Session',
                  style: MnemonicsTypography.headingMedium.copyWith(
                    color: isDarkMode
                        ? MnemonicsColors.darkTextPrimary
                        : MnemonicsColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: MnemonicsSpacing.xs),
                Text(
                  'Enhance your vocabulary with smart flashcards',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: isDarkMode
                        ? MnemonicsColors.darkTextSecondary
                        : MnemonicsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Duration',
          style: MnemonicsTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        Text(
          'Choose how long you want to study',
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: MnemonicsColors.textSecondary,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),

        // Duration options
        Row(
          children: SessionDuration.values.map((duration) {
            final isSelected = sessionState.duration == duration;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: duration != SessionDuration.values.last
                      ? MnemonicsSpacing.s
                      : 0,
                ),
                child: GestureDetector(
                  onTap: () => onDurationChanged(duration),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: MnemonicsSpacing.m,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MnemonicsColors.primaryGreen
                          : (isDarkMode
                              ? MnemonicsColors.darkSurface
                              : Colors.white),
                      borderRadius:
                          BorderRadius.circular(MnemonicsSpacing.radiusL),
                      border: Border.all(
                        color: isSelected
                            ? MnemonicsColors.primaryGreen
                            : (isDarkMode
                                ? MnemonicsColors.darkBorder.withOpacity(0.3)
                                : MnemonicsColors.textSecondary
                                    .withOpacity(0.2)),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: MnemonicsColors.primaryGreen
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : (isDarkMode
                              ? MnemonicsColors.darkCardShadow
                              : MnemonicsColors.cardShadow),
                    ),
                    child: Column(
                      children: [
                        Text(
                          duration.displayText,
                          style: MnemonicsTypography.bodyLarge.copyWith(
                            color: isSelected
                                ? Colors.white
                                : (isDarkMode
                                    ? MnemonicsColors.darkTextPrimary
                                    : MnemonicsColors.textPrimary),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: MnemonicsSpacing.xs),
                        Text(
                          duration.description,
                          style: MnemonicsTypography.bodyRegular.copyWith(
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : MnemonicsColors.textSecondary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study Mode',
          style: MnemonicsTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        Text(
          'Select which words to focus on',
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: MnemonicsColors.textSecondary,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),

        // Mode options
        ...SessionMode.values.map((mode) {
          final isSelected = sessionState.mode == mode;
          return Padding(
            padding: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
            child: GestureDetector(
              onTap: () => onModeChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(MnemonicsSpacing.m),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MnemonicsColors.primaryGreen.withOpacity(0.1)
                      : (isDarkMode
                          ? MnemonicsColors.darkSurface
                          : Colors.white),
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                  border: Border.all(
                    color: isSelected
                        ? MnemonicsColors.primaryGreen
                        : (isDarkMode
                            ? MnemonicsColors.darkBorder.withOpacity(0.3)
                            : MnemonicsColors.textSecondary.withOpacity(0.2)),
                  ),
                  boxShadow: isDarkMode
                      ? MnemonicsColors.darkCardShadow
                      : MnemonicsColors.cardShadow,
                ),
                child: Row(
                  children: [
                    Icon(
                      _getModeIcon(mode),
                      color: isSelected
                          ? MnemonicsColors.primaryGreen
                          : MnemonicsColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: MnemonicsSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.title,
                            style: MnemonicsTypography.bodyLarge.copyWith(
                              color: isDarkMode
                                  ? MnemonicsColors.darkTextPrimary
                                  : MnemonicsColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            mode.description,
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              color: MnemonicsColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: MnemonicsColors.primaryGreen,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await onStartSession();
          } on StateError catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(MnemonicsSpacing.l),
                duration: const Duration(seconds: 4),
              ),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'An unexpected error occurred. Please try again.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(MnemonicsSpacing.l),
              ),
            );
          }
        },
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
              'Start ${sessionState.duration.displayText} Session',
              style: MnemonicsTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModeIcon(SessionMode mode) {
    switch (mode) {
      case SessionMode.allWords:
        return Icons.library_books;
      case SessionMode.dueForReview:
        return Icons.schedule;
      case SessionMode.strugglingWords:
        return Icons.trending_down;
      case SessionMode.newWords:
        return Icons.fiber_new;
    }
  }
}
