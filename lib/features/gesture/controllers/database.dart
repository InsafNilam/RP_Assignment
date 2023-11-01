import 'package:chat_application/features/gesture/controllers/boxes.dart';
import 'package:chat_application/models/gesture.dart';

//  Adds a new Gesture object to the "gesture_box" Hive database box. use of the Boxes class to retrieve the database box, avoids the need to hard-code the database box name throughout the codebase.

Future<void> addTask(
  String objectKey,
  String objectValue,
  bool objectUse,
) async {
  final gesture = Gesture(
    objectKey: objectKey,
    objectValue: objectValue,
    objectUse: objectUse,
  );
  // Retrieves the "gesture_box" in Hive database.
  final box = Boxes.getGestures();
  // Insert a new Gesture object to the "gesture_box" Hive database box.
  if (box.containsKey(objectKey)) {
    return;
  }
  box.put(objectKey, gesture);
}

// Edit an existing Gesture object in the "gesture_box" Hive database box. The changes to the object are persisted to the database.
void editTask(
  Gesture gesture,
  String objectKey,
  String objectValue,
  bool objectUse,
) {
  gesture.objectKey = objectKey;
  gesture.objectValue = objectValue;
  gesture.objectUse = objectUse;

  // Saves the updated Gesture object to the "gesture_box" Hive database box.
  gesture.save();
}

// Removes an existing Gesture object from the "gesture_box" Hive database box
void deleteTask(Gesture gesture) {
  gesture.delete();
}
