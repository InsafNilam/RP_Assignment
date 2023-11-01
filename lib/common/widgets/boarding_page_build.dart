import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingPageBuild extends StatefulWidget {
  const OnBoardingPageBuild({
    Key? key,
    required this.color,
    required this.hero,
    required this.title,
    required this.subtitle,
    required this.lottieUrl,
  }) : super(key: key);
  final Color color;
  final String hero;
  final String title;
  final String subtitle;
  final String lottieUrl;

  @override
  State<OnBoardingPageBuild> createState() => _OnBoardingPageBuildState();
}

class _OnBoardingPageBuildState extends State<OnBoardingPageBuild> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
      color: widget.color,
      child: Column(
        children: [
          ClipPath(
            clipper: TopClipper(),
            child: SizedBox(
              height: screenSize.height / 1.8,
              width: screenSize.width,
              child: Container(
                color: Colors.orange,
                child: CustomPaint(
                  painter: ArcPainter(),
                  child: Lottie.network(
                    widget.lottieUrl,
                    alignment: Alignment.center,
                    key: Key('${Random().nextInt(999999999)}'),
                  ),
                ),
              ),
            ),
          ),
          Text(
            widget.title,
            style: const TextStyle(
                fontSize: 27.0,
                fontWeight: FontWeight.bold,
                color: Colors.amber),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17.0, color: Colors.amber),
            ),
          )
        ],
      ),
    );
  }
}

class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path orangeArc = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 125)
      ..quadraticBezierTo(
          size.width / 2, size.height * 1.05, size.width, size.height - 125)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    return orangeArc;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path whiteArc = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 135)
      ..quadraticBezierTo(
          size.width / 2, size.height - 40, size.width, size.height - 135)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(whiteArc, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
