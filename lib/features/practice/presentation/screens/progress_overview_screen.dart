import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/providers.dart';
import '../../../home/domain/vocabulary_word.dart';
import '../../../home/domain/user_word_data.dart';
import '../../../../common/design/design_system.dart';

class ProgressOverviewScreen extends ConsumerWidget {
  const ProgressOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabularyListProvider);
    final userDataAsync = ref.watch(allUserWordDataProvider);

    if (vocabAsync.isLoading || userDataAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vocabAsync.hasError || userDataAsync.hasError) {
      return Center(child: Text('Error loading progress data'));
    }
    final vocab = vocabAsync.asData?.value ?? [];
    final userData = userDataAsync.asData?.value ?? [];
    if (vocab.isEmpty) {
      return const Center(child: Text('No vocabulary data.'));
    }

    final learned = userData.where((d) => d.isLearned).toList();
    final totalLearned = learned.length;
    final today = DateTime.now();
    final learnedToday = learned.where((d) => d.nextReview != null && d.nextReview!.day == today.day && d.nextReview!.month == today.month && d.nextReview!.year == today.year).length;
    // Breakdown by stage (dummy logic for now)
    final newCount = vocab.length - totalLearned;
    final inProgressCount = 0; // Placeholder
    final masteredCount = totalLearned;
    // Breakdown by category
    final categories = <String, int>{};
    for (final w in learned) {
      final v = vocab.firstWhere(
        (vw) => vw.word == w.word,
        orElse: () => VocabularyWord(word: '', meaning: '', mnemonic: '', example: '', synonyms: [], antonyms: [], difficulty: '', category: '')
      );
      if (v != null) {
        categories[v.category] = (categories[v.category] ?? 0) + 1;
      }
    }
    // Breakdown by difficulty
    final difficulties = <String, int>{};
    for (final w in learned) {
      final v = vocab.firstWhere(
        (vw) => vw.word == w.word,
        orElse: () => VocabularyWord(word: '', meaning: '', mnemonic: '', example: '', synonyms: [], antonyms: [], difficulty: '', category: '')
      );
      if (v != null) {
        difficulties[v.difficulty] = (difficulties[v.difficulty] ?? 0) + 1;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress Overview', style: MnemonicsTypography.headingMedium),
          const SizedBox(height: MnemonicsSpacing.l),
          Row(
            children: [
              _buildStatCard('Total Learned', totalLearned.toString()),
              const SizedBox(width: MnemonicsSpacing.m),
              _buildStatCard('Learned Today', learnedToday.toString()),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          // Placeholder for chart
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
              boxShadow: MnemonicsColors.cardShadow,
            ),
            child: const Center(child: Text('Progress Chart (add fl_chart for real chart)')),
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          Text('Breakdown by Stage', style: MnemonicsTypography.bodyLarge),
          const SizedBox(height: MnemonicsSpacing.s),
          Row(
            children: [
              _buildStatCard('New', newCount.toString()),
              const SizedBox(width: MnemonicsSpacing.m),
              _buildStatCard('In Progress', inProgressCount.toString()),
              const SizedBox(width: MnemonicsSpacing.m),
              _buildStatCard('Mastered', masteredCount.toString()),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          Text('Breakdown by Category', style: MnemonicsTypography.bodyLarge),
          const SizedBox(height: MnemonicsSpacing.s),
          Wrap(
            spacing: 12,
            children: categories.entries.map((e) => _buildStatCard(e.key, e.value.toString())).toList(),
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          Text('Breakdown by Difficulty', style: MnemonicsTypography.bodyLarge),
          const SizedBox(height: MnemonicsSpacing.s),
          Wrap(
            spacing: 12,
            children: difficulties.entries.map((e) => _buildStatCard(e.key, e.value.toString())).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: MnemonicsColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: MnemonicsTypography.headingMedium.copyWith(color: MnemonicsColors.primaryGreen)),
          Text(label, style: MnemonicsTypography.bodyRegular.copyWith(color: MnemonicsColors.textSecondary)),
        ],
      ),
    );
  }
} 