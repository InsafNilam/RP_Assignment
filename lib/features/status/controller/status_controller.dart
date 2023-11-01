import 'dart:io';

import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/features/status/repository/status_repository.dart';
import 'package:chat_application/models/status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final statusControllerProvider = Provider((ref) {
  final statusRepository = ref.read(statusRepositoryProvider);
  return StatusController(
    statusRepository: statusRepository,
    ref: ref,
  );
});

class StatusController {
  final StatusRepository statusRepository;
  final ProviderRef ref;

  StatusController({required this.statusRepository, required this.ref});

  void addStatus(File file, BuildContext context) {
    ref.watch(userDataAuthProvider).whenData(
          (value) => statusRepository.uploadStatus(
            username: value!.name,
            profilePic: value.profilePic,
            phoneNumber: value.phoneNumber,
            statusImage: file,
            context: context,
          ),
        );
  }

  Future<List<StatusModel>> getStatus(BuildContext context) async {
    List<StatusModel> status = await statusRepository.getStatus(context);
    return status;
  }
}
