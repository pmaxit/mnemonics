import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../../common/widgets/course_card.dart';
import 'package:go_router/go_router.dart';
import '../../providers.dart';
import 'dart:math';
import '../../../../common/widgets/animated_wave_background.dart';
import '../../../profile/providers/user_info_provider.dart';
import '../../../profile/domain/user_info.dart';
import '../widgets/knowledge_tree_widget.dart';
import '../../../profile/providers/profile_statistics_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  static const List<String> _tabRoutes = ['/learn', '/progress', '/profile'];
  static const List<String> _quotes = [
    'Small steps every day lead to big results.',
    'Consistency is the key to mastery.',
    'Mistakes are proof that you are trying.',
    'Learning never exhausts the mind.',
    'Push yourself, because no one else is going to do it for you.'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  static const List<IconData> setIcons = [
    Icons.book,
    Icons.star,
    Icons.school,
  ];
  static const List<Color> accentColors = [
    MnemonicsColors.primaryGreen,
    MnemonicsColors.secondaryOrange,
    MnemonicsColors.progressPink,
  ];

  String _getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  Widget _buildAnimatedHeader(bool isDarkMode) {
    final userInfoAsync = ref.watch(currentUserProvider);
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      margin: const EdgeInsets.all(MnemonicsSpacing.m),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vocabulary Learning',
                      style: MnemonicsTypography.headingMedium.copyWith(
                        color: isDarkMode
                            ? MnemonicsColors.darkTextPrimary
                            : MnemonicsColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Master words through mnemonics',
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
          const SizedBox(height: MnemonicsSpacing.m),
          userInfoAsync.when(
            data: (userInfo) => Container(
              padding: const EdgeInsets.all(MnemonicsSpacing.m),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MnemonicsColors.primaryGreen.withOpacity(0.8),
                    MnemonicsColors.secondaryOrange.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, ${userInfo.displayName.split(' ').first}!',
                          style: MnemonicsTypography.headingMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: MnemonicsSpacing.xs),
                        Text(
                          'Ready to expand your vocabulary?',
                          style: MnemonicsTypography.bodyRegular.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(MnemonicsSpacing.s),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(MnemonicsSpacing.radiusM),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Stack(
      children: [
        // Full-screen animated background
        AnimatedWaveBackground(height: screenHeight),
        // Main content
        Column(
          children: [
            // Animated Header (only this slides up)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildAnimatedHeader(isDarkMode),
                  ),
                );
              },
            ),
            // Card Content (static)
            Expanded(
              child: wordSetsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (sets) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: MnemonicsSpacing.m),
                    children: [
                      // Knowledge Tree Header Widget
                      statsAsync.when(
                        data: (stats) {
                          return Padding(
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
                            padding: const EdgeInsets.all(MnemonicsSpacing.m),
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
                                        style: MnemonicsTypography.bodyLarge
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: MnemonicsColors
                                                    .primaryGreen),
                                      ),
                                      Text(
                                        'Let\'s conquer "${suggestedCategory.categoryName}" next.',
                                        style: MnemonicsTypography.bodyRegular,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Normally navigate to practice with this category filter
                                    GoRouter.of(context).push('/learn');
                                  },
                                  icon: const Icon(Icons.arrow_forward_ios,
                                      color: MnemonicsColors.primaryGreen,
                                      size: 16),
                                ),
                              ],
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

                      ...sets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final set = entry.value;
                        final accent =
                            accentColors[index % accentColors.length];
                        final icon = setIcons[index % setIcons.length];

                        return _buildAnimatedCard(
                          set: set,
                          accent: accent,
                          icon: icon,
                          isDarkMode: isDarkMode,
                          index: index,
                        );
                      }),
                      const SizedBox(height: MnemonicsSpacing.xl),
                    ],
                  );
                },
              ),
            ),
          ],
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
