import 'dart:io';
import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:chat_application/common/repositories/common_firebase_storage.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/models/chat_group.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final groupRepositoryProvider = Provider((ref) => GroupRepository(
    firebaseFirestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref));

class GroupRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  GroupRepository(
      {required this.firebaseFirestore, required this.auth, required this.ref});

  void createGroup(
    BuildContext context,
    String name,
    File profilePic,
    List<UserModel> users,
  ) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < users.length; i++) {
        uids.add(users[i].uid);

        var groupId = const Uuid().v1();
        String groupPicURL = await ref
            .read(commonFirebaseStorageProvider)
            .storeFileToFirebase('groups/$groupId', profilePic);
        GroupModel group = GroupModel(
          senderId: auth.currentUser!.uid,
          name: name,
          groupId: groupId,
          lastMessage: '',
          groupPic: groupPicURL,
          membersId: [auth.currentUser!.uid, ...uids],
          timeSent: DateTime.now(),
        );

        await firebaseFirestore
            .collection('groups')
            .doc(groupId)
            .set(group.toMap());
      }
    } catch (err) {
      Future(
        () => showSnackbar(
          context: context,
          content: err.toString(),
          type: SnackBarEnum.error,
        ),
      );
    }
  }
}
