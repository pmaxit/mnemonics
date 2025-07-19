import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../../domain/learning_session_models.dart';

class SessionCompletionWidget extends StatelessWidget {
  final LearningSessionSummary summary;
  final VoidCallback onNewSession;
  final VoidCallback onBackToProgress;

  const SessionCompletionWidget({
    super.key,
    required this.summary,
    required this.onNewSession,
    required this.onBackToProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        children: [
          // Celebration header
          _buildCelebrationHeader(),
          
          const SizedBox(height: MnemonicsSpacing.xl),
          
          // Main stats
          _buildMainStats(),
          
          const SizedBox(height: MnemonicsSpacing.l),
          
          // Detailed breakdown
          _buildDetailedBreakdown(),
          
          const SizedBox(height: MnemonicsSpacing.xl),
          
          // Performance insights
          if (summary.strugglingWords.isNotEmpty || summary.masteredWords.isNotEmpty)
            _buildPerformanceInsights(),
          
          const SizedBox(height: MnemonicsSpacing.xl),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCelebrationHeader() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animation),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MnemonicsSpacing.xl),
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
              border: Border.all(
                color: MnemonicsColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        MnemonicsColors.primaryGreen,
                        MnemonicsColors.primaryGreen.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: MnemonicsSpacing.m),
                Text(
                  'Session Complete!',
                  style: MnemonicsTypography.headingLarge.copyWith(
                    color: MnemonicsColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: MnemonicsSpacing.s),
                Text(
                  'Great job on completing your study session!',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: MnemonicsColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Words Reviewed',
            summary.wordsReviewed.toString(),
            Icons.book,
            MnemonicsColors.primaryGreen,
          ),
        ),
        const SizedBox(width: MnemonicsSpacing.m),
        Expanded(
          child: _buildStatCard(
            'Words/Min',
            summary.wordsPerMinute.toStringAsFixed(1),
            Icons.speed,
            MnemonicsColors.secondaryOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            value,
            style: MnemonicsTypography.headingLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: MnemonicsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Breakdown',
            style: MnemonicsTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          // Duration and unique words
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Duration',
                  '${summary.sessionDuration.inMinutes}:${(summary.sessionDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                  Icons.timer,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Unique Words',
                  summary.uniqueWordsReviewed.toString(),
                  Icons.bookmark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: MnemonicsSpacing.m),
          
          // Difficulty breakdown
          Text(
            'Difficulty Ratings',
            style: MnemonicsTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          
          Row(
            children: [
              Expanded(
                child: _buildDifficultyItem(
                  'Easy',
                  summary.difficultyBreakdown['easy'] ?? 0,
                  MnemonicsColors.primaryGreen,
                  '😊',
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: _buildDifficultyItem(
                  'Medium',
                  summary.difficultyBreakdown['medium'] ?? 0,
                  MnemonicsColors.secondaryOrange,
                  '😐',
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: _buildDifficultyItem(
                  'Hard',
                  summary.difficultyBreakdown['hard'] ?? 0,
                  Colors.red,
                  '😅',
                ),
              ),
            ],
          ),
          
          // Accuracy rate
          const SizedBox(height: MnemonicsSpacing.m),
          Row(
            children: [
              Text(
                'Accuracy Rate: ',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: MnemonicsColors.textSecondary,
                ),
              ),
              Text(
                '${(summary.accuracyRate * 100).toStringAsFixed(1)}%',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: summary.accuracyRate >= 0.7 
                      ? MnemonicsColors.primaryGreen 
                      : MnemonicsColors.secondaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: MnemonicsColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: MnemonicsSpacing.s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: MnemonicsTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              title,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: MnemonicsColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyItem(String title, int count, Color color, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: MnemonicsSpacing.s,
        horizontal: MnemonicsSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
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
            title,
            style: MnemonicsTypography.bodyRegular.copyWith(
              fontSize: 12,
              color: MnemonicsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInsights() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Insights',
            style: MnemonicsTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          if (summary.masteredWords.isNotEmpty) ...[
            _buildWordsList(
              'Words You\'re Mastering',
              summary.masteredWords,
              MnemonicsColors.primaryGreen,
              Icons.trending_up,
            ),
            if (summary.strugglingWords.isNotEmpty)
              const SizedBox(height: MnemonicsSpacing.m),
          ],
          
          if (summary.strugglingWords.isNotEmpty) ...[
            _buildWordsList(
              'Words to Focus On',
              summary.strugglingWords,
              MnemonicsColors.secondaryOrange,
              Icons.trending_down,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWordsList(String title, List<String> words, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: MnemonicsSpacing.s),
            Text(
              title,
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        Wrap(
          spacing: MnemonicsSpacing.s,
          runSpacing: MnemonicsSpacing.xs,
          children: words.take(10).map((word) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MnemonicsSpacing.s,
              vertical: MnemonicsSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Text(
              word,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
        if (words.length > 10) ...[
          const SizedBox(height: MnemonicsSpacing.xs),
          Text(
            '+${words.length - 10} more',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: MnemonicsColors.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onNewSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: MnemonicsColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: MnemonicsSpacing.m),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh, size: 20),
                const SizedBox(width: MnemonicsSpacing.s),
                const Text('New Session'),
              ],
            ),
          ),
        ),
        const SizedBox(width: MnemonicsSpacing.m),
        Expanded(
          child: OutlinedButton(
            onPressed: onBackToProgress,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: MnemonicsSpacing.m),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              ),
              side: BorderSide(
                color: MnemonicsColors.primaryGreen,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back, size: 20),
                const SizedBox(width: MnemonicsSpacing.s),
                const Text('Back'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}