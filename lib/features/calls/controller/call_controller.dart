import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/features/calls/repository/call_repository.dart';
import 'package:chat_application/models/chat_call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(
      callRepository: callRepository, auth: FirebaseAuth.instance, ref: ref);
});

class CallController {
  final CallRepository callRepository;
  final FirebaseAuth auth;
  final ProviderRef ref;

  CallController(
      {required this.callRepository, required this.auth, required this.ref});

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeCall(
    BuildContext context,
    String receiverId,
    String receiverName,
    String receiverPic,
    bool isGroup,
  ) {
    ref.read(userDataAuthProvider).whenData((value) {
      String callId = const Uuid().v1();
      CallModel senderCallData = CallModel(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerPic: value.profilePic,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverPic: receiverPic,
        callId: callId,
        hasDialled: true,
      );

      CallModel receiverCallData = CallModel(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerPic: value.profilePic,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverPic: receiverPic,
        callId: callId,
        hasDialled: false,
      );

      if (isGroup) {
        callRepository.makeGroupCall(context, senderCallData, receiverCallData);
      } else {
        callRepository.makeCall(context, senderCallData, receiverCallData);
      }
    });
  }

  void endCall(BuildContext context, String callerId, String receiverId) {
    callRepository.endCall(context, callerId, receiverId);
  }

  void endGroupCall(BuildContext context, String callerId, String receiverId) {
    callRepository.endCall(context, callerId, receiverId);
  }
}
