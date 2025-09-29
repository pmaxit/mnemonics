import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../domain/vocabulary_word.dart';
import '../../../../common/design/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/infrastructure/user_word_data_repository.dart';
import '../../../home/domain/user_word_data.dart';
import '../../../home/domain/spaced_repetition.dart';
import '../../../profile/domain/user_statistics.dart';
import '../../../../common/widgets/animated_wave_background.dart';
import '../../../practice/domain/user_progress_service.dart';

class LearnWordDetailScreen extends ConsumerStatefulWidget {
  final List<VocabularyWord> words;
  final int initialIndex;
  const LearnWordDetailScreen({Key? key, required this.words, this.initialIndex = 0}) : super(key: key);

  @override
  ConsumerState<LearnWordDetailScreen> createState() => _LearnWordDetailScreenState();
}

class _LearnWordDetailScreenState extends ConsumerState<LearnWordDetailScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  TextEditingController? _notesController;
  bool _isLearned = false;
  DateTime? _nextReview;

  UserWordData? _userWordData;
  bool _loading = true;
  DateTime? _viewStartTime;
  bool _wordViewed = false;
  
  late AnimationController _pageAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _viewStartTime = DateTime.now();
    
    // Initialize animations
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _loadUserWordData();
    _trackWordView();
  }

  Future<void> _loadUserWordData() async {
    setState(() => _loading = true);
    final repo = ref.read(userWordDataRepositoryProvider);
    final word = widget.words[_currentIndex].word;
    final data = await repo.getUserWordData(word);
    setState(() {
      _userWordData = data;
      _notesController = TextEditingController(text: data?.notes ?? '');
      _isLearned = data?.isLearned ?? false;
      _nextReview = data?.nextReview;
      _loading = false;
    });
    
    // Initialize video player if video URL exists
    await _initializeVideo();
  }

  void _disposeVideoControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  Future<void> _initializeVideo() async {
    _disposeVideoControllers();
    
    final currentWord = widget.words[_currentIndex];
    if (currentWord.video != null && currentWord.video!.isNotEmpty) {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(currentWord.video!));
        await _videoController!.initialize();
        
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          aspectRatio: _videoController!.value.aspectRatio,
        );
        
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('Error initializing video: $e');
        _disposeVideoControllers();
      }
    }
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _contentAnimationController.dispose();
    _pageController.dispose();
    _notesController?.dispose();
    _disposeVideoControllers();
    super.dispose();
  } 

  void _onPageChanged(int index) async {
    // Track time spent on previous word
    if (_viewStartTime != null) {
      await _trackWordViewTime();
    }
    
    // Reset animations for new page
    _pageAnimationController.reset();
    _contentAnimationController.reset();
    
    setState(() {
      _currentIndex = index;
      _wordViewed = false;
      _viewStartTime = DateTime.now();
    });
    
    await _loadUserWordData();
    await _trackWordView();
    
    // Start animations for new page
    _pageAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.words[_currentIndex].word),
      ),
      body: Stack(
        children: [
          AnimatedWaveBackground(height: MediaQuery.of(context).size.height),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: widget.words.length,
                  itemBuilder: (context, index) {
                    final word = widget.words[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(MnemonicsSpacing.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(word.word, style: MnemonicsTypography.headingLarge),
                          const SizedBox(height: MnemonicsSpacing.m),
                          Text('Meaning:', style: MnemonicsTypography.bodyLarge),
                          Text(word.meaning, style: MnemonicsTypography.bodyRegular),
                          const SizedBox(height: MnemonicsSpacing.m),
                          Text('Meaning (Hindi):', style: MnemonicsTypography.bodyLarge),
                          const Text('हिंदी अर्थ यहाँ आएगा', style: MnemonicsTypography.bodyRegular),
                          const SizedBox(height: MnemonicsSpacing.m),
                          Text('Use in English sentence:', style: MnemonicsTypography.bodyLarge),
                          Text(word.example, style: MnemonicsTypography.bodyRegular),
                          const SizedBox(height: MnemonicsSpacing.l),
                          // Image
                          if (word.image != null && word.image!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                              child: Image.network(
                                word.image!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 160,
                                  color: MnemonicsColors.surface,
                                  child: const Center(child: Icon(Icons.broken_image, size: 48, color: MnemonicsColors.textSecondary)),
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: MnemonicsColors.surface,
                                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                              ),
                              child: const Center(
                                child: Icon(Icons.image, size: 48, color: MnemonicsColors.textSecondary),
                              ),
                            ),
                          const SizedBox(height: MnemonicsSpacing.m),
                          // Video Player
                          if (word.video != null && word.video!.isNotEmpty && _chewieController != null)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                                child: Chewie(controller: _chewieController!),
                              ),
                            )
                          else if (word.video != null && word.video!.isNotEmpty)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: MnemonicsColors.surface,
                                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          if (word.video != null && word.video!.isNotEmpty) 
                            const SizedBox(height: MnemonicsSpacing.m),
                          if (word.synonyms.isNotEmpty) ...[
                            Text('Synonyms:', style: MnemonicsTypography.bodyLarge),
                            Wrap(
                              spacing: 8,
                              children: word.synonyms.map((s) => Chip(label: Text(s))).toList(),
                            ),
                            const SizedBox(height: MnemonicsSpacing.m),
                          ],
                          if (word.antonyms.isNotEmpty) ...[
                            Text('Antonyms:', style: MnemonicsTypography.bodyLarge),
                            Wrap(
                              spacing: 8,
                              children: word.antonyms.map((a) => Chip(label: Text(a))).toList(),
                            ),
                          ],
                          const SizedBox(height: MnemonicsSpacing.l),
                          Text('Your Notes:', style: MnemonicsTypography.bodyLarge),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Add your notes or mnemonic...',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => _saveUserWordData(),
                          ),
                          const SizedBox(height: MnemonicsSpacing.m),
                          Row(
                            children: [
                              Checkbox(
                                value: _isLearned,
                                onChanged: (val) {
                                  setState(() {
                                    _isLearned = val ?? false;
                                  });
                                  _saveUserWordData();
                                },
                              ),
                              const Text('Mark as Learned'),
                            ],
                          ),
                          const SizedBox(height: MnemonicsSpacing.m),
                          _buildProgressInfo(),
                          const SizedBox(height: MnemonicsSpacing.m),
                          _buildSpacedRepetitionHint(),
                          if (_isLearned) ...[
                            const SizedBox(height: MnemonicsSpacing.m),
                            Text('How did you find this word?', style: MnemonicsTypography.bodyLarge),
                            const SizedBox(height: MnemonicsSpacing.s),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _handleReview(ReviewRating.hard),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Hard'),
                                  ),
                                ),
                                const SizedBox(width: MnemonicsSpacing.s),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _handleReview(ReviewRating.medium),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orangeAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Medium'),
                                  ),
                                ),
                                const SizedBox(width: MnemonicsSpacing.s),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _handleReview(ReviewRating.easy),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Easy'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // TODO: Add spaced repetition review actions
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo() {
    final word = widget.words[_currentIndex];
    
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: MnemonicsColors.surface,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        border: Border.all(color: MnemonicsColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Word Information',
            style: MnemonicsTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Row(
            children: [
              _buildInfoChip('Category', word.category, MnemonicsColors.primaryGreen),
              const SizedBox(width: MnemonicsSpacing.s),
              _buildInfoChip('Difficulty', word.difficulty.displayName, _getDifficultyColor(word.difficulty)),
            ],
          ),
          if (_userWordData != null) ...[
            const SizedBox(height: MnemonicsSpacing.s),
            Row(
              children: [
                _buildInfoChip('Reviews', '${_userWordData!.reviewCount}', MnemonicsColors.secondaryOrange),
                const SizedBox(width: MnemonicsSpacing.s),
                _buildInfoChip('Accuracy', '${(_userWordData!.accuracyRate * 100).toStringAsFixed(0)}%', 
                    _getAccuracyColor(_userWordData!.accuracyRate)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.s, vertical: MnemonicsSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: MnemonicsTypography.bodyRegular.copyWith(
          fontSize: 12,
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getDifficultyColor(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.basic:
        return Colors.green;
      case WordDifficulty.intermediate:
        return Colors.orange;
      case WordDifficulty.advanced:
        return Colors.red;
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSpacedRepetitionHint() {
    if (!_isLearned) {
      return const Text(
        'Mark this word as learned to start spaced repetition review.',
        style: MnemonicsTypography.bodyRegular,
      );
    }
    if (_nextReview != null) {
      final now = DateTime.now();
      final diff = _nextReview!.difference(now);
      String timeStr;
      if (diff.inDays > 0) {
        timeStr = '${diff.inDays} day(s)';
      } else if (diff.inHours > 0) {
        timeStr = '${diff.inHours} hour(s)';
      } else if (diff.inMinutes > 0) {
        timeStr = '${diff.inMinutes} minute(s)';
      } else {
        timeStr = 'now';
      }
      return Text(
        'Next review: $timeStr',
        style: MnemonicsTypography.bodyRegular.copyWith(color: MnemonicsColors.secondaryOrange),
      );
    }
    return const Text(
      'Spaced repetition will remind you to review this word soon.',
      style: MnemonicsTypography.bodyRegular,
    );
  }

  void _handleReview(ReviewRating rating) async {
    final now = DateTime.now();
    final next = SpacedRepetitionManager.calculateNextReview(now, rating);
    setState(() {
      _nextReview = next;
    });
    await _saveUserWordData();
    
    // Use enhanced progress service
    final progressService = ref.read(userProgressServiceProvider);
    final word = widget.words[_currentIndex].word;
    
    // Convert rating to enum for review activity
    final ratingEnum = ReviewDifficultyRating.values.firstWhere(
      (r) => r.name == rating.toString().split('.').last.toLowerCase(),
      orElse: () => ReviewDifficultyRating.medium,
    );
    await progressService.recordReviewActivity(word, ratingEnum);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Next review: ${_formatNextReview(next)}')),
      );
    }
  }

  String _formatNextReview(DateTime next) {
    final now = DateTime.now();
    final diff = next.difference(now);
    if (diff.inDays > 0) {
      return '${diff.inDays} day(s)';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour(s)';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute(s)';
    } else {
      return 'now';
    }
  }

  Future<void> _trackWordView() async {
    if (_wordViewed) return;
    
    // Simply mark this word as viewed without affecting learning statistics
    _wordViewed = true;
  }

  Future<void> _trackWordViewTime() async {
    if (_viewStartTime == null) return;
    
    final viewDuration = DateTime.now().difference(_viewStartTime!);
    if (viewDuration.inSeconds >= 5) {
      // Track extended viewing duration for analytics (without affecting learning statistics)
      // This could be used for engagement metrics but doesn't count as "learned"
    }
  }

  Future<void> _saveUserWordData() async {
    final repo = ref.read(userWordDataRepositoryProvider);
    final word = widget.words[_currentIndex];
    final now = DateTime.now();
    
    var data = _userWordData ?? UserWordData(
      word: word.word,
      notes: _notesController?.text ?? '',
      isLearned: _isLearned,
      nextReview: _nextReview,
    );
    
    data.notes = _notesController?.text ?? '';
    data.isLearned = _isLearned;
    data.nextReview = _nextReview;
    data.lastReviewedAt = now;
    
    if (data.firstLearnedAt == null && _isLearned) {
      data.firstLearnedAt = now;
    }
    
    await repo.saveOrUpdateUserWordData(data);
    
    // Update progress service
    final progressService = ref.read(userProgressServiceProvider);
    if (_isLearned) {
      await progressService.markWordAsLearned(word.word);
    }
  }

  Widget _buildAnimatedWordHeader(VocabularyWord word, bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * animation),
          child: Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MnemonicsColors.primaryGreen.withOpacity(0.8),
                  MnemonicsColors.secondaryOrange.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.word,
                        style: MnemonicsTypography.headingLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(MnemonicsSpacing.s),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MnemonicsSpacing.s),
                Row(
                  children: [
                    _buildHeaderChip(word.category, Colors.white.withOpacity(0.9)),
                    const SizedBox(width: MnemonicsSpacing.s),
                    _buildHeaderChip(word.difficulty.displayName, Colors.white.withOpacity(0.9)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.s,
        vertical: MnemonicsSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
      ),
      child: Text(
        text.toUpperCase(),
        style: MnemonicsTypography.bodyRegular.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(
    String title,
    String content,
    IconData icon,
    Color color,
    bool isDarkMode,
    double delay,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (delay * 200).round()),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              padding: const EdgeInsets.all(MnemonicsSpacing.m),
              decoration: BoxDecoration(
                color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
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
                        padding: const EdgeInsets.all(MnemonicsSpacing.xs),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: MnemonicsSpacing.s),
                      Text(
                        title,
                        style: MnemonicsTypography.bodyLarge.copyWith(
                          color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MnemonicsSpacing.s),
                  Text(
                    content,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 