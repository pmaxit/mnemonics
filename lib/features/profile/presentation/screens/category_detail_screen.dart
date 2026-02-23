import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../providers/detailed_statistics_provider.dart';
import 'detailed_word_statistics_screen.dart';
import '../../../../common/widgets/animated_wave_background.dart';
import 'package:go_router/go_router.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final String category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final categoryStatsAsync = ref.watch(categoryDetailedStatsProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        AnimatedWaveBackground(height: screenHeight),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('$category Category'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: categoryStatsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDarkMode
                        ? MnemonicsColors.darkTextSecondary
                        : MnemonicsColors.textSecondary,
                  ),
                  const SizedBox(height: MnemonicsSpacing.m),
                  Text(
                    'Error loading category data',
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextSecondary
                          : MnemonicsColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            data: (categoryStats) {
              final stats = categoryStats[category];
              if (stats == null) {
                return Center(
                  child: Text(
                    'Category not found',
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextSecondary
                          : MnemonicsColors.textSecondary,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(MnemonicsSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _buildHeaderCard(stats, isDarkMode),

                    const SizedBox(height: MnemonicsSpacing.l),

                    // Progress Overview
                    _buildProgressOverview(stats, isDarkMode),

                    const SizedBox(height: MnemonicsSpacing.l),

                    // Quick Actions
                    _buildQuickActions(context, isDarkMode),

                    const SizedBox(height: MnemonicsSpacing.l),

                    // Detailed Breakdown
                    _buildDetailedBreakdown(stats, isDarkMode),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(CategoryStats stats, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode
            ? MnemonicsColors.darkCardShadow
            : MnemonicsColors.cardShadow,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MnemonicsColors.primaryGreen.withOpacity(0.1),
            MnemonicsColors.secondaryOrange.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      MnemonicsColors.primaryGreen,
                      MnemonicsColors.primaryGreen.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(category),
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
                      category.toUpperCase(),
                      style: MnemonicsTypography.headingMedium.copyWith(
                        color: isDarkMode
                            ? MnemonicsColors.darkTextPrimary
                            : MnemonicsColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: MnemonicsSpacing.s),
                    Text(
                      'Vocabulary Category',
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

          const SizedBox(height: MnemonicsSpacing.l),

          // Main stats row
          Row(
            children: [
              Expanded(
                child: _buildMainStat(
                  'Total Words',
                  stats.totalWords.toString(),
                  Icons.library_books,
                  MnemonicsColors.primaryGreen,
                  isDarkMode,
                ),
              ),
              Expanded(
                child: _buildMainStat(
                  'Learned',
                  stats.learnedWords.toString(),
                  Icons.check_circle,
                  MnemonicsColors.success,
                  isDarkMode,
                ),
              ),
              Expanded(
                child: _buildMainStat(
                  'Accuracy',
                  '${(stats.averageAccuracy * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  MnemonicsColors.secondaryOrange,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStat(
      String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: MnemonicsSpacing.s),
        Text(
          value,
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: isDarkMode
                ? MnemonicsColors.darkTextSecondary
                : MnemonicsColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressOverview(CategoryStats stats, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode
            ? MnemonicsColors.darkCardShadow
            : MnemonicsColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Progress',
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextPrimary
                  : MnemonicsColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Progress',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextSecondary
                          : MnemonicsColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(stats.progressPercentage * 100).toStringAsFixed(1)}%',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: MnemonicsColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MnemonicsSpacing.s),
              ClipRRect(
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                child: LinearProgressIndicator(
                  value: stats.progressPercentage,
                  backgroundColor: isDarkMode
                      ? MnemonicsColors.darkBorder
                      : MnemonicsColors.textSecondary.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      MnemonicsColors.primaryGreen),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: MnemonicsSpacing.l),

          // Breakdown
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Mastered',
                  stats.learnedWords,
                  stats.totalWords,
                  MnemonicsColors.primaryGreen,
                  isDarkMode,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  'Struggling',
                  stats.strugglingWords,
                  stats.totalWords,
                  MnemonicsColors.warning,
                  isDarkMode,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  'Remaining',
                  stats.totalWords - stats.learnedWords,
                  stats.totalWords,
                  MnemonicsColors.textSecondary,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      String label, int count, int total, Color color, bool isDarkMode) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Column(
      children: [
        Text(
          count.toString(),
          style: MnemonicsTypography.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: isDarkMode
                ? MnemonicsColors.darkTextSecondary
                : MnemonicsColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: MnemonicsSpacing.xs),
        Text(
          '${(percentage * 100).toStringAsFixed(0)}%',
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode
            ? MnemonicsColors.darkCardShadow
            : MnemonicsColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextPrimary
                  : MnemonicsColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'View All Words',
                  Icons.list,
                  MnemonicsColors.primaryGreen,
                  () => _navigateToWordList(context, WordStatType.category),
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: _buildActionButton(
                  'Practice Category',
                  Icons.play_arrow,
                  MnemonicsColors.secondaryOrange,
                  () => _startCategoryPractice(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Struggling Words',
                  Icons.warning,
                  MnemonicsColors.warning,
                  () => _navigateToWordList(context, WordStatType.struggling),
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: _buildActionButton(
                  'New Words',
                  Icons.fiber_new,
                  MnemonicsColors.textSecondary,
                  () => _navigateToWordList(context, WordStatType.newWords),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      child: Container(
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: MnemonicsSpacing.s),
            Text(
              label,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedBreakdown(CategoryStats stats, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode
            ? MnemonicsColors.darkCardShadow
            : MnemonicsColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Breakdown',
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextPrimary
                  : MnemonicsColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          _buildBreakdownItem(
            'Words Mastered',
            '${stats.learnedWords} of ${stats.totalWords}',
            stats.progressPercentage,
            MnemonicsColors.primaryGreen,
            isDarkMode,
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          _buildBreakdownItem(
            'Average Accuracy',
            '${(stats.averageAccuracy * 100).toStringAsFixed(1)}%',
            stats.averageAccuracy,
            MnemonicsColors.secondaryOrange,
            isDarkMode,
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          _buildBreakdownItem(
            'Struggling Words',
            '${stats.strugglingWords} words',
            stats.totalWords > 0
                ? (stats.strugglingWords / stats.totalWords)
                : 0.0,
            MnemonicsColors.warning,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String title, String value, double progress,
      Color color, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode
                    ? MnemonicsColors.darkTextSecondary
                    : MnemonicsColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        ClipRRect(
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: isDarkMode
                ? MnemonicsColors.darkBorder
                : MnemonicsColors.textSecondary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return Icons.business;
      case 'technology':
        return Icons.computer;
      case 'science':
        return Icons.science;
      case 'arts':
        return Icons.palette;
      case 'general':
      default:
        return Icons.book;
    }
  }

  void _navigateToWordList(BuildContext context, WordStatType statType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailedWordStatisticsScreen(
          statType: statType,
          categoryFilter: category,
        ),
      ),
    );
  }

  void _startCategoryPractice(BuildContext context) {
    // Navigate to learning session with category filter
    context.go('/main/timer');
  }
}
