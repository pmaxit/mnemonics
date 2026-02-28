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
You are an expert etymologist, linguist, and pop-culture enthusiast.
Provide deep, fascinating insights about the English vocabulary word: "$word"

Return EXACTLY a valid JSON object with NO OTHER markdown or formatting (DO NOT wrap it in ```json) using the following structure:
{
  "origin": "Briefly describe the etymology and history of the word.",
  "usage_contexts": "Describe typical scenarios or professional contexts where this word is commonly used.",
  "pop_culture": "Provide 1 or 2 famous quotes, book titles, movie references, or pop-culture moments where this word is notable.",
  "fun_fact": "One surprising or fun fact about this word."
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
}

@riverpod
AIService aiService(AiServiceRef ref) {
  return AIService();
}
