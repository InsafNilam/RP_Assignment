import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotifiedPage extends StatelessWidget {
  final String? label;
  const NotifiedPage({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
          ),
        ),
        title: Text(
          label.toString().split("|")[0],
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        titleSpacing: 0,
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.grey.shade400),
          child: Center(
            child: Text(
              label.toString().split("|")[1],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
