import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../../common/widgets/course_card.dart';
import '../../../../common/layout/tab_screen_layout.dart';
import '../../../../common/widgets/animated_tab_header_card.dart';
import 'package:go_router/go_router.dart';
import '../../providers.dart';
import 'dart:math';
import '../../../profile/providers/user_info_provider.dart';
import '../../../profile/domain/user_info.dart';
import '../../domain/word_recommendation.dart';
import '../widgets/knowledge_tree_widget.dart';
import '../../../profile/providers/profile_statistics_provider.dart';
import '../../infrastructure/user_word_data_repository.dart';
import '../../../auth/providers/user_profile_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const List<String> _quotes = [
    'Small steps every day lead to big results.',
    'Consistency is the key to mastery.',
    'Mistakes are proof that you are trying.',
    'Learning never exhausts the mind.',
    'Push yourself, because no one else is going to do it for you.'
  ];

  static const List<IconData> setIcons = [
    Icons.school,                // SAT
    Icons.menu_book,             // GRE
    Icons.favorite,              // Emotions
    Icons.person,                // Character
    Icons.record_voice_over,     // Speech
    Icons.psychology,            // Intellect
    Icons.flash_on,              // Conflict
    Icons.gavel,                 // Power
    Icons.balance,               // Morality
    Icons.rate_review,           // Criticism
    Icons.all_inclusive,         // Abundance
    Icons.autorenew,             // Change
    Icons.star,                  // MyList
    Icons.forum,                 // Phrases
  ];
  static const List<Color> accentColors = [
    Color(0xFF4CAF50),           // SAT — green
    Color(0xFFE91E63),           // GRE — pink
    Color(0xFFFF7043),           // Emotions — deep orange
    Color(0xFF26A69A),           // Character — teal
    Color(0xFF5C6BC0),           // Speech — indigo
    Color(0xFF7E57C2),           // Intellect — deep purple
    Color(0xFFEF5350),           // Conflict — red
    Color(0xFF455A64),           // Power — blue grey
    Color(0xFF66BB6A),           // Morality — light green
    Color(0xFFFFA726),           // Criticism — orange
    Color(0xFF42A5F5),           // Abundance — blue
    Color(0xFF26C6DA),           // Change — cyan
    Color(0xFFFFCA28),           // MyList — amber
    Color(0xFF673AB7),           // Phrases — deep purple
  ];

  String _getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  Widget _buildLogoLeading() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      child: Image.asset(
        'assets/images/logo.jpg',
        width: TabScreenLayout.leadingSize,
        height: TabScreenLayout.leadingSize,
        fit: BoxFit.cover,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // "My Words" — level-aware recommended practice list
  // ---------------------------------------------------------------------------
  String _levelLabel(String? vocabularyLevel) {
    final levels = WordRecommendation.parseLevels(vocabularyLevel);
    if (levels.length == 1) {
      switch (levels.first) {
        case 1:
          return 'Beginner';
        case 2:
          return 'Intermediate';
        default:
          return 'Advanced';
      }
    }
    return 'Levels ${levels.join(', ')}';
  }

  Widget _buildMyWordsSection(bool isDarkMode) {
    final settings = ref.watch(userSettingsProvider);
    if (settings == null || !settings.showMyWords) {
      return const SizedBox.shrink();
    }

    final recommendedAsync = ref.watch(recommendedWordsProvider);
    final profile = ref.watch(userProfileProvider).value;

    return recommendedAsync.when(
      loading: () => Container(
        margin: const EdgeInsets.only(bottom: TabScreenLayout.afterHeaderGap),
        padding: const EdgeInsets.all(MnemonicsSpacing.l),
        decoration: BoxDecoration(
          color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          boxShadow: isDarkMode
              ? MnemonicsColors.darkCardShadow
              : MnemonicsColors.cardShadow,
        ),
        child: const Center(
          child: CircularProgressIndicator(
              color: MnemonicsColors.primaryGreen),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (words) {
        if (words.isEmpty) return const SizedBox.shrink();

        final accent = const Color(0xFF7E57C2);
        final preview = words.take(3).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: TabScreenLayout.afterHeaderGap),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            boxShadow: isDarkMode
                ? MnemonicsColors.darkCardShadow
                : MnemonicsColors.cardShadow,
            border: isDarkMode
                ? Border.all(
                    color: MnemonicsColors.darkBorder.withOpacity(0.3),
                    width: 1)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
              onTap: () {
                HapticFeedback.lightImpact();
                GoRouter.of(context).push('/flashcards', extra: {
                  'words': words,
                  'initialIndex': 0,
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(MnemonicsSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(MnemonicsSpacing.s),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accent, accent.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(
                                MnemonicsSpacing.radiusL),
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: MnemonicsSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Words',
                                style: MnemonicsTypography.headingMedium
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? MnemonicsColors.darkTextPrimary
                                      : MnemonicsColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Personalized for you • ${_levelLabel(profile?.vocabularyLevel)}',
                                style:
                                    MnemonicsTypography.bodyRegular.copyWith(
                                  color: isDarkMode
                                      ? MnemonicsColors.darkTextSecondary
                                      : MnemonicsColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(
                                MnemonicsSpacing.radiusM),
                          ),
                          child: Text(
                            '${words.length} words',
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: MnemonicsSpacing.m),
                    Wrap(
                      spacing: MnemonicsSpacing.s,
                      runSpacing: MnemonicsSpacing.s,
                      children: [
                        ...preview.map((w) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.06)
                                    : MnemonicsColors.surface,
                                borderRadius: BorderRadius.circular(
                                    MnemonicsSpacing.radiusM),
                              ),
                              child: Text(
                                w.word,
                                style: MnemonicsTypography.bodyRegular
                                    .copyWith(
                                  color: isDarkMode
                                      ? MnemonicsColors.darkTextPrimary
                                      : MnemonicsColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            )),
                        if (words.length > preview.length)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  MnemonicsSpacing.radiusM),
                            ),
                            child: Text(
                              '+${words.length - preview.length} more',
                              style: MnemonicsTypography.bodyRegular.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: MnemonicsSpacing.m),
                    Row(
                      children: [
                        Icon(Icons.play_circle_filled_rounded,
                            color: accent, size: 20),
                        const SizedBox(width: MnemonicsSpacing.xs),
                        Text(
                          'Start practicing your level',
                          style: MnemonicsTypography.bodyRegular.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
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

  Widget _buildAnimatedHeader(bool isDarkMode) {
    final userInfoAsync = ref.watch(currentUserProvider);
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    final fallback = AnimatedTabHeaderCard(
      isDarkMode: isDarkMode,
      leading: _buildLogoLeading(),
      title: 'Vocabulary Learning',
      subtitle: 'Master words through mnemonics',
      trailing: const TabHeaderTrailingIcon(
        icon: Icons.auto_awesome,
        color: MnemonicsColors.secondaryOrange,
      ),
    );

    return userInfoAsync.when(
      data: (userInfo) => AnimatedTabHeaderCard(
        isDarkMode: isDarkMode,
        leading: _buildLogoLeading(),
        title: '$greeting, ${userInfo.displayName.split(' ').first}!',
        subtitle: 'Ready to expand your vocabulary?',
        trailing: const TabHeaderTrailingIcon(
          icon: Icons.auto_awesome,
          color: MnemonicsColors.secondaryOrange,
        ),
      ),
      loading: () => fallback,
      error: (error, stack) => fallback,
    );
  }

  Widget _buildAnimatedCard({
    required dynamic set,
    required Color accent,
    required IconData icon,
    required bool isDarkMode,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          onTap: () {
            // Add haptic feedback
            HapticFeedback.lightImpact();
            GoRouter.of(context).push('/word-list/${set.id}');
          },
          child: Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(MnemonicsSpacing.m),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent,
                        accent.withOpacity(0.7),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(MnemonicsSpacing.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: MnemonicsSpacing.l),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        set.name,
                        style: MnemonicsTypography.headingMedium.copyWith(
                          color: isDarkMode
                              ? MnemonicsColors.darkTextPrimary
                              : MnemonicsColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: MnemonicsSpacing.xs),
                      Text(
                        set.description,
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: isDarkMode
                              ? MnemonicsColors.darkTextSecondary
                              : MnemonicsColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: MnemonicsSpacing.s),
                      // Progress indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MnemonicsSpacing.s,
                          vertical: MnemonicsSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(MnemonicsSpacing.radiusM),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: accent,
                              size: 16,
                            ),
                            const SizedBox(width: MnemonicsSpacing.xs),
                            Text(
                              'Start Learning',
                              style: MnemonicsTypography.bodyRegular.copyWith(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Container(
                  padding: const EdgeInsets.all(MnemonicsSpacing.xs),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(MnemonicsSpacing.radiusS),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: accent,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordSetsAsync = ref.watch(wordSetListProvider);
    final statsAsync = ref
        .watch(profileStatisticsProvider); // Fetch real user stats for the Tree
    final vocabAsync = ref.watch(vocabularyListProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return ListView(
      padding: TabScreenLayout.paddedScrollPadding(context),
      children: [
        _buildAnimatedHeader(isDarkMode),
        const SizedBox(height: TabScreenLayout.afterHeaderGap),
        _buildMyWordsSection(isDarkMode),
        wordSetsAsync.when(
          loading: () => const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (sets) {
            final userProfile = ref.watch(userProfileProvider).value;
            final enabledSets = userProfile?.enabledWordSets
                    .split(',')
                    .where((s) => s.isNotEmpty)
                    .toSet() ??
                {};

            final filteredSets = sets.where((s) {
              if (enabledSets.isEmpty) return true;
              return enabledSets.contains(s.id);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                      // Knowledge Tree Header Widget
                      statsAsync.when(
                        data: (stats) {
                          return Padding(
                            key: TabScreenLayout.nextCardKey,
                            padding: const EdgeInsets.only(
                                bottom: MnemonicsSpacing.l),
                            child: KnowledgeTreeWidget(
                              totalLearned: stats.totalWordsLearned,
                              daysSinceLastPractice: stats.lastStudyDate != null
                                  ? DateTime.now()
                                      .difference(stats.lastStudyDate!)
                                      .inDays
                                  : 0,
                              masteredCategoriesCount: stats.masteredCategories,
                              onTreeTapped: () {
                                // Will trigger Tree Whisperer AI insight modal
                              },
                            ),
                          );
                        },
                        loading: () => const SizedBox(
                            key: TabScreenLayout.nextCardKey,
                            height: 250,
                            child: Center(child: CircularProgressIndicator())),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      // Smart Pathfinding (Next Category Suggestion)
                      statsAsync.when(
                        data: (stats) {
                          if (stats.categoryStats.isEmpty)
                            return const SizedBox.shrink();

                          // Find category with lowest accuracy or least learned words
                          var suggestedCategory = stats.categoryStats.first;
                          for (var cat in stats.categoryStats) {
                            if (cat.wordsLearned < cat.totalWords &&
                                (cat.averageAccuracy <
                                        suggestedCategory.averageAccuracy ||
                                    suggestedCategory.wordsLearned >=
                                        suggestedCategory.totalWords)) {
                              suggestedCategory = cat;
                            }
                          }

                          if (suggestedCategory.wordsLearned >=
                              suggestedCategory.totalWords) {
                            return const SizedBox.shrink(); // All mastered!
                          }

                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: MnemonicsSpacing.xl),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  MnemonicsColors.primaryGreen.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                  MnemonicsSpacing.radiusL),
                              border: Border.all(
                                  color: MnemonicsColors.primaryGreen
                                      .withOpacity(0.3)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    MnemonicsSpacing.radiusL),
                                onTap: () async {
                                  final vocab = vocabAsync.value ?? [];
                                  final categoryWords = vocab
                                      .where((w) =>
                                          w.category ==
                                          suggestedCategory.categoryName)
                                      .toList();

                                  if (categoryWords.isNotEmpty) {
                                    final repo = ref
                                        .read(userWordDataRepositoryProvider);
                                    final allData =
                                        await repo.getAllUserWordData();
                                    final learnedWords = allData
                                        .where((u) => u.isLearned)
                                        .map((u) => u.word)
                                        .toSet();

                                    final unlearnedWords = categoryWords
                                        .where((w) =>
                                            !learnedWords.contains(w.word))
                                        .toList();

                                    int initialIndex = 0;
                                    if (unlearnedWords.isNotEmpty) {
                                      final randomWord = unlearnedWords[Random()
                                          .nextInt(unlearnedWords.length)];
                                      initialIndex =
                                          categoryWords.indexOf(randomWord);
                                    }

                                    if (context.mounted) {
                                      context.push('/flashcards', extra: {
                                        'words': categoryWords,
                                        'initialIndex': initialIndex,
                                      });
                                    }
                                  } else {
                                    // Fallback to the main learning setup
                                    context.go('/main/timer');
                                  }
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(MnemonicsSpacing.m),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.assistant_direction,
                                          color: MnemonicsColors.primaryGreen,
                                          size: 32),
                                      const SizedBox(width: MnemonicsSpacing.m),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tree Needs Nutrients!',
                                              style: MnemonicsTypography
                                                  .bodyLarge
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: MnemonicsColors
                                                          .primaryGreen),
                                            ),
                                            Text(
                                              'Let\'s conquer "${suggestedCategory.categoryName}" next.',
                                              style: MnemonicsTypography
                                                  .bodyRegular,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios,
                                          color: MnemonicsColors.primaryGreen,
                                          size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      Text(
                        'Your Vocab Sets',
                        style: MnemonicsTypography.headingMedium.copyWith(
                          color: isDarkMode
                              ? Colors.white
                              : MnemonicsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: MnemonicsSpacing.m),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: filteredSets.length,
                  itemBuilder: (context, index) {
                    final set = filteredSets[index];
                    final accent = accentColors[index % accentColors.length];
                    final icon = setIcons[index % setIcons.length];

                    return _buildAnimatedCard(
                      set: set,
                      accent: accent,
                      icon: icon,
                      isDarkMode: isDarkMode,
                      index: index,
                    );
                  },
                ),
                const SizedBox(height: MnemonicsSpacing.xl),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(String quote) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What would you like',
                      style: MnemonicsTypography.headingMedium,
                    ),
                    Text(
                      'to learn today?',
                      style: MnemonicsTypography.headingMedium.copyWith(
                        color: MnemonicsColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLanguageSelector(),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Text(
            '"$quote"',
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: MnemonicsColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.s),
      decoration: BoxDecoration(
        color: MnemonicsColors.surface,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/us_flag.png',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: MnemonicsSpacing.xs),
          const Icon(
            Icons.arrow_drop_down,
            color: MnemonicsColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalProgress(int learnedToday, int dailyGoal) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: MnemonicsSpacing.m, horizontal: MnemonicsSpacing.m),
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: MnemonicsColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: MnemonicsColors.secondaryOrange,
                size: 32,
              ),
              const SizedBox(height: MnemonicsSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Learned Today',
                      style: MnemonicsTypography.bodyLarge,
                    ),
                    Text(
                      '$learnedToday / $dailyGoal words',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: MnemonicsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
            child: LinearProgressIndicator(
              value: learnedToday / (dailyGoal > 0 ? dailyGoal : 1),
              backgroundColor: MnemonicsColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                MnemonicsColors.secondaryOrange,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: MnemonicsSpacing.m,
      crossAxisSpacing: MnemonicsSpacing.m,
      childAspectRatio: 0.85,
      children: [
        CourseCard(
          languageName: 'Spanish Language',
          progressPercentage: 48,
          progressColor: MnemonicsColors.primaryGreen,
          onTap: () {},
        ),
        CourseCard(
          languageName: 'English Language',
          progressPercentage: 70,
          progressColor: MnemonicsColors.progressPink,
          onTap: () {},
        ),
        CourseCard(
          languageName: 'Turkish Language',
          progressPercentage: 60,
          progressColor: MnemonicsColors.secondaryOrange,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLessonTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lesson Types',
          style: MnemonicsTypography.headingMedium,
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: MnemonicsSpacing.m,
          crossAxisSpacing: MnemonicsSpacing.m,
          children: [
            _buildLessonTypeCard(
              icon: Icons.book_outlined,
              title: 'Reading',
              color: MnemonicsColors.primaryGreen,
            ),
            _buildLessonTypeCard(
              icon: Icons.edit_outlined,
              title: 'Writing',
              color: MnemonicsColors.progressPink,
            ),
            _buildLessonTypeCard(
              icon: Icons.headphones_outlined,
              title: 'Listening',
              color: MnemonicsColors.secondaryOrange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLessonTypeCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: MnemonicsColors.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: MnemonicsSpacing.xs),
          Text(
            title,
            style: MnemonicsTypography.bodyRegular,
          ),
        ],
      ),
    );
  }
}
