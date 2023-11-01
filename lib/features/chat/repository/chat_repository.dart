import 'dart:io';
import 'package:chat_application/common/enums/message_enum.dart';
import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:chat_application/common/providers/message_provider.dart';
import 'package:chat_application/common/repositories/common_firebase_storage.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/models/chat_contact.dart';
import 'package:chat_application/models/chat_message.dart';
import 'package:chat_application/models/chat_group.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
      firebaseFirestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance),
);

class ChatRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firebaseFirestore, required this.auth});

  Stream<List<ChatContact>> getChatContacts() {
    return firebaseFirestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firebaseFirestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();

        var user = UserModel.fromMap(userData.data()!);
        contacts.add(ChatContact(
          name: user.name,
          profilePic: user.profilePic,
          contactId: user.uid,
          timeSent: chatContact.timeSent,
          lastMessage: chatContact.lastMessage,
        ));
      }
      return contacts;
    });
  }

  Stream<List<GroupModel>> getChatGroups() {
    return firebaseFirestore.collection('groups').snapshots().map((event) {
      List<GroupModel> groups = [];
      for (var document in event.docs) {
        var group = GroupModel.fromMap(document.data());
        if (group.membersId.contains(auth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    return firebaseFirestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(
          Message.fromMap(document.data()),
        );
      }
      return messages;
    });
  }

  Stream<List<Message>> getGroupStream(String groupId) {
    return firebaseFirestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(
          Message.fromMap(document.data()),
        );
      }
      return messages;
    });
  }

  void _saveDataToContactSubCollection(
    UserModel senderUserData,
    UserModel? receiverUserData,
    String text,
    DateTime timeSent,
    String receiverUserId,
    bool isGroup,
  ) async {
    if (isGroup) {
      await firebaseFirestore.collection('groups').doc(receiverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      var receiverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );

      await firebaseFirestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .set(
            receiverChatContact.toMap(),
          );

      var senderChatContact = ChatContact(
        name: receiverUserData!.name,
        profilePic: receiverUserData.profilePic,
        contactId: receiverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );

      await firebaseFirestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .set(
            senderChatContact.toMap(),
          );
    }
  }

  void _saveMessageToMessageSubCollection(
    String receiverUserId,
    String text,
    DateTime timeSent,
    String messageId,
    String username,
    String? receiverUsername,
    MessageEnum messageType,
    MessageReply? messageReply,
    bool isGroup,
  ) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? username
              : receiverUsername ?? '',
      repliedType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );

    if (isGroup) {
      await firebaseFirestore
          .collection('groups')
          .doc(receiverUserId)
          .collection('chats')
          .doc(messageId)
          .set(message.toMap());
    } else {
      await firebaseFirestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      await firebaseFirestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUserData,
    required MessageReply? messageReply,
    required bool isGroup,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? receiverUserData;

      if (!isGroup) {
        var userData = await firebaseFirestore
            .collection('users')
            .doc(receiverUserId)
            .get();
        receiverUserData = UserModel.fromMap(userData.data()!);
      }

      _saveDataToContactSubCollection(
        senderUserData,
        receiverUserData,
        text,
        timeSent,
        receiverUserId,
        isGroup,
      );

      var messageId = const Uuid().v1();

      _saveMessageToMessageSubCollection(
        receiverUserId,
        text,
        timeSent,
        messageId,
        receiverUserData!.name,
        senderUserData.name,
        MessageEnum.text,
        messageReply,
        isGroup,
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

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroup,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String fileURL = await ref
          .read(commonFirebaseStorageProvider)
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId',
              file);

      UserModel? receiverUserData;
      var userDataMap =
          await firebaseFirestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMessage;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMessage = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMessage = '📹 Video';
          break;
        case MessageEnum.audio:
          contactMessage = '🎙️ Audio';
          break;
        case MessageEnum.gif:
          contactMessage = 'GIF';
          break;
        default:
          contactMessage = 'GIF';
          break;
      }

      _saveDataToContactSubCollection(
        senderUserData,
        receiverUserData,
        contactMessage,
        timeSent,
        receiverUserId,
        isGroup,
      );
      _saveMessageToMessageSubCollection(
        receiverUserId,
        fileURL,
        timeSent,
        messageId,
        senderUserData.name,
        receiverUserData.name,
        messageEnum,
        messageReply,
        isGroup,
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

  void sendGIFMessage({
    required BuildContext context,
    required String gifURL,
    required String receiverUserId,
    required UserModel senderUserData,
    required MessageReply? messageReply,
    required bool isGroup,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;
      var userData =
          await firebaseFirestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userData.data()!);

      _saveDataToContactSubCollection(
        senderUserData,
        receiverUserData,
        "GIF",
        timeSent,
        receiverUserId,
        isGroup,
      );

      var messageId = const Uuid().v1();

      _saveMessageToMessageSubCollection(
          receiverUserId,
          gifURL,
          timeSent,
          messageId,
          receiverUserData.name,
          senderUserData.name,
          MessageEnum.gif,
          messageReply,
          isGroup);
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

  void setChatMessageSeen(
    BuildContext context,
    String receiverUserId,
    String messageId,
  ) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firebaseFirestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
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
