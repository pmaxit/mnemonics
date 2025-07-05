import 'package:flutter/material.dart';
import '../../domain/vocabulary_word.dart';
import '../../../../common/design/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/providers.dart';
import '../../../home/infrastructure/user_word_data_repository.dart';
import '../../../home/domain/user_word_data.dart';
import '../../../home/domain/spaced_repetition.dart';
import '../../../home/infrastructure/review_activity_repository.dart';
import '../../../home/domain/review_activity.dart';

class LearnWordDetailScreen extends ConsumerStatefulWidget {
  final List<VocabularyWord> words;
  final int initialIndex;
  const LearnWordDetailScreen({Key? key, required this.words, this.initialIndex = 0}) : super(key: key);

  @override
  ConsumerState<LearnWordDetailScreen> createState() => _LearnWordDetailScreenState();
}

class _LearnWordDetailScreenState extends ConsumerState<LearnWordDetailScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  TextEditingController? _notesController;
  bool _isLearned = false;
  DateTime? _nextReview;

  UserWordData? _userWordData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadUserWordData();
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController?.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) async {
    setState(() {
      _currentIndex = index;
    });
    await _loadUserWordData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.words[_currentIndex].word),
      ),
      body: _loading
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
                      _buildSpacedRepetitionHint(),
                      if (_isLearned)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => _handleReview(ReviewRating.hard),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              child: const Text('Hard'),
                            ),
                            ElevatedButton(
                              onPressed: () => _handleReview(ReviewRating.medium),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                              child: const Text('Medium'),
                            ),
                            ElevatedButton(
                              onPressed: () => _handleReview(ReviewRating.easy),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Easy'),
                            ),
                          ],
                        ),
                      // TODO: Add spaced repetition review actions
                    ],
                  ),
                );
              },
            ),
    );
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
    // Log activity
    final repo = ref.read(reviewActivityRepositoryProvider);
    final word = widget.words[_currentIndex].word;
    await repo.addActivity(ReviewActivity(
      word: word,
      reviewedAt: now,
      rating: rating.toString().split('.').last,
    ));
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

  Future<void> _saveUserWordData() async {
    final repo = ref.read(userWordDataRepositoryProvider);
    final word = widget.words[_currentIndex];
    final data = UserWordData(
      word: word.word,
      notes: _notesController?.text ?? '',
      isLearned: _isLearned,
      nextReview: _nextReview,
    );
    await repo.saveOrUpdateUserWordData(data);
  }
} 