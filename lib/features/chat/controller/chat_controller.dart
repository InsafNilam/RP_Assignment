import 'dart:io';
import 'package:chat_application/common/enums/message_enum.dart';
import 'package:chat_application/common/providers/message_provider.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/features/chat/repository/chat_repository.dart';
import 'package:chat_application/models/chat_contact.dart';
import 'package:chat_application/models/chat_message.dart';
import 'package:chat_application/models/chat_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({required this.chatRepository, required this.ref});

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<GroupModel>> chatGroups() {
    return chatRepository.getChatGroups();
  }

  Stream<List<Message>> chatStream(String receiverUserId) {
    return chatRepository.getChatStream(receiverUserId);
  }

  Stream<List<Message>> groupStream(String groupId) {
    return chatRepository.getGroupStream(groupId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String receiverUserId,
    bool isGroup,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
              context: context,
              text: text,
              receiverUserId: receiverUserId,
              senderUserData: value!,
              messageReply: messageReply,
              isGroup: isGroup),
        );
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
    MessageEnum messageEnum,
    bool isGroup,
  ) async {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendFileMessage(
            context: context,
            file: file,
            receiverUserId: receiverUserId,
            senderUserData: value!,
            ref: ref,
            messageEnum: messageEnum,
            messageReply: messageReply,
            isGroup: isGroup,
          ),
        );
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void sendGIFMessage(
    BuildContext context,
    String gifURL,
    String receiverUserId,
    bool isGroup,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    int gifURLPartIndex = gifURL.lastIndexOf("-") + 1;
    String gifURLPart = gifURL.substring(gifURLPartIndex);
    String newGIFURL = 'https://i.giphy.com/media/$gifURLPart/200.gif';
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendGIFMessage(
              context: context,
              gifURL: newGIFURL,
              receiverUserId: receiverUserId,
              senderUserData: value!,
              messageReply: messageReply,
              isGroup: isGroup),
        );
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void setChatMessageSeen(
    BuildContext context,
    String receiverUserId,
    String messageId,
  ) {
    chatRepository.setChatMessageSeen(context, receiverUserId, messageId);
  }
}
