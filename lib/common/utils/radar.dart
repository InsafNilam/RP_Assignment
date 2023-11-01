import 'package:flutter/material.dart';

class Radar extends StatefulWidget {
  const Radar({super.key});

  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/radar.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 4.0).animate(_controller),
        child: Container(
          decoration: const BoxDecoration(
            gradient: SweepGradient(
              center: FractionalOffset.center,
              colors: <Color>[
                Colors.transparent,
                Color(0XFF34A853),
                Colors.transparent,
              ],
              stops: <double>[
                0.20,
                0.25,
                0.20,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
