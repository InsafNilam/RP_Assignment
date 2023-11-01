import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final Color color;
  final String mainText;
  final String subText;
  const FeatureBox(
      {Key? key,
      required this.color,
      required this.mainText,
      required this.subText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 20.0).copyWith(left: 15.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                mainText,
                style: const TextStyle(
                    fontFamily: 'CeraPro',
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
            ),
            const SizedBox(
              height: 3.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text(
                subText,
                style: const TextStyle(
                  fontFamily: 'CeraPro',
                  color: Colors.black,
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
