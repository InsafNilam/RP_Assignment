import 'package:chat_application/models/gesture.dart';
import 'package:hive/hive.dart';

class Boxes {
  // Access the 'gesture_box' in Hive database of the application, used for retrieving Todo objects
  static Box<Gesture> getGestures() => Hive.box<Gesture>('gesture_box');
  static Gesture? getGesture(key) => Hive.box<Gesture>('gesture_box').get(key);
  static List<String> getKeys() =>
      Hive.box<Gesture>('gesture_box').keys.toList().cast<String>();
}
