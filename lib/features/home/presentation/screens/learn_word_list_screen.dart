import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../../common/widgets/course_card.dart';
import '../../domain/vocabulary_word.dart';
import '../../../profile/domain/user_statistics.dart';
import 'package:go_router/go_router.dart';
import 'learn_word_detail_screen.dart';
import '../../infrastructure/word_set_repository.dart';
import '../../../../common/widgets/animated_wave_background.dart';

class LearnWordListScreen extends ConsumerStatefulWidget {
  final String setId;
  const LearnWordListScreen({super.key, required this.setId});

  @override
  ConsumerState<LearnWordListScreen> createState() => _LearnWordListScreenState();
}

class _LearnWordListScreenState extends ConsumerState<LearnWordListScreen>
    with TickerProviderStateMixin {
  String _search = '';
  String? _difficulty;
  String? _category;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
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

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    final vocabAsync = ref.watch(vocabularyListProvider);
    final vocabList = vocabAsync.asData?.value ?? [];
    final filtered = vocabList.where((word) {
      final matchesSet = word.setIds.contains(widget.setId);
      final matchesSearch = _search.isEmpty || word.word.toLowerCase().contains(_search.toLowerCase()) || word.meaning.toLowerCase().contains(_search.toLowerCase()) || word.mnemonic.toLowerCase().contains(_search.toLowerCase());
      final matchesDifficulty = _difficulty == null || word.difficulty == _difficulty;
      final matchesCategory = _category == null || word.category == _category;
      return matchesSet && matchesSearch && matchesDifficulty && matchesCategory;
    }).toList();
    final difficulties = vocabList.map((w) => w.difficulty).toSet().toList();
    final categories = vocabList.map((w) => w.category).toSet().toList();
    final accentColors = [MnemonicsColors.primaryGreen, MnemonicsColors.secondaryOrange, MnemonicsColors.progressPink];

    final wordSetsAsync = ref.watch(wordSetListProvider);
    String? setName;
    wordSetsAsync.whenData((sets) {
      setName = sets.firstWhere((s) => s.id == widget.setId, orElse: () => WordSet(id: '', name: '', description: '')).name;
    });

    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: wordSetsAsync.when(
          loading: () => const Text(''),
          error: (e, _) => const Text(''),
          data: (sets) {
            final set = sets.firstWhere((s) => s.id == widget.setId, orElse: () => WordSet(id: '', name: '', description: ''));
            return Text(set.name.isNotEmpty ? set.name : 'Word List');
          },
        ),
      ),
      body: Stack(
        children: [
          AnimatedWaveBackground(height: screenHeight),
          Container(
            color: Colors.transparent,
            child: Column(
              children: [
                // Animated Header (only this slides up)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildAnimatedHeader(setName ?? 'Word List', isDarkMode),
                      ),
                    );
                  },
                ),
                
                // Search Bar (static)
                Container(
                  margin: const EdgeInsets.all(MnemonicsSpacing.m),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search words, meanings, or mnemonics',
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                        borderSide: BorderSide(
                          color: isDarkMode 
                              ? MnemonicsColors.darkBorder.withOpacity(0.3)
                              : MnemonicsColors.surface,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                        borderSide: BorderSide(
                          color: MnemonicsColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(() => _search = value),
                  ),
                ),
                Expanded(
                  child: vocabAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (_) => filtered.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.l, vertical: MnemonicsSpacing.m),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: MnemonicsSpacing.m),
                            itemBuilder: (context, i) {
                              final word = filtered[i];
                              final accent = accentColors[i % accentColors.length];
                              return _buildWordCard(word, accent, i, filtered, isDarkMode);
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(String title, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(MnemonicsSpacing.m),
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
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
            padding: const EdgeInsets.all(MnemonicsSpacing.s),
            decoration: BoxDecoration(
              color: MnemonicsColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            ),
            child: Icon(
              Icons.library_books,
              color: MnemonicsColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: MnemonicsSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MnemonicsTypography.headingMedium.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap any word to start learning',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.s),
            decoration: BoxDecoration(
              color: MnemonicsColors.secondaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
            ),
            child: Icon(
              Icons.psychology,
              color: MnemonicsColors.secondaryOrange,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Transform.scale(
                scale: animation,
                child: Container(
                  padding: const EdgeInsets.all(MnemonicsSpacing.l),
                  decoration: BoxDecoration(
                    color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                  ),
                  child: Icon(
                    Icons.search_off,
                    size: 64,
                    color: MnemonicsColors.primaryGreen,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Text(
            'No words found',
            style: MnemonicsTypography.headingMedium.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            'Try adjusting your search terms',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(VocabularyWord word, Color accent, int index, List<VocabularyWord> filtered, bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, scaleAnimation, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
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
                HapticFeedback.lightImpact();
                context.push('/flashcards', extra: {
                  'words': filtered,
                  'initialIndex': index,
                });
              },
              child: Container(
                padding: const EdgeInsets.all(MnemonicsSpacing.m),
                child: Row(
                  children: [
                    // Animated icon
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, iconAnimation, child) {
                        return Transform.rotate(
                          angle: iconAnimation * 0.05,
                          child: Container(
                            padding: const EdgeInsets.all(MnemonicsSpacing.s),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  accent,
                                  accent.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: MnemonicsSpacing.m),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.word,
                            style: MnemonicsTypography.headingMedium.copyWith(
                              color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: MnemonicsSpacing.xs),
                          Text(
                            word.meaning,
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: MnemonicsSpacing.s),
                          // Difficulty indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: MnemonicsSpacing.s,
                              vertical: MnemonicsSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(word.difficulty).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                            ),
                            child: Text(
                              word.difficulty.displayName.toUpperCase(),
                              style: MnemonicsTypography.bodyRegular.copyWith(
                                color: _getDifficultyColor(word.difficulty),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
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
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
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
      },
    );
  }

  Color _getDifficultyColor(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.basic:
        return Colors.green;
      case WordDifficulty.intermediate:
        return MnemonicsColors.secondaryOrange;
      case WordDifficulty.advanced:
        return Colors.red;
    }
  }
} 