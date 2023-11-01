import 'dart:convert';
import 'package:chat_application/models/article_model.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class ApiService {
  Future<List<Article>>? getArticle(String query) async {
    const String key = '43e14892e5204c71a5be127b41e9f7ea';
    // Get 1 Month Old Results
    DateTime date = DateTime.now().subtract(const Duration(days: 30));
    String fromDate = DateFormat("yyyy-MM-dd").format(date);
    String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    DateTime.now().month;
    final endpoint = Uri.parse(
      'https://newsapi.org/v2/everything?q=$query&from=$fromDate&to=$toDate&sortBy=publishedAt&apiKey=$key',
    );
    Response res = await get(endpoint);
    if (res.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(res.body);
      List<dynamic> body = json['articles'];
      List<Article> articles = await Future.wait(
        body.map((dynamic item) async => Article.fromJson(item)).toList(),
      );
      return articles;
    } else {
      throw Exception("Can't get the Articles");
    }
  }
}
