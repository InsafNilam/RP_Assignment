import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(
        size: 25,
        color: Colors.amber.shade400,
      ),
    );
  }
}
