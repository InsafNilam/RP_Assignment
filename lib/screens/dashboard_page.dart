import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/common/utils/get_location.dart';
import 'package:chat_application/common/utils/weather_data.dart';
import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/models/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Weather?> info() async {
    WeatherData client = WeatherData();
    Position position = await getCurrentLocation();
    Weather? data = await client.getData(position.latitude, position.longitude);
    // Weather? data = Weather.fromJson({
    //   "location": {
    //     "name": "Colombo",
    //     "region": "Western",
    //     "country": "Sri Lanka",
    //     "lat": 6.93,
    //     "lon": 79.85,
    //     "tz_id": "Asia/Colombo",
    //     "localtime_epoch": 1697003733,
    //     "localtime": "2023-10-11 11:25"
    //   },
    //   "current": {
    //     "last_updated_epoch": 1697003100,
    //     "last_updated": "2023-10-11 11:15",
    //     "temp_c": 30.0,
    //     "temp_f": 86.0,
    //     "is_day": 1,
    //     "condition": {
    //       "text": "Partly cloudy",
    //       "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png",
    //       "code": 1003
    //     },
    //     "wind_mph": 6.9,
    //     "wind_kph": 11.2,
    //     "wind_degree": 240,
    //     "wind_dir": "WSW",
    //     "pressure_mb": 1013.0,
    //     "pressure_in": 29.91,
    //     "precip_mm": 0.12,
    //     "precip_in": 0.0,
    //     "humidity": 79,
    //     "cloud": 50,
    //     "feelslike_c": 36.7,
    //     "feelslike_f": 98.1,
    //     "vis_km": 10.0,
    //     "vis_miles": 6.0,
    //     "uv": 6.0,
    //     "gust_mph": 11.9,
    //     "gust_kph": 19.1
    //   }
    // });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
        titleSpacing: 0,
        title: BounceInDown(child: const Text('Dashboard')),
        backgroundColor: const Color(0XFF3FA2FA),
        elevation: 0,
      ),
      body: FutureBuilder<Weather?>(
          future: info(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ZoomIn(
                child: Container(
                  height: size.height * 0.65,
                  width: size.width,
                  padding:
                      const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    ),
                    gradient: LinearGradient(
                        colors: [
                          Color(0XFF955CD1),
                          Color(0XFF3FA2FA),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0.2, 0.85]),
                  ),
                  child: const Loader(),
                ),
              );
            }
            return Column(
              children: [
                Container(
                  height: size.height * 0.65,
                  width: size.width,
                  padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    ),
                    gradient: LinearGradient(
                        colors: [
                          Color(0XFF955CD1),
                          Color(0XFF3FA2FA),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0.2, 0.85]),
                  ),
                  child: BounceInUp(
                    delay: const Duration(seconds: 1),
                    child: Column(
                      children: [
                        Text(
                          "${snapshot.data?.city}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 36,
                            fontFamily: 'MavenPro',
                          ),
                        ),
                        const SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontFamily: 'MavenPro',
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        CachedNetworkImage(
                          fit: BoxFit.fill,
                          width: size.width * 0.35,
                          imageUrl: 'https:${snapshot.data!.icon}',
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.error),
                          ),
                        ),
                        Text(
                          "${snapshot.data?.condition}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Hubballi',
                          ),
                        ),
                        Text(
                          "${snapshot.data?.temp}°",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Hubballi',
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: ZoomIn(
                                delay: const Duration(seconds: 2),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      width: size.width * 0.1,
                                      color: Colors.white,
                                      'assets/images/storm.png',
                                    ),
                                    const SizedBox(
                                      height: 3.0,
                                    ),
                                    Text(
                                      "${snapshot.data?.wind} km/h",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Hubballi',
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2.0,
                                    ),
                                    Text(
                                      "Wind",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "MavenPro",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: ZoomIn(
                                delay: const Duration(seconds: 3),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      width: size.width * 0.1,
                                      color: Colors.lightBlue,
                                      'assets/images/humidity.png',
                                    ),
                                    const SizedBox(
                                      height: 3.0,
                                    ),
                                    Text(
                                      "${snapshot.data?.humidity}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Hubballi',
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2.0,
                                    ),
                                    Text(
                                      "Humidity",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'MavenPro',
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: ZoomIn(
                                delay: const Duration(seconds: 4),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      width: size.width * 0.1,
                                      color: Colors.orange,
                                      'assets/images/wind.png',
                                    ),
                                    const SizedBox(
                                      height: 3.0,
                                    ),
                                    Text(
                                      "${snapshot.data?.direction}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "MavenPro",
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2.0,
                                    ),
                                    Text(
                                      "Direction",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                BounceInRight(
                  delay: const Duration(seconds: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Gust',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${snapshot.data?.gust} kp/h',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Pressure',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${snapshot.data?.pressure} hpa',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'UV',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${snapshot.data?.uv}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Precipitation',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${snapshot.data?.precipitation} mm',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Wind',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${snapshot.data?.wind} km/h',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Last Update',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 17,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${snapshot.data?.update!.split(' ')[1]}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontFamily: 'MavenPro',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }
}
