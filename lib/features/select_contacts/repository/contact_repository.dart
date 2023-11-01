import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:chat_application/features/chat/screens/mobile_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

final contactRepositoryProvider = Provider(
  (ref) => ContactRepository(
    firebaseFirestore: FirebaseFirestore.instance,
  ),
);

class ContactRepository {
  final FirebaseFirestore firebaseFirestore;

  ContactRepository({required this.firebaseFirestore});

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (err) {
      debugPrint(err.toString());
    }
    return contacts;
  }

  void selectUser(UserModel user, BuildContext context) {
    try {
      Get.toNamed(
        MobileChatScreen.routeName,
        arguments: {
          'name': user.name,
          'uid': user.uid,
          'profilePic': user.profilePic,
          'isGroup': false,
        },
      );
    } catch (err) {
      showSnackbar(
          context: context, content: err.toString(), type: SnackBarEnum.error);
    }
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firebaseFirestore.collection('users').get();
      bool isFound = false;

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNumber =
            selectedContact.phones[0].number.replaceAll(" ", "");

        if (selectedPhoneNumber == userData.phoneNumber) {
          isFound = true;
          Get.toNamed(
            MobileChatScreen.routeName,
            arguments: {
              'name': userData.name,
              'uid': userData.uid,
              'profilePic': userData.profilePic,
              'isGroup': false,
            },
          );
        }
      }
      if (!isFound) {
        Future(
          () => showSnackbar(
            context: context,
            content: 'This number doesn\'t exits on this application',
            type: SnackBarEnum.info,
          ),
        );
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
