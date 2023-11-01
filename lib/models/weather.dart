class Weather {
  String? city;
  String? icon;
  String? condition;
  double? temp;
  double? wind;
  int? humidity;
  String? direction;
  double? gust;
  double? uv;
  double? pressure;
  double? precipitation;
  String? update;

  Weather({
    required this.city,
    required this.icon,
    required this.condition,
    required this.temp,
    required this.wind,
    required this.humidity,
    required this.direction,
    required this.gust,
    required this.uv,
    required this.pressure,
    required this.precipitation,
    required this.update,
  });

  Weather.fromJson(Map<String, dynamic> json) {
    city = json['location']['name'];
    icon = json['current']['condition']['icon'];
    condition = json['current']['condition']['text'];
    temp = json['current']['temp_c'];
    wind = json['current']['wind_kph'];
    humidity = json['current']['humidity'];
    direction = json['current']['wind_dir'];
    gust = json['current']['gust_kph'];
    uv = json['current']['uv'];
    pressure = json['current']['pressure_mb'];
    precipitation = json['current']['precip_mm'];
    update = json['current']['last_updated'];
  }
}
