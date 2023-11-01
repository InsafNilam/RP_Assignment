import 'package:hive/hive.dart';
part 'gesture.g.dart';

// Defines a class that should be serialized to a Hive database using the @HiveObject, @HiveType and @HiveField annotations. This allows instances of the class to be stored and retrieved from the database as needed, making it easy to persist data.

@HiveType(typeId: 0)
//Indicating the class should be serialized to a Hive database and the argument specifies a unique identifier for the class in the database.
class Gesture extends HiveObject {
  // Annotates the objectKey property should be serialized to the Hive database
  @HiveField(0)
  String objectKey;
  // Annotates the objectValue property should be serialized to the Hive database
  @HiveField(1)
  String objectValue;
  // Annotates the objectUse property should be serialized to the Hive database
  @HiveField(2)
  bool objectUse;

  Gesture({
    required this.objectKey,
    required this.objectValue,
    required this.objectUse,
  });
}

// Should Run 'flutter packages pub run build_runner build' to create an Adapter class for the application to be used with Hive Database
