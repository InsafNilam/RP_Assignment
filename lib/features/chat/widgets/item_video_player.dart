import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class ItemVideoPlayer extends StatefulWidget {
  final String videoURL;
  const ItemVideoPlayer({Key? key, required this.videoURL}) : super(key: key);

  @override
  State<ItemVideoPlayer> createState() => _ItemVideoPlayerState();
}

class _ItemVideoPlayerState extends State<ItemVideoPlayer> {
  late CachedVideoPlayerController videoController;
  bool isPlay = false;

  @override
  void initState() {
    super.initState();
    videoController = CachedVideoPlayerController.network(widget.videoURL)
      ..initialize().then((value) {
        videoController.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          CachedVideoPlayer(videoController),
          Align(
              alignment: Alignment.center,
              child: IconButton(
                  onPressed: () {
                    if (isPlay) {
                      videoController.pause();
                    } else {
                      videoController.play();
                    }
                    setState(() {
                      isPlay = !isPlay;
                    });
                  },
                  icon: isPlay
                      ? const Icon(Icons.pause_circle)
                      : const Icon(Icons.play_circle)))
        ],
      ),
    );
  }
}
