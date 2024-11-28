import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenaiService {
  static final OpenaiService _instance = OpenaiService._internal();
  late String _apiKey;
  
  factory OpenaiService() {
    return _instance;
  }

  OpenaiService._internal();

  void init() {
    _apiKey = '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';
  }

  Future<void> delayRequests() async {
    await Future.delayed(const Duration(seconds: 1));
  }


  Future<Map<String, dynamic>> correctAnswer(String answer, String question, String lang) async {
    final prompt = _generatePrompt(answer, question, lang);
    const int maxRetries = 5;
    const Duration baseDelay = Duration(seconds: 2);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      print('Attempt: $attempt');
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedBody);
      } else if (response.statusCode == 429) {
        final int delay = baseDelay.inMilliseconds * (1 << attempt);
        await Future.delayed(Duration(milliseconds: delay));
        print('Retrying after delay: ${delay / 1000} seconds');
      } else {
        throw Exception('Failed to get response from OpenAI: ${response.statusCode}');
      }
    }
    throw Exception('Exceeded retry attempts due to rate limit.');
  }



  String _generatePrompt(String answer, String question, String lang) {
    if (lang == "fr") {
      return '''
        Évalue la réponse donnée à la question suivante:
        Question: $question
        Réponse: $answer

        Aa. 0%
        Bb. 50%
        Cc. 100%

        Justifie avec une phrase de 50 mots et donne le score associé (Aa, Bb Cc)
      ''';
    } else {
      return '''
        Evaluate the following answer to the following question:
        Question: $question
        Answer: $answer
        
        Aa. 0%
        Bb. 50%
        Cc. 100%
        
        Justify with a 50-word sentence and provide the associated score (Aa, Bb, Cc).
      ''';
    }
  }
}