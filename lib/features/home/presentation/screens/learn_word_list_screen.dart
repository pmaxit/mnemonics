import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/course_card.dart';
import '../../domain/vocabulary_word.dart';
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

class _LearnWordListScreenState extends ConsumerState<LearnWordListScreen> {
  String _search = '';
  String? _difficulty;
  String? _category;

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.all(MnemonicsSpacing.l),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search words, meanings, or mnemonics',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _search = value),
                  ),
                ),
                Expanded(
                  child: vocabAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (_) => filtered.isEmpty
                        ? const Center(child: Text('No words found.'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.l, vertical: MnemonicsSpacing.m),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: MnemonicsSpacing.m),
                            itemBuilder: (context, i) {
                              final word = filtered[i];
                              final accent = accentColors[i % accentColors.length];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                                ),
                                elevation: 2,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                                  onTap: () {
                                    context.push('/flashcards', extra: {
                                      'words': filtered,
                                      'initialIndex': i,
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: accent,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(MnemonicsSpacing.radiusL),
                                            bottomLeft: Radius.circular(MnemonicsSpacing.radiusL),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(MnemonicsSpacing.m),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(word.word, style: MnemonicsTypography.headingMedium),
                                              const SizedBox(height: MnemonicsSpacing.xs),
                                              Text(word.meaning, style: MnemonicsTypography.bodyRegular.copyWith(color: MnemonicsColors.textSecondary)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
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
} 