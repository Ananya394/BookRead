// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  static Future<String> generateSummary({
    required String title,
    required String author,
  }) async {
    final prompt = """
একটি সংক্ষিপ্ত, আকর্ষণীয় ৩-৪ বাক্যের সারাংশ লিখুন বাংলায়:

**বই:** $title  
**লেখক:** $author

পাঠকদের কাছে আকর্ষণীয় এবং স্বাভাবিক শোনাতে হবে। AI বলবেন না।
""";

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "google/gemini-flash-1.5",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "temperature": 0.7,
        "max_tokens": 300,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error']['message'] ?? 'AI request failed');
    }
  }
}
