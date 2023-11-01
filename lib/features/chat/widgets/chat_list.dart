import 'package:animate_do/animate_do.dart';
import 'package:chat_application/common/enums/message_enum.dart';
import 'package:chat_application/common/providers/message_provider.dart';
import 'package:chat_application/common/widgets/error.dart';
import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/chat/controller/chat_controller.dart';
import 'package:chat_application/features/chat/widgets/my_message_card.dart';
import 'package:chat_application/features/chat/widgets/sender_message_card.dart';
import 'package:chat_application/models/chat_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroup;
  const ChatList({
    Key? key,
    required this.receiverUserId,
    required this.isGroup,
  }) : super(key: key);

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  late ScrollController messageController;

  @override
  void initState() {
    super.initState();
    messageController = ScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      messageController.jumpTo(
        messageController.position.maxScrollExtent,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    ref.read(messageReplyProvider.notifier).update(
          (state) => MessageReply(
            message: message,
            isMe: isMe,
            messageEnum: messageEnum,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream: widget.isGroup
            ? ref
                .read(chatControllerProvider)
                .groupStream(widget.receiverUserId)
            : ref
                .read(chatControllerProvider)
                .chatStream(widget.receiverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          } else if (snapshot.connectionState == ConnectionState.active) {
            return ListView.builder(
              // addAutomaticKeepAlives: true, // Add this property
              // cacheExtent: double.infinity, // And this one
              controller: messageController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final messageData = snapshot.data![index];
                if (!messageData.isSeen &&
                    messageData.receiverId ==
                        FirebaseAuth.instance.currentUser!.uid) {
                  ref.read(chatControllerProvider).setChatMessageSeen(
                        context,
                        widget.receiverUserId,
                        messageData.messageId,
                      );
                }
                if (messageData.senderId ==
                    FirebaseAuth.instance.currentUser!.uid) {
                  return SlideInRight(
                    child: MyMessageCard(
                      message: messageData.text,
                      type: messageData.type,
                      date: DateFormat.Hm().format(messageData.timeSent),
                      repliedText: messageData.repliedMessage,
                      username: messageData.repliedTo,
                      messageType: messageData.repliedType,
                      onLeftSwipe: () => onMessageSwipe(
                        messageData.text,
                        true,
                        messageData.type,
                      ),
                      isSeen: messageData.isSeen,
                    ),
                  );
                }
                return SlideInLeft(
                  child: SenderMessageCard(
                    message: messageData.text,
                    date: DateFormat.Hm().format(messageData.timeSent),
                    type: messageData.type,
                    repliedText: messageData.repliedMessage,
                    username: messageData.repliedTo,
                    messageType: messageData.repliedType,
                    onRightSwipe: () => onMessageSwipe(
                      messageData.text,
                      false,
                      messageData.type,
                    ),
                  ),
                );
              },
            );
          } else {
            return const ErrorScreen(
              error: 'No Data',
            );
          }
        });
  }
}
