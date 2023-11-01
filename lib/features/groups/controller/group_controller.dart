import 'dart:io';

import 'package:chat_application/features/groups/repository/group_repository.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupControllerProvider = Provider((ref) {
  final groupRepository = ref.read(groupRepositoryProvider);
  return GroupController(groupRepository: groupRepository, ref: ref);
});

class GroupController {
  final GroupRepository groupRepository;
  final ProviderRef ref;

  GroupController({required this.groupRepository, required this.ref});

  void createGroup(BuildContext context, String name, File profilePic,
      List<UserModel> users) {
    groupRepository.createGroup(context, name, profilePic, users);
  }
}
