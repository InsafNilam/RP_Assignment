import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:chat_application/colors.dart';
import 'package:chat_application/features/status/controller/status_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class ConfirmScreen extends ConsumerWidget {
  static const String routeName = '/confirm-screen';
  final File file;
  const ConfirmScreen({Key? key, required this.file}) : super(key: key);

  void addStatus(WidgetRef ref, BuildContext context) {
    ref.read(statusControllerProvider).addStatus(file, context);
    Get.back();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            'Confirm',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: ZoomIn(
        delay: const Duration(milliseconds: 500),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            child: Image.file(file),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addStatus(ref, context),
        backgroundColor: tabColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
