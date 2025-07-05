import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/bottom_nav.dart';
import '../../../../common/widgets/course_card.dart';
import 'package:go_router/go_router.dart';
import '../../providers.dart';
import 'dart:math';
import 'learn_word_list_screen.dart';
import '../../../home/providers.dart';
import '../../infrastructure/word_set_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<String> _tabRoutes = ['/learn', '/progress', '/profile'];
  static const List<String> _quotes = [
    'Small steps every day lead to big results.',
    'Consistency is the key to mastery.',
    'Mistakes are proof that you are trying.',
    'Learning never exhausts the mind.',
    'Push yourself, because no one else is going to do it for you.'
  ];

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordSetsAsync = ref.watch(wordSetListProvider);
    return Container(
      color: MnemonicsColors.surface,
      child: wordSetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sets) {
          return GridView.builder(
            padding: const EdgeInsets.all(MnemonicsSpacing.xl),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: MnemonicsSpacing.xl,
              crossAxisSpacing: MnemonicsSpacing.xl,
              childAspectRatio: 1.1,
            ),
            itemCount: sets.length,
            itemBuilder: (context, i) {
              final set = sets[i];
              final accent = accentColors[i % accentColors.length];
              final icon = setIcons[i % setIcons.length];
              return Container(
                decoration: BoxDecoration(
                  color: MnemonicsColors.background,
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                  boxShadow: MnemonicsColors.cardShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                    onTap: () {
                      GoRouter.of(context).push('/word-list/${set.id}');
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(MnemonicsSpacing.radiusXL),
                              bottomLeft: Radius.circular(MnemonicsSpacing.radiusXL),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(MnemonicsSpacing.l),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(set.name, style: MnemonicsTypography.headingMedium),
                                    Text(set.description, style: MnemonicsTypography.bodyRegular),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(icon, color: accent, size: 28),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
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
      margin: const EdgeInsets.symmetric(vertical: MnemonicsSpacing.m, horizontal: MnemonicsSpacing.m),
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