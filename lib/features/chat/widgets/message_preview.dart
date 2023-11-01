import 'package:animate_do/animate_do.dart';
import 'package:chat_application/common/providers/message_provider.dart';
import 'package:chat_application/features/chat/widgets/display_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagePreview extends ConsumerWidget {
  const MessagePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);

    void cancelReply(WidgetRef ref) {
      ref.read(messageReplyProvider.notifier).update((state) => null);
    }

    return ZoomIn(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Color(0xFF36454F),
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      messageReply!.isMe ? 'You' : 'Opposite',
                      style: TextStyle(
                        color: messageReply.isMe
                            ? const Color(0XFF1CAC78)
                            : const Color(0XFF367588),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cancelReply(ref),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              DisplayMessage(
                message: messageReply.message,
                type: messageReply.messageEnum,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
