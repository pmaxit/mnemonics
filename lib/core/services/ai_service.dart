import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_service.g.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not set in .env file');
    }
    _model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);
  }

  Future<String> generateMnemonic({
    required String word,
    required String meaning,
    String? nativeLanguage,
  }) async {
    final nativeLangInstruction = nativeLanguage != null
        ? 'The user speaks $nativeLanguage. You can bridge the English word with a similar sounding word in $nativeLanguage.'
        : 'Create a vivid visual association to help remember it.';

    final prompt = '''
You are an expert at creating highly memorable, slightly bizarre, and effective mnemonics for learning English vocabulary.
Create a short, engaging mnemonic to help remember the following word:

Word: "$word"
Meaning: "$meaning"

Instructions:
1. $nativeLangInstruction
2. Make it visual and funny or bizarre, as these stick best in memory.
3. Keep it to 1-2 short sentences.
4. Don't explain what a mnemonic is, just provide the mnemonic story/association directly.
5. Emphasize the connection between the *sound* of the word and its *meaning*.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text?.trim() ??
          'Hmm, my brain fizzled out. Try generating again!';
    } catch (e) {
      log('Error generating mnemonic: $e');
      throw Exception('Failed to generate magic mnemonic. Please try again.');
    }
  }

  Future<String> generateWordInsights({
    required String word,
  }) async {
    final prompt = '''
For the word detail screen can you add more information about the word.

Act as a GRE vocabulary tutor.

For the given word, help me learn it through association and context.

For the word: "$word"

1. Give a short, simple definition suitable for GRE preparation.
2. Generate 12-15 short phrases where the word is naturally used.
   Do NOT write full sentences here — only short phrases (2-4 words).
   The phrases should cover different contexts such as behavior, science, society, emotions, academic writing, etc.
3. Write 3 example sentences using the word naturally in different contexts.
4. Give 3 synonyms commonly tested on GRE.
5. Give 1 quick memory tip or association to remember the word.

Return EXACTLY a valid JSON object with NO OTHER markdown or formatting (DO NOT wrap it in ```json) using the following structure:
{
  "definition": "definition here",
  "common_phrases": ["phrase 1", "phrase 2", "phrase 3"],
  "example_sentences": ["sentence 1", "sentence 2", "sentence 3"],
  "synonyms": ["synonym 1", "synonym 2", "synonym 3"],
  "memory_tip": "memory tip here"
}
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(
        content,
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      return response.text?.trim() ?? '{}';
    } catch (e) {
      log('Error generating word insights: $e');
      throw Exception('Failed to generate word insights. Please try again.');
    }
  }

  Future<String> generateTreeWisdom({
    required int totalLearned,
    required double accuracy,
    required int streak,
  }) async {
    final prompt = '''
You are the ancient, wise "Tree Spirit of Knowledge". A student is growing a virtual Knowledge Tree by learning vocabulary words.

Their current stats:
- Words Learned: $totalLearned
- Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%
- Current Streak: $streak days

Write a SINGLE, mystical, encouraging sentence (max 20 words) as if the Tree itself is speaking to them. 
Acknowledge their effort or their stats, but keep it poetic and magical.
Return ONLY the sentence, nothing else.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text?.replaceAll('"', '').trim() ??
          'The roots run deep, but your potential reaches higher.';
    } catch (e) {
      log('Error generating tree wisdom: $e');
      return 'The wind rustles the leaves, whispering of untold words yet to be learned.';
    }
  }
}

@riverpod
AIService aiService(AiServiceRef ref) {
  return AIService();
}
