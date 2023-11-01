import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/models/status_model.dart';
import 'package:get/get.dart';
import "package:story_view/story_view.dart";
import 'package:flutter/material.dart';

class StatusScreen extends StatefulWidget {
  static const String routeName = 'status-view';
  final StatusModel status;
  const StatusScreen({Key? key, required this.status}) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StoryController controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    initStoryPageItems();
  }

  void initStoryPageItems() {
    for (int i = 0; i < widget.status.photoURL.length; i++) {
      storyItems.add(
        StoryItem.pageImage(
          url: widget.status.photoURL[i],
          controller: controller,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty
          ? const Loader()
          : StoryView(
              storyItems: storyItems,
              controller: controller,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Get.back();
                }
              },
            ),
    );
  }
}
