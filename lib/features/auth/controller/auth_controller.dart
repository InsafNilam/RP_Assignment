import 'dart:io';
import 'dart:typed_data';

import 'package:chat_application/features/auth/repository/auth_repository.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData();
});

final getUserProvider = FutureProvider((ref) {
  final contactRepository = ref.watch(authControllerProvider);
  return contactRepository.getUsers();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;

  AuthController({
    required this.ref,
    required this.authRepository,
  });

  Future<UserModel?> getUserData() async {
    UserModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  Future<List<UserModel>> getUsers() async {
    List<UserModel> users = await authRepository.getUserData();
    return users;
  }

  Stream<List<String>> getSpeechDataStream() {
    return authRepository.getSpeechDataStream();
  }

  Future<List<String>> getSpeechDataList() async {
    List<String> items = await authRepository.getSpeechDataList();
    return items;
  }

  Future<List<String>> getSpeechDataKeyList() async {
    List<String> items = await authRepository.getSpeechDataKeyList();
    return items;
  }

  Future<List<String>> getCameraDataKeyList() async {
    List<String> items = await authRepository.getCameraDataKeyList();
    return items;
  }

  Stream<List<Uint8List>> getCameraDataStream() {
    return authRepository.getCameraDataStream();
  }

  void signInWithPhone(
    BuildContext context,
    String phoneNumber,
  ) {
    authRepository.signInWithPhone(context, phoneNumber);
  }

  void signOut(
    BuildContext context,
  ) {
    authRepository.signOut(context);
  }

  void verifyOTP(
    BuildContext context,
    String verificationId,
    String userOTP,
  ) {
    authRepository.verifyOTP(
      context: context,
      verificationId: verificationId,
      userOTP: userOTP,
    );
  }

  void saveUserDataToFirebase(
    BuildContext context,
    String name,
    String status,
    File? profilePic,
  ) {
    authRepository.saveUserDataToFirebase(
      name: name,
      status: status,
      profilePic: profilePic,
      ref: ref,
      context: context,
    );
  }

  Stream<UserModel> userData(String userId) {
    return authRepository.userData(userId);
  }

  void setUserState(bool isOnline) {
    authRepository.setUserState(isOnline);
  }
}
