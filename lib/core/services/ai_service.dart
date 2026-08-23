import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_service.g.dart';

class AIService {
  static const String _openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String _model = 'google/gemma-4-12b-instruct';

  final String _apiKey;
  final http.Client _client;

  AIService({http.Client? client})
      : _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '',
        _client = client ?? http.Client();

  Future<String> _callOpenRouter(String prompt, {bool jsonMode = false}) async {
    if (_apiKey.isEmpty) {
      throw Exception('OPENROUTER_API_KEY is not set in .env file');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'HTTP-Referer': 'https://mnemonics-app.com',
      'X-Title': 'Mnemonics App',
    };

    final body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': 0.7,
      if (jsonMode) 'response_format': {'type': 'json_object'},
    });

    try {
      final response = await _client.post(
        Uri.parse('$_openRouterBaseUrl/chat/completions'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final error = jsonDecode(response.body);
        log('OpenRouter error: ${response.statusCode} - $error');
        throw Exception('Failed to generate response: ${error['error']['message']}');
      }
    } catch (e) {
      log('Error calling OpenRouter: $e');
      rethrow;
    }
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
      final response = await _callOpenRouter(prompt);
      return response.isNotEmpty ? response : 'Hmm, my brain fizzled out. Try generating again!';
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
3. Write 5 concise example sentences that use the word naturally in different real-world contexts (e.g. health, politics, daily life). Each sentence must show the word in action — never mention the word itself as a vocabulary item.
4. Give 3 synonyms commonly tested on GRE.
5. Give 1 quick memory tip or association to remember the word.

Return EXACTLY a valid JSON object with NO OTHER markdown or formatting (DO NOT wrap it in triple backticks) using the following structure:
{
  "definition": "definition here",
  "common_phrases": ["phrase 1", "phrase 2", "phrase 3"],
  "example_sentences": ["sentence 1", "sentence 2", "sentence 3", "sentence 4", "sentence 5"],
  "synonyms": ["synonym 1", "synonym 2", "synonym 3"],
  "memory_tip": "memory tip here"
}
''';

    try {
      final response = await _callOpenRouter(prompt, jsonMode: true);
      return response.trim();
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
      final response = await _callOpenRouter(prompt);
      return response.replaceAll('"', '').trim();
    } catch (e) {
      log('Error generating tree wisdom: $e');
      return 'The wind rustles the leaves, whispering of untold words yet to be learned.';
    }
  }

  void dispose() {
    _client.close();
  }
}

@riverpod
AIService aiService(Ref ref) {
  return AIService();
}
