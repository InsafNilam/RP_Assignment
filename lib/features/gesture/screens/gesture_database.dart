import 'package:animate_do/animate_do.dart';
import 'package:buttons_panel/buttons_panel.dart';
import 'package:chat_application/features/gesture/controllers/boxes.dart';
import 'package:chat_application/features/gesture/controllers/gesture_list.dart';
import 'package:chat_application/features/gesture/widgets/build_bot_defined.dart';
import 'package:chat_application/features/gesture/widgets/build_content.dart';
import 'package:chat_application/models/gesture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GestureDatabase extends StatefulWidget {
  const GestureDatabase({super.key});

  @override
  State<GestureDatabase> createState() => _GestureDatabaseState();
}

class _GestureDatabaseState extends State<GestureDatabase> {
  late final ScrollController _scrollController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  // Responsible for cleaning up resources and ensuring that the application is closed properly
  @override
  void dispose() {
    super.dispose();
    // Closes the Hive box. This ensures that any changes made to the database are properly saved before the application is closed.
    Hive.box('gesture_box').close();
    // Free up any resources that the ScrollController uses
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ButtonsPanel(
        currentIndex: currentIndex,
        borderRadius: BorderRadius.circular(32),
        backgroundColor: const Color(0xFFEEE5E9),
        selectedItemBackgroundColor: Theme.of(context).primaryColor,
        selectedIconThemeData: const IconThemeData(
          color: Colors.white,
        ),
        padding: const EdgeInsets.only(top: 20.0, left: 24, right: 24),
        onTap: (value) => setState(() => currentIndex = value),
        children: const [
          Icon(Icons.person),
          Icon(Icons.smart_toy_outlined),
        ],
      ),
      Expanded(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(8.0).copyWith(top: 0),
          child: currentIndex == 0 ? _getUserDefined() : _getBotDefined(),
        ),
      ),
    ]);
  }

  Widget _getUserDefined() {
    return ValueListenableBuilder(
      // Listens for changes in the Hive database box named 'gesture_box' and updates its child widget whenever there is a change.
      valueListenable: Boxes.getGestures().listenable(),
      // listen for changes to the box named 'gesture_box'
      builder: (context, box, _) {
        final gestures = box.values.toList().cast<Gesture>();
        // Extracts the values from the box and casts them to a list of Gesture objects.
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: gestures.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (BuildContext context, int index) {
              Gesture gesture = gestures[index];
              return AnimationConfiguration.staggeredList(
                delay: const Duration(milliseconds: 100),
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: BuildContent(gesture: gesture),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _getBotDefined() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: gestures.length,
        padding: const EdgeInsets.only(top: 16),
        itemBuilder: (BuildContext context, int index) {
          Gesture gesture = gestures[index];
          return BounceInUp(
            delay: const Duration(milliseconds: 200),
            child: BuildBotContent(gesture: gesture),
          );
        },
      ),
    );
  }
}
