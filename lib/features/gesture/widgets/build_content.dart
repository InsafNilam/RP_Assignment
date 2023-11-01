import 'package:chat_application/features/gesture/controllers/database.dart';
import 'package:chat_application/features/gesture/widgets/update_dailog.dart';
import 'package:chat_application/models/gesture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BuildContent extends StatelessWidget {
  final Gesture gesture;

  const BuildContent({
    super.key,
    required this.gesture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
          startActionPane: ActionPane(
            // On Sliding to the right side of the container, the widget displays an edit button, once clicked opens a dialog where the user can edit the todo item's properties from the Local Database.
            extentRatio: 0.2,
            motion: const ScrollMotion(),
            children: [
              const SizedBox(width: 8),
              SlidableAction(
                onPressed: ((context) {
                  UpdateDialogWidget.show(
                    context,
                    gesture,
                    gesture.objectKey,
                    gesture.objectValue,
                    gesture.objectUse,
                  );
                }),
                borderRadius: BorderRadius.circular(8.0),
                icon: Icons.edit,
                foregroundColor: Colors.white,
                backgroundColor: Colors.green.shade500,
              ),
              const SizedBox(width: 8),
            ],
          ),
          endActionPane: ActionPane(
              // On Sliding to the left side of the container, the widget displays an delete button, once clicked opens a dialog where the user can delete the todo item from the Local Database.
              motion: const ScrollMotion(),
              extentRatio: 0.2,
              children: [
                const SizedBox(width: 8),
                SlidableAction(
                  onPressed: ((context) {
                    deleteTask(gesture);
                  }),
                  borderRadius: BorderRadius.circular(8.0),
                  icon: Icons.delete,
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(width: 8),
              ]),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 20),
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
              enabled: gesture
                  .objectUse, // Depending on whether a gesture should be used or not, the widgets will fade or be normal.
              subtitle: Text(
                'Value: ${gesture.objectValue}',
                style: TextStyle(
                  // Depending on whether a task is complete or incomplete, the text will be underlined or be normal.
                  decoration: !gesture.objectUse
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
                  value: gesture.objectUse,
                  onChanged: (bool? value) {
                    // Updates the task with the new value of isComplete which will be true if the Checkbox is checked and false if it is unchecked.
                    editTask(
                      gesture,
                      gesture.objectKey,
                      gesture.objectValue,
                      value!,
                    );
                  }),
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
