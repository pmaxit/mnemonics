import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../domain/vocabulary_word.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/infrastructure/user_word_data_repository.dart';
import '../../../home/domain/user_word_data.dart';
import '../../../home/domain/spaced_repetition.dart';
import '../../../profile/domain/user_statistics.dart';
import '../../../../common/widgets/animated_wave_background.dart';
import '../../../practice/domain/user_progress_service.dart';
import '../../../home/providers.dart';

import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../auth/infrastructure/auth_repository.dart';
import '../../../../core/config/api_config.dart';
import '../../../../common/widgets/vocabulary_word_image.dart';
import '../widgets/fill_in_blank_card.dart';

class LearnWordDetailScreen extends ConsumerStatefulWidget {
  final List<VocabularyWord> words;
  final int initialIndex;
  const LearnWordDetailScreen(
      {Key? key, required this.words, this.initialIndex = 0})
      : super(key: key);

  @override
  ConsumerState<LearnWordDetailScreen> createState() =>
      _LearnWordDetailScreenState();
}

class _LearnWordDetailScreenState extends ConsumerState<LearnWordDetailScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  TextEditingController? _notesController;
  bool _isLearned = false;
  DateTime? _nextReview;
  double _easeFactor = 2.5;
  int _interval = 0;
  int _repetitions = 0;

  UserWordData? _userWordData;
  bool _loading = true;
  DateTime? _viewStartTime;
  bool _wordViewed = false;

  final _translator = GoogleTranslator();
  String? _hindiMeaning;
  bool _loadingHindi = false;
  bool _isNotesDirty = false;
  bool _isSavingNotes = false;

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
    _loadHindiMeaning(widget.words[_currentIndex].meaning);
  }

  Future<void> _fetchCloudNotes(String word) async {
    final userId =
        ref.read(authRepositoryProvider).currentUser?.uid ?? 'default';
    try {
      final response = await http.get(Uri.parse(ApiConfig.notes(userId, word)));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['notes'] != null && data['notes'].toString().isNotEmpty) {
          if (mounted) {
            setState(() {
              _notesController?.text = data['notes'];
              _isNotesDirty = false;
            });
            // We should also sync it locally, but the prompt only focuses on DB sync.
          }
        }
      }
    } catch (e) {
      print('Failed to fetch cloud notes: $e');
    }
  }

  Future<void> _saveCloudNotes() async {
    final word = widget.words[_currentIndex].word;
    final notes = _notesController?.text ?? '';
    final userId =
        ref.read(authRepositoryProvider).currentUser?.uid ?? 'default';

    setState(() {
      _isSavingNotes = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.notes(userId, word)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'notes': notes}),
      );
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _isNotesDirty = false;
          _isSavingNotes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Notes saved to cloud!'),
              duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      print('Failed to save cloud notes: $e');
      if (mounted) {
        setState(() {
          _isSavingNotes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save notes.'),
              duration: Duration(seconds: 2)),
        );
      }
    }
  }

  Future<void> _fetchCloudLearnedStatus(String word) async {
    final userId =
        ref.read(authRepositoryProvider).currentUser?.uid ?? 'default';
    try {
      final response = await http.get(Uri.parse(ApiConfig.learnedStatus(userId, word)));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _isLearned = data['is_learned'] as bool? ?? false;
          });
        }
      }
    } catch (e) {
      print('Failed to fetch learned status: $e');
    }
  }

  Future<void> _saveCloudLearnedStatus(bool learned) async {
    final word = widget.words[_currentIndex].word;
    final userId =
        ref.read(authRepositoryProvider).currentUser?.uid ?? 'default';
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.learnedStatus(userId, word)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'is_learned': learned}),
      );
      if (response.statusCode != 200) {
        print(
            'Failed to save learned status to cloud. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to save cloud learned status: $e');
    }
  }

  Future<void> _loadHindiMeaning(String englishMeaning) async {
    setState(() {
      _hindiMeaning = null;
      _loadingHindi = true;
    });
    try {
      final translation = await _translator.translate(englishMeaning, to: 'hi');
      if (mounted) {
        setState(() {
          _hindiMeaning = translation.text;
          _loadingHindi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hindiMeaning = 'Translation failed';
          _loadingHindi = false;
        });
      }
    }
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
      _easeFactor = data?.easeFactor ?? 2.5;
      _interval = data?.interval ?? 0;
      _repetitions = data?.repetitions ?? 0;
      _loading = false;
    });

    _fetchCloudNotes(word);
    _fetchCloudLearnedStatus(word);

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
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(currentWord.video!));
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

    _loadHindiMeaning(widget.words[index].meaning);

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
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: (isDarkMode ? const Color(0xFF1A1A1A) : Colors.white)
                  .withOpacity(0.5),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.words[_currentIndex].word,
          style: MnemonicsTypography.headingMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: isDarkMode ? Colors.white : MnemonicsColors.textPrimary,
          ),
        ),
        actions: [
          if (widget.words.length > 1)
            IconButton(
              tooltip: 'Next word',
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onPressed: _goToNextWord,
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: const AnimatedWaveBackground(),
          ),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: widget.words.length,
                  itemBuilder: (context, index) {
                    final word = widget.words[index];
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: MnemonicsSpacing.l,
                        right: MnemonicsSpacing.l,
                        bottom: MnemonicsSpacing.l,
                        top: MediaQuery.of(context).padding.top + kToolbarHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LearnedSlider(
                            isLearned: _isLearned,
                            onChanged: (val) {
                              setState(() {
                                _isLearned = val;
                              });
                              _saveUserWordData(); // save locally and continue workflow
                              _saveCloudLearnedStatus(
                                  val); // save to mysql cloud db
                            },
                          ),
                          const SizedBox(height: MnemonicsSpacing.l),

                          // ── Word header ────────────────────────────────
                          Center(
                            child: Text(
                              word.word,
                              style: MnemonicsTypography.headingLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: MnemonicsSpacing.l),

                          // ── Meaning card ───────────────────────────────
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(MnemonicsSpacing.l),
                            decoration: BoxDecoration(
                              color: MnemonicsColors.primaryGreen
                                  .withOpacity(0.07),
                              borderRadius: BorderRadius.circular(
                                  MnemonicsSpacing.radiusXL),
                              border: Border.all(
                                color: MnemonicsColors.primaryGreen
                                    .withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word.meaning,
                                  style: MnemonicsTypography.bodyLarge
                                      .copyWith(
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                    height: MnemonicsSpacing.s),
                                _loadingHindi
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : (_hindiMeaning != null &&
                                            _hindiMeaning!.isNotEmpty)
                                        ? Text(
                                            _hindiMeaning!,
                                            style: MnemonicsTypography
                                                .bodyRegular
                                                .copyWith(
                                              color: MnemonicsColors
                                                  .textSecondary,
                                              fontSize: 14,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          const SizedBox(height: MnemonicsSpacing.l),

                          VocabularyWordImage(
                            word: word,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            borderRadius: BorderRadius.circular(
                                MnemonicsSpacing.radiusL),
                          ),
                          const SizedBox(height: MnemonicsSpacing.m),
                          // Video Player
                          /*
                          if (word.video != null &&
                              word.video!.isNotEmpty &&
                              _chewieController != null)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    MnemonicsSpacing.radiusL),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    MnemonicsSpacing.radiusL),
                                child: Chewie(controller: _chewieController!),
                              ),
                            )
                          else if (word.video != null && word.video!.isNotEmpty)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: MnemonicsColors.surface,
                                borderRadius: BorderRadius.circular(
                                    MnemonicsSpacing.radiusL),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          if (word.video != null && word.video!.isNotEmpty)
                            const SizedBox(height: MnemonicsSpacing.m),
                          */
                          if (word.effectiveSynonyms.isNotEmpty) ...[
                            const Text('Synonyms:',
                                style: MnemonicsTypography.bodyLarge),
                            Wrap(
                              spacing: 8,
                              children: word.effectiveSynonyms
                                  .map((s) => Chip(label: Text(s)))
                                  .toList(),
                            ),
                            const SizedBox(height: MnemonicsSpacing.m),
                          ],
                          if (word.antonyms.isNotEmpty) ...[
                            const Text('Antonyms:',
                                style: MnemonicsTypography.bodyLarge),
                            Wrap(
                              spacing: 8,
                              children: word.antonyms
                                  .map((a) => Chip(label: Text(a)))
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: MnemonicsSpacing.l),

                          // AI Insights Section
                          Builder(
                            builder: (context) {
                              final definitionText = word.definition != null &&
                                      word.definition!.isNotEmpty
                                  ? word.definition!
                                  : word.meaning;

                              final String memoryTipText =
                                  (word.aiMnemonic != null &&
                                          word.aiMnemonic!.isNotEmpty)
                                      ? word.aiMnemonic!
                                      : word.mnemonic;

                              final bool hasDistinctDefinition =
                                  word.definition != null &&
                                      word.definition!.trim().isNotEmpty &&
                                      word.definition!.trim().toLowerCase() !=
                                          word.meaning.trim().toLowerCase();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.explore,
                                          color: MnemonicsColors.primaryGreen,
                                          size: 24),
                                      const SizedBox(width: MnemonicsSpacing.s),
                                      Text(
                                        'Word Explorer',
                                        style: MnemonicsTypography.headingMedium
                                            .copyWith(
                                          color: MnemonicsColors.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: MnemonicsSpacing.m),
                                  Column(
                                    children: [
                                      if (hasDistinctDefinition) ...[
                                        _buildCollapsibleCard(
                                          icon: Icons.menu_book,
                                          title: 'Nuance & Extended Meaning',
                                          contentWidget: Text(word.definition!,
                                              style: MnemonicsTypography
                                                  .bodyRegular),
                                          color: Colors.amber.shade700,
                                        ),
                                      ],
                                      _buildPhrasesSection(word, isDarkMode),
                                      _buildFillInBlankSection(word, definitionText),
                                      _buildCommonPhrasesSection(word),
                                      if (memoryTipText.isNotEmpty) ...[
                                        const SizedBox(
                                            height: MnemonicsSpacing.m),
                                        _buildCollapsibleCard(
                                          icon: Icons.psychology,
                                          title: 'Memory Hook',
                                          contentWidget: Text(memoryTipText,
                                              style: MnemonicsTypography
                                                  .bodyRegular),
                                          color: Colors.orange.shade700,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: MnemonicsSpacing.l),
                          _buildProgressInfo(),
                          const SizedBox(height: MnemonicsSpacing.m),
                          _buildSpacedRepetitionHint(),
                          const SizedBox(height: MnemonicsSpacing.l),
                          const Text('Your Notes:',
                              style: MnemonicsTypography.bodyLarge),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Add your notes or mnemonic...',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) {
                              setState(() {
                                _isNotesDirty = true;
                              });
                              _saveUserWordData();
                            },
                          ),
                          if (_isNotesDirty) ...[
                            const SizedBox(height: MnemonicsSpacing.s),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isSavingNotes ? null : _saveCloudNotes,
                                icon: _isSavingNotes
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Icon(Icons.cloud_upload),
                                label: const Text('Save to Cloud'),
                              ),
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
      bottomNavigationBar: _buildPracticeBar(isDarkMode),
    );
  }

  // ── Practice bar (Anki-style Easy / Medium / Hard) ──────────────────────
  Widget _buildPracticeBar(bool isDarkMode) {
    if (_loading) return const SizedBox.shrink();

    final bg = (isDarkMode ? const Color(0xFF1A1A1A) : Colors.white)
        .withOpacity(0.92);

    if (_isLearned) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          MnemonicsSpacing.l,
          MnemonicsSpacing.m,
          MnemonicsSpacing.l,
          MnemonicsSpacing.l,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            top: BorderSide(
              color: MnemonicsColors.primaryGreen.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded,
                color: MnemonicsColors.primaryGreen, size: 20),
            const SizedBox(width: MnemonicsSpacing.s),
            Text(
              'Learned — removed from your practice queue',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: MnemonicsColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        MnemonicsSpacing.l,
        MnemonicsSpacing.s,
        MnemonicsSpacing.l,
        MnemonicsSpacing.l,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.06),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'How well did you know this word?',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode
                    ? MnemonicsColors.darkTextSecondary
                    : MnemonicsColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Row(
            children: [
              _ratingButton('Hard', Colors.redAccent, Icons.trending_down,
                  () => _handleReview(ReviewRating.hard)),
              const SizedBox(width: MnemonicsSpacing.s),
              _ratingButton('Medium', Colors.orangeAccent, Icons.remove,
                  () => _handleReview(ReviewRating.medium)),
              const SizedBox(width: MnemonicsSpacing.s),
              _ratingButton('Easy', MnemonicsColors.primaryGreen,
                  Icons.check_rounded, () => _handleReview(ReviewRating.easy)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingButton(
      String label, Color color, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        child: InkWell(
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Phrase Context & Usage — bold usecase + example sentence ───────────
  Widget _buildPhrasesSection(VocabularyWord word, bool isDarkMode) {
    final usages = word.phraseUsages.take(5).toList();

    return Padding(
      padding: const EdgeInsets.only(top: MnemonicsSpacing.m),
      child: _buildCollapsibleCard(
        icon: Icons.chat_bubble_outline,
        title: 'Phrase Context & Usage',
        contentWidget: usages.isEmpty
            ? Text(
                'Example sentences are not available for this word yet.',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: usages
                    .map((usage) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: MnemonicsSpacing.m),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.label_important_outline,
                                  size: 16,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: MnemonicsTypography.bodyRegular
                                        .copyWith(
                                      color: isDarkMode
                                          ? MnemonicsColors.darkTextPrimary
                                          : MnemonicsColors.textPrimary,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${usage.useCase} — ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : MnemonicsColors.textPrimary,
                                        ),
                                      ),
                                      TextSpan(
                                        text: usage.sentence,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: isDarkMode
                                              ? MnemonicsColors.darkTextSecondary
                                              : MnemonicsColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
        color: Colors.blue.shade600,
      ),
    );
  }

  // ── Key Collocations — short collocations, tap-friendly chips ────────────
  Widget _buildCommonPhrasesSection(VocabularyWord word) {
    final phrases = word.effectivePhrases;
    if (phrases.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: MnemonicsSpacing.m),
      child: _buildCollapsibleCard(
        icon: Icons.style,
        title: 'Key Collocations',
        contentWidget: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: phrases
              .map((p) => Chip(
                    label: Text(p),
                    backgroundColor: Colors.purple.shade50,
                    side: BorderSide(color: Colors.purple.shade100),
                  ))
              .toList(),
        ),
        color: Colors.purple.shade600,
      ),
    );
  }

  // ── Fill in the Blank — recall the word from real usage context ─────────
  Widget _buildFillInBlankSection(VocabularyWord word, String definitionText) {
    final sentences = word.contextSentences.take(3).toList();
    if (sentences.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: MnemonicsSpacing.m),
      child: _buildCollapsibleCard(
        icon: Icons.quiz,
        title: 'Fill in the Blank (Active Recall)',
        contentWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sentences
              .map((s) => FillInBlankCard(
                    sentence: s,
                    answer: word.word,
                    hint: definitionText,
                  ))
              .toList(),
        ),
        color: Colors.teal.shade600,
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
        border:
            Border.all(color: MnemonicsColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Word Information',
            style: MnemonicsTypography.bodyLarge
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Wrap(
            spacing: MnemonicsSpacing.s,
            runSpacing: MnemonicsSpacing.s,
            children: [
              _buildInfoChip(
                  'Category', word.category, MnemonicsColors.primaryGreen),
              _buildInfoChip('Difficulty', word.difficulty.displayName,
                  _getDifficultyColor(word.difficulty)),
            ],
          ),
          if (_userWordData != null) ...[
            const SizedBox(height: MnemonicsSpacing.s),
            Wrap(
              spacing: MnemonicsSpacing.s,
              runSpacing: MnemonicsSpacing.s,
              children: [
                _buildInfoChip('Reviews', '${_userWordData!.reviewCount}',
                    MnemonicsColors.secondaryOrange),
                _buildInfoChip(
                    'Accuracy',
                    '${(_userWordData!.accuracyRate * 100).toStringAsFixed(0)}%',
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
      padding: const EdgeInsets.symmetric(
          horizontal: MnemonicsSpacing.s, vertical: MnemonicsSpacing.xs),
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
        style: MnemonicsTypography.bodyRegular
            .copyWith(color: MnemonicsColors.secondaryOrange),
      );
    }
    return const Text(
      'Spaced repetition will remind you to review this word soon.',
      style: MnemonicsTypography.bodyRegular,
    );
  }

  void _handleReview(ReviewRating rating) async {
    final now = DateTime.now();
    final result = SpacedRepetitionManager.calculateNextReview(
      now,
      rating,
      _interval,
      _repetitions,
      _easeFactor,
    );
    setState(() {
      _nextReview = result.nextReview;
      _interval = result.interval;
      _repetitions = result.repetitions;
      _easeFactor = result.easeFactor;
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
        SnackBar(
            duration: const Duration(seconds: 1),
            content:
                Text('Next review: ${_formatNextReview(result.nextReview)}')),
      );
      // Anki-style: advance to the next word that still needs practice.
      // Learned words drop out of the queue automatically.
      _advanceToNextUnlearned();
    }
  }

  /// Moves the pager to the next word in the set (wrapping around).
  /// Used by the next button in the top bar — always advances one card.
  void _goToNextWord() {
    if (widget.words.length <= 1) return;
    final next = (_currentIndex + 1) % widget.words.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  /// Moves the pager to the next card that is not marked as learned,
  /// wrapping around if needed. If every word is learned, stays put.
  void _advanceToNextUnlearned() {
    if (widget.words.length <= 1) return;

    final repo = ref.read(userWordDataRepositoryProvider);
    final total = widget.words.length;
    final learnedCache = <int, bool>{};

    Future<void> scan() async {
      for (var step = 1; step < total; step++) {
        final idx = (_currentIndex + step) % total;
        final candidate = widget.words[idx];
        var learned = learnedCache[idx];
        if (learned == null) {
          final data = await repo.getUserWordData(candidate.word);
          learned = data?.isLearned ?? false;
          learnedCache[idx] = learned;
        }
        if (!learned) {
          if (mounted) {
            _pageController.animateToPage(
              idx,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
            );
          }
          return;
        }
      }
      // All remaining words learned — nothing left in the queue.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All words in this set are learned. 🎉'),
            backgroundColor: MnemonicsColors.primaryGreen,
          ),
        );
      }
    }

    scan();
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

  Widget _buildCollapsibleCard({
    required IconData icon,
    required String title,
    required Widget contentWidget,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: MnemonicsSpacing.m, vertical: 0),
          childrenPadding: const EdgeInsets.only(
              left: MnemonicsSpacing.m,
              right: MnemonicsSpacing.m,
              bottom: MnemonicsSpacing.m),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: Text(
                  title,
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color.withAlpha(220),
                  ),
                ),
              ),
            ],
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: contentWidget,
            ),
          ],
        ),
      ),
    );
  }

  String _sanitizeString(String text) {
    if (text.isEmpty) return text;
    // Replace markdown bold stars with nothing to make text normal string format
    return text.replaceAll('**', "");
  }

  Future<void> _saveUserWordData() async {
    final repo = ref.read(userWordDataRepositoryProvider);
    final word = widget.words[_currentIndex];
    final now = DateTime.now();

    var data = _userWordData ??
        UserWordData(
          word: word.word,
          notes: _notesController?.text ?? '',
          isLearned: _isLearned,
          nextReview: _nextReview,
          easeFactor: _easeFactor,
          interval: _interval,
          repetitions: _repetitions,
        );

    data.notes = _notesController?.text ?? '';
    data.isLearned = _isLearned;
    data.nextReview = _nextReview;
    data.easeFactor = _easeFactor;
    data.interval = _interval;
    data.repetitions = _repetitions;
    data.lastReviewedAt = now;

    if (data.firstLearnedAt == null && _isLearned) {
      data.firstLearnedAt = now;
    }

    await repo.saveOrUpdateUserWordData(data);

    // Update progress service
    final progressService = ref.read(userProgressServiceProvider);
    if (_isLearned) {
      await progressService.markWordAsLearned(word.word);
    } else {
      ref.invalidate(allUserWordDataProvider);
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
                        borderRadius:
                            BorderRadius.circular(MnemonicsSpacing.radiusM),
                      ),
                      child: const Icon(
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
                    _buildHeaderChip(
                        word.category, Colors.white.withOpacity(0.9)),
                    const SizedBox(width: MnemonicsSpacing.s),
                    _buildHeaderChip(word.difficulty.displayName,
                        Colors.white.withOpacity(0.9)),
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
                        padding: const EdgeInsets.all(MnemonicsSpacing.xs),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(MnemonicsSpacing.radiusS),
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
                          color: isDarkMode
                              ? MnemonicsColors.darkTextPrimary
                              : MnemonicsColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MnemonicsSpacing.s),
                  Text(
                    content,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextSecondary
                          : MnemonicsColors.textSecondary,
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

class LearnedSlider extends StatelessWidget {
  final bool isLearned;
  final ValueChanged<bool> onChanged;

  const LearnedSlider(
      {Key? key, required this.isLearned, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isLearned),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && !isLearned) {
          onChanged(true);
        } else if (details.primaryVelocity! < 0 && isLearned) {
          onChanged(false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isLearned
                ? [
                    MnemonicsColors.primaryGreen,
                    MnemonicsColors.primaryGreen.withOpacity(0.7)
                  ]
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          boxShadow: [
            BoxShadow(
              color: isLearned
                  ? MnemonicsColors.primaryGreen.withOpacity(0.4)
                  : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment:
                  isLearned ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  isLearned ? 'LEARNED' : 'UNLEARNED',
                  style: MnemonicsTypography.headingMedium.copyWith(
                    color: isLearned ? Colors.white : Colors.grey.shade600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment:
                  isLearned ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(4),
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isLearned ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isLearned
                      ? MnemonicsColors.primaryGreen
                      : Colors.grey.shade500,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
