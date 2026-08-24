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

  group('VocabularyWord.phraseUsages', () {
    test('pairs matched collocation with example sentence', () {
      const word = VocabularyWord(
        word: 'obfuscate',
        meaning: 'to confuse or make unclear',
        mnemonic: 'test',
        example: 'No example available',
        synonyms: [],
        antonyms: [],
        difficulty: WordDifficulty.advanced,
        category: 'academic',
        phrases: [
          'obfuscate the truth',
          'obfuscate the code',
        ],
        exampleSentences: [
          ['The politician used complex jargon to obfuscate the truth during the debate.'],
          ['Software developers often obfuscate their code to protect it from being copied.'],
        ],
      );

      final usages = word.phraseUsages;

      expect(usages, hasLength(2));
      expect(usages[0].useCase, equals('Obfuscate the truth'));
      expect(
        usages[0].sentence,
        equals(
            'The politician used complex jargon to obfuscate the truth during the debate.'),
      );
      expect(usages[1].useCase, equals('Obfuscate the code'));
    });

    test('extracts clause use case when explicit phrase is not listed', () {
      const word = VocabularyWord(
        word: 'abstain',
        meaning: 'choose not to consume',
        mnemonic: 'test',
        example: 'He abstained from alcohol for a full year.',
        synonyms: [],
        antonyms: [],
        difficulty: WordDifficulty.intermediate,
        category: 'common',
      );

      final usages = word.phraseUsages;

      expect(usages, hasLength(1));
      expect(usages[0].useCase.isNotEmpty, isTrue);
      expect(usages[0].sentence, equals('He abstained from alcohol for a full year.'));
    });
  });
}
