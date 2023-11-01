import 'package:chat_application/features/gesture/controllers/boxes.dart';
import 'package:chat_application/models/gesture.dart';
import 'package:flutter/material.dart';

class BuildBotContent extends StatelessWidget {
  final Gesture gesture;

  const BuildBotContent({
    super.key,
    required this.gesture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, offset: Offset(0, 2), blurRadius: 20),
            ],
          ),
          child: ListTile(
            dense: true,
            title: Text(
              'Key: ${gesture.objectKey}',
              style: TextStyle(
                decoration: !gesture.objectUse
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            enabled: Boxes.getGesture(gesture.objectKey) != null &&
                    Boxes.getGesture(gesture.objectKey)!.objectUse
                ? false
                : true, // Depending on whether a gesture should be used or not, the widgets will fade or be normal.
            subtitle: Text(
              'Value: ${gesture.objectValue}',
              style: TextStyle(
                // Depending on whether a task is complete or incomplete, the text will be underlined or be normal.
                decoration: Boxes.getGesture(gesture.objectKey) != null &&
                        Boxes.getGesture(gesture.objectKey)!.objectUse
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: AssetImage(
                'assets/gestures/${gesture.objectKey}.jpg',
              ),
              radius: 23,
            ),
            trailing: Checkbox(
              shape: const CircleBorder(), // Makes a round Checkbox
              activeColor: const Color(0xff17B169),
              value: Boxes.getGesture(gesture.objectKey) != null &&
                      Boxes.getGesture(gesture.objectKey)!.objectUse
                  ? false
                  : true,
              onChanged: (bool? value) {},
            ),
          ),
        ),
        const SizedBox(
          height: 8.0,
        )
      ],
    );
  }
}
