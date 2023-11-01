import 'package:chat_application/features/gesture/controllers/database.dart';
import 'package:chat_application/models/gesture.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateDialogWidget extends StatefulWidget {
  final Gesture gesture;
  final bool objectUse;
  final String objectKey;
  final String objectValue;

  const UpdateDialogWidget({
    super.key,
    required this.objectKey,
    required this.objectValue,
    required this.objectUse,
    required this.gesture,
  });

  @override
  State<UpdateDialogWidget> createState() => _UpdateDialogWidgetState();

  static Future<void> show(
    BuildContext context,
    Gesture gesture,
    String objectKey,
    String objectValue,
    bool objectUse,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => UpdateDialogWidget(
        objectKey: objectKey,
        objectValue: objectValue,
        objectUse: objectUse,
        gesture: gesture,
      ),
    );
  }
}

class _UpdateDialogWidgetState extends State<UpdateDialogWidget> {
  final formKey = GlobalKey<FormState>();
  late String objectKey;
  late String objectValue;
  late TextEditingController _objectValueController;

  @override
  void initState() {
    super.initState();
    _objectValueController = TextEditingController(text: widget.objectValue);
    objectKey = widget.objectKey;
    objectValue = widget.objectValue;
  }

  @override
  void dispose() {
    super.dispose();
    _objectValueController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Prompts the user to add a new task.
      title: const Text(
        'Update Gesture',
        style: TextStyle(
          color: Colors.green,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        // Creates a scrollable content area
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/gestures/$objectKey.jpg'),
                  ),
                ),
              ),
              TextFormField(
                controller: _objectValueController,
                autofocus: false,
                decoration: const InputDecoration(
                  labelText: "Label",
                  helperText: "Ex: Hello There, How are you?",
                ),
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    // Sub Task cannot be Empty but should contain alphabets commas and whitespaces
                    return "Provide a Label";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  objectValue = value.trim();
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('UPDATE'),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              if (objectValue.isNotEmpty) {
                editTask(
                  widget.gesture,
                  objectKey,
                  objectValue,
                  widget.objectUse,
                );
              }
              const snackBar = SnackBar(
                content: Text('Gesture Updated Successfully'),
              );
              // Displays a message to the user when an existing task is updated successfully.
              ScaffoldMessenger.of(context).showSnackBar(
                snackBar,
              );

              // Dismiss the dialog and return to the main screen.
              Get.back();
            }
          },
        ),
      ],
    );
  }
}
