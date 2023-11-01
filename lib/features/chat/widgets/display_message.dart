import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/common/enums/message_enum.dart';
import 'package:chat_application/features/chat/widgets/item_video_player.dart';
import 'package:flutter/material.dart';

class DisplayMessage extends StatelessWidget {
  final String message;
  final MessageEnum type;

  const DisplayMessage({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();

    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          )
        : type == MessageEnum.video
            ? ItemVideoPlayer(videoURL: message)
            : type == MessageEnum.audio
                ? StatefulBuilder(builder: (context, setState) {
                    return IconButton(
                      constraints: const BoxConstraints(minWidth: 100),
                      onPressed: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                          setState(() {
                            isPlaying = false;
                          });
                        } else {
                          await audioPlayer.play(UrlSource(message));
                          setState(() {
                            isPlaying = true;
                          });
                        }
                      },
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                      ),
                    );
                  })
                : CachedNetworkImage(
                    imageUrl: message,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error),
                    ),
                  );
  }
}
