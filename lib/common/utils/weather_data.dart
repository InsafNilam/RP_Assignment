import 'dart:convert';
import 'package:chat_application/models/weather.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  Future<Weather>? getData(double? latitude, double? longitude) async {
    const String key = '026124cce286454c94b54813231110';
    var endpoint = Uri.parse(
      'http://api.weatherapi.com/v1/current.json?key=$key&q=$latitude,$longitude&aqi=no',
    );

    var response = await http.get(endpoint);
    var body = jsonDecode(response.body);
    return Weather.fromJson(body);
  }
}
