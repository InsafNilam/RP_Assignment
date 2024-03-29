import 'dart:convert';
import 'package:chat_application/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, dynamic>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $OPENAI_API_KEY'
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                'role': "user",
                'content':
                    'Does this message want to generate an AI picture, image, art or anything similar? $prompt. Simply answer with a yes or no.'
              }
            ],
          }));

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return "An Internal Error Occurred";
    } catch (err) {
      return err.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': "user",
      'content': prompt,
    });
    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $OPENAI_API_KEY'
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": messages,
          }));

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });

        return content;
      }
      return 'An Internal Error Occurred';
    } catch (err) {
      return err.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': "user",
      'content': prompt,
    });
    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $OPENAI_API_KEY'
          },
          body: jsonEncode({
            'prompt': prompt,
            'n': 1,
            'size': "512x512",
          }));

      if (res.statusCode == 200) {
        String imageURL = jsonDecode(res.body)['data'][0]['url'];
        imageURL = imageURL.trim();

        messages.add({
          'role': 'assistant',
          'content': imageURL,
        });

        return imageURL;
      }
      return 'An Internal Error Occurred';
    } catch (err) {
      return err.toString();
    }
  }
}
