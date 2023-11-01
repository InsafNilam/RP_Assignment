import 'dart:io';

import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:chat_application/common/repositories/common_firebase_storage.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/models/chat_contact.dart';
import 'package:chat_application/models/status_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final statusRepositoryProvider = Provider((ref) => StatusRepository(
    firebaseFirestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref));

class StatusRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusRepository(
      {required this.firebaseFirestore, required this.auth, required this.ref});

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      String imageUrl = await ref
          .read(commonFirebaseStorageProvider)
          .storeFileToFirebase('/status/$statusId/$uid', statusImage);

      List<String> uidWhoCanSee = [];
      var uids = await firebaseFirestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .get();

      uidWhoCanSee.add(auth.currentUser!.uid);

      for (var uid in uids.docs) {
        ChatContact data = ChatContact.fromMap(uid.data());
        uidWhoCanSee.add(data.contactId);
      }

      List<String> statusImageURLs = [];
      var statusSnapshot = await firebaseFirestore
          .collection('status')
          .where('uid', isEqualTo: uid)
          .where('createdAt',
              isLessThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch)
          .get();

      if (statusSnapshot.docs.isNotEmpty) {
        StatusModel status = StatusModel.fromMap(statusSnapshot.docs[0].data());
        statusImageURLs = status.photoURL;
        statusImageURLs.add(imageUrl);
        await firebaseFirestore
            .collection('status')
            .doc(statusSnapshot.docs[0].id)
            .update({
          'photoURL': statusImageURLs,
        });
        return;
      } else {
        statusImageURLs = [imageUrl];
      }
      StatusModel status = StatusModel(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoURL: statusImageURLs,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );

      await firebaseFirestore
          .collection('status')
          .doc(statusId)
          .set(status.toMap());
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

  Future<List<StatusModel>> getStatus(BuildContext context) async {
    List<StatusModel> statusData = [];
    try {
      var statusSnapshot = await firebaseFirestore
          .collection('status')
          .where('createdAt',
              isGreaterThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch)
          .get();
      for (var tempData in statusSnapshot.docs) {
        StatusModel tempStatus = StatusModel.fromMap(tempData.data());
        if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
          statusData.add(tempStatus);
        }
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
    return statusData;
  }
}
