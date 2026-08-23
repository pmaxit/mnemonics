import 'package:flutter_test/flutter_test.dart';
import 'package:mnemonics/features/home/domain/vocabulary_word.dart';
import 'package:mnemonics/features/profile/domain/user_statistics.dart';

void main() {
  group('VocabularyWord.contextSentences', () {
    test('returns real usage sentences and skips filler', () {
      const word = VocabularyWord(
        word: 'abstain',
        meaning: 'choose not to consume or take part in',
        mnemonic: 'test',
        example:
            'Considered a health nut, Jessica abstained from anything containing sugar—even chocolate.',
        synonyms: [],
        antonyms: [],
        difficulty: WordDifficulty.intermediate,
        category: 'common',
        exampleSentences: [
          [
            'Several board members chose to abstain from the vote on the merger.',
          ],
          ['He abstained from alcohol for a full year.'],
        ],
      );

      final sentences = word.contextSentences;

      expect(sentences, hasLength(3));
      expect(
        sentences.any((s) => s.contains('Jessica abstained')),
        isTrue,
      );
      expect(
        sentences.any((s) => s.contains('abstain from the vote')),
        isTrue,
      );
      expect(
        sentences.any((s) => s.contains('comes up often')),
        isFalse,
      );
    });

    test('parses example sentences from aiInsights JSON', () {
      final word = VocabularyWord(
        word: 'lucid',
        meaning: 'clear',
        mnemonic: 'test',
        example: 'No example available',
        synonyms: const [],
        antonyms: const [],
        difficulty: WordDifficulty.intermediate,
        category: 'common',
        aiInsights: '''
{
  "definition": "clear",
  "example_sentences": [
    "Her lucid explanation helped everyone understand the topic.",
    "After the fever broke, he remained lucid and answered every question."
  ]
}
''',
      );

      expect(word.contextSentences, hasLength(2));
    });
  });
}
