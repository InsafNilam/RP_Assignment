import 'dart:io';
import 'dart:typed_data';
import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:chat_application/common/repositories/common_firebase_storage.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/features/auth/screens/login_screen.dart';
import 'package:chat_application/features/auth/screens/otp_screen.dart';
import 'package:chat_application/features/auth/screens/user_info_screen.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:chat_application/screens/chat_page.dart';
import 'package:chat_application/services/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  static final notifications = NotificationServices();

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    UserModel? user;

    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  Future<List<UserModel>> getUserData() async {
    var users = await firestore.collection('users').get();
    List<UserModel> usersList = [];

    // Iterate over the users and add them to the list.
    for (var user in users.docs) {
      UserModel data = UserModel.fromMap(user.data());
      if (data.uid != auth.currentUser!.uid) {
        usersList.add(data);
      }
    }
    return usersList;
  }

  Stream<List<String>> getSpeechDataStream() {
    DatabaseReference reference = FirebaseDatabase.instance.ref('speech_data');
    // Use the onValue event to listen for changes in the data
    Stream<DatabaseEvent> dataStream = reference.onValue;
    // Convert the event stream into a stream of List<String>
    Stream<List<String>> stringListStream = dataStream.map((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null && snapshot.value is Map) {
        List<String> data = [];
        (snapshot.value as Map).forEach((key, value) {
          if (value is String) {
            data.add(value);
          }
        });
        return data;
      }
      return <String>[]; // Return an empty list if there's no data or data is in an unexpected format
    });

    return stringListStream;
  }

  Future<List<String>> getSpeechDataList() async {
    List<String> items = [];

    DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref('speech_data').get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        items.add(value);
      });
    }

    return items;
  }

  Future<List<String>> getSpeechDataKeyList() async {
    List<String> items = [];

    DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref('speech_data').get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      for (String key in data.keys) {
        items.add(key);
      }
    }
    return items;
  }

  Stream<List<Uint8List>> getCameraDataStream() {
    DatabaseReference reference = FirebaseDatabase.instance.ref('esp32-cam');
    // Use the onValue event to listen for changes in the data
    Stream<DatabaseEvent> dataStream = reference.onValue;
    // Convert the event stream into a stream of List<Unit8List>
    Stream<List<Uint8List>> unit8ListStream = dataStream.map((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null && snapshot.value is Map) {
        List<Uint8List> data = [];
        (snapshot.value as Map).forEach((key, value) {
          if (value.containsKey("photo")) {
            // Add the "photo" field to the items list
            final UriData? image = Uri.parse(value["photo"]).data;
            // Will returns your image as Uint8List
            Uint8List photo = image!.contentAsBytes();
            data.add(photo);
          }
        });
        return data;
      }
      return <Uint8List>[]; // Return an empty list if there's no data or data is in an unexpected format
    });

    return unit8ListStream;
  }

  Future<List<String>> getCameraDataKeyList() async {
    List<String> items = [];
    DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref('esp32-cam').get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      // Iterate through the data map
      for (String key in data.keys) {
        items.add(key);
      }
    }
    return items;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: ((String verificationId, int? resetToken) async {
          Get.toNamed(
            OTPScreen.routeName,
            arguments: {
              'verificationId': verificationId,
            },
          );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
        phoneNumber: phoneNumber,
      );
    } on FirebaseAuthException catch (err) {
      Future(
        () => showSnackbar(
          context: context,
          content: err.message!,
          type: SnackBarEnum.error,
        ),
      );
    }
  }

  void signOut(BuildContext context) async {
    try {
      await auth.signOut();
      Future(
        () => Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        ),
      );
    } on FirebaseAuthException catch (err) {
      Future(
        () => showSnackbar(
          context: context,
          content: err.message!,
          type: SnackBarEnum.error,
        ),
      );
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );

      await auth.signInWithCredential(credential);
      var userData =
          await firestore.collection('users').doc(auth.currentUser?.uid).get();

      if (userData.data() != null) {
        await notifications.requestPermission();
        await notifications.getToken();
        Future(
          () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
            (route) => false,
          ),
        );
      } else {
        Future(
          () => Navigator.pushNamedAndRemoveUntil(
            context,
            UserInfoScreen.routeName,
            (route) => false,
          ),
        );
      }
    } on FirebaseAuthException catch (err) {
      Future(
        () => showSnackbar(
          context: context,
          content: err.message!,
          type: SnackBarEnum.error,
        ),
      );
    }
  }

  void saveUserDataToFirebase({
    required String name,
    required String status,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://i.ibb.co/dWmBfNJ/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg';

      if (profilePic != null) {
        photoUrl =
            await ref.read(commonFirebaseStorageProvider).storeFileToFirebase(
                  'profilePic/$uid',
                  profilePic,
                );
      }

      var user = UserModel(
        name: name,
        status: status,
        uid: uid,
        profilePic: photoUrl,
        isOnline: true,
        phoneNumber: auth.currentUser!.phoneNumber!,
        groupId: [],
        token: '',
      );

      await firestore.collection('users').doc(uid).set(user.toMap());
      await notifications.requestPermission();
      await notifications.getToken();

      Future(
        () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
          (route) => false,
        ),
      );
    } catch (e) {
      Future(
        () => showSnackbar(
          context: context,
          content: e.toString(),
          type: SnackBarEnum.error,
        ),
      );
    }
  }

  Stream<UserModel> userData(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

  void setUserState(bool isOnline) async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'isOnline': isOnline});
  }
}
