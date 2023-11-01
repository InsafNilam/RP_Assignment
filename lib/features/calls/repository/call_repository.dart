import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/features/calls/screens/call_screen.dart';
import 'package:chat_application/models/chat_call.dart';
import 'package:chat_application/models/chat_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

final callRepositoryProvider = Provider(
  (ref) => CallRepository(
    firebaseFirestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class CallRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth auth;

  CallRepository({required this.firebaseFirestore, required this.auth});

  Stream<DocumentSnapshot> get callStream => firebaseFirestore
      .collection('calls')
      .doc(auth.currentUser!.uid)
      .snapshots();

  void makeCall(
    BuildContext context,
    CallModel senderCallData,
    CallModel receiverCallData,
  ) async {
    try {
      await firebaseFirestore
          .collection('calls')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await firebaseFirestore
          .collection('calls')
          .doc(senderCallData.receiverId)
          .set(receiverCallData.toMap());

      Get.to(
        () => CallScreen(
          channelId: senderCallData.callId,
          call: senderCallData,
          isGroup: false,
        ),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
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

  void makeGroupCall(
    BuildContext context,
    CallModel senderCallData,
    CallModel receiverCallData,
  ) async {
    try {
      await firebaseFirestore
          .collection('calls')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());

      var groupSnapshot = await firebaseFirestore
          .collection('groups')
          .doc(senderCallData.receiverId)
          .get();

      GroupModel group = GroupModel.fromMap(groupSnapshot.data()!);
      for (var id in group.membersId) {
        await firebaseFirestore
            .collection('calls')
            .doc(id)
            .set(receiverCallData.toMap());
      }
      Get.to(
        () => CallScreen(
          channelId: senderCallData.callId,
          call: senderCallData,
          isGroup: true,
        ),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
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

  void endCall(
    BuildContext context,
    String callerId,
    String receiverId,
  ) async {
    try {
      await firebaseFirestore.collection('calls').doc(callerId).delete();
      await firebaseFirestore.collection('calls').doc(receiverId).delete();
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

  void endGroupCall(
    BuildContext context,
    String callerId,
    String receiverId,
  ) async {
    try {
      await firebaseFirestore.collection('calls').doc(callerId).delete();

      var groupSnapshot =
          await firebaseFirestore.collection('groups').doc(receiverId).get();

      GroupModel group = GroupModel.fromMap(groupSnapshot.data()!);
      for (var id in group.membersId) {
        await firebaseFirestore.collection('calls').doc(id).delete();
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
