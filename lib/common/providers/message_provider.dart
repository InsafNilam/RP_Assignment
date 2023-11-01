import 'package:chat_application/common/enums/message_enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageReplyProvider = StateProvider<MessageReply?>((ref) => null);

class MessageReply {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;

  MessageReply(
      {required this.message, required this.isMe, required this.messageEnum});
}
