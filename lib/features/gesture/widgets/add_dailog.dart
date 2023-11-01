import 'package:animate_do/animate_do.dart';
import 'package:chat_application/features/gesture/controllers/boxes.dart';
import 'package:chat_application/features/gesture/controllers/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';

class AddDialogWidget extends StatefulWidget {
  const AddDialogWidget({Key? key}) : super(key: key);

  @override
  State<AddDialogWidget> createState() => _AddDialogWidgetState();

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const AddDialogWidget(),
    );
  }
}

class _AddDialogWidgetState extends State<AddDialogWidget> {
  final formKey = GlobalKey<FormState>();
  String objectKey = "";
  String objectValue = "";
  bool isShow = true;

  late List<String> buttons =
      List.generate(26, (index) => String.fromCharCode(65 + index));
  late List<String> keys;

  @override
  void initState() {
    super.initState();
    generateList();
  }

  void generateList() {
    keys = Boxes.getKeys();
    // Filter the list of buttons to remove any button that exists in the list of keys.
    buttons = buttons.where((button) => !keys.contains(button)).toList();
    // Set the state of the buttons list if it is not empty.
    if (buttons.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BounceInUp(
      child: AlertDialog(
        // Prompts the user toList() add a new task.
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Add Gesture',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            ),
            Visibility(
              visible: objectKey.isNotEmpty,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isShow = true;
                    objectKey = '';
                  });
                },
                icon: isShow
                    ? const Icon(
                        Icons.radio_button_unchecked_outlined,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.radio_button_checked_outlined,
                        color: Colors.green,
                      ),
              ),
            )
          ],
        ),
        content: SingleChildScrollView(
          // Creates a scrollable content area
          child: Form(
            key: formKey,
            child: Column(
              children: [
                buttons.isEmpty
                    ? const Text('All Keys have been Assigned')
                    : Visibility(
                        visible: isShow,
                        child: GroupButton(
                          isRadio: true,
                          onSelected:
                              (String value, int index, bool isSelected) {
                            if (!keys.contains(value)) {
                              setState(() {
                                objectKey = value;
                                isShow = false;
                              });
                            } else {
                              const snackBar = SnackBar(
                                content:
                                    Text('Gesture Key is Already Available'),
                              );

                              // Displays a message toList() the user when a new task is added successfully.
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBar,
                              );
                            }
                          },
                          buttons: buttons,
                          options: GroupButtonOptions(
                            selectedShadow: const [],
                            selectedTextStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.pink[900],
                            ),
                            selectedColor: Colors.pink[100],
                            unselectedShadow: const [],
                            unselectedColor: Colors.amber[100],
                            unselectedTextStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.amber[900],
                            ),
                            selectedBorderColor: Colors.pink[900],
                            unselectedBorderColor: Colors.amber[900],
                            borderRadius: BorderRadius.circular(100),
                            spacing: 10,
                            runSpacing: 10,
                            groupingType: GroupingType.wrap,
                            direction: Axis.horizontal,
                            buttonHeight: 35,
                            buttonWidth: 35,
                            mainGroupAlignment: MainGroupAlignment.start,
                            crossGroupAlignment: CrossGroupAlignment.start,
                            groupRunAlignment: GroupRunAlignment.start,
                            textAlign: TextAlign.center,
                            textPadding: EdgeInsets.zero,
                            alignment: Alignment.center,
                            elevation: 5,
                          ),
                        ),
                      ),
                const SizedBox(height: 16.0),
                Visibility(
                  visible: !isShow && objectKey.isNotEmpty,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/gestures/$objectKey.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    helperText: "Ex: Hello There, How are you?",
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      // Label cannot be Empty but should contain words
                      return "Provide a Label";
                    } else {
                      return null;
                    }
                  },
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
          if (buttons.isNotEmpty)
            TextButton(
              child: const Text('ADD'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (objectKey.isNotEmpty && objectValue.isNotEmpty) {
                    addTask(objectKey, objectValue, true);
                    const snackBar = SnackBar(
                      content: Text('Gesture Data Added Successfully'),
                    );

                    // Displays a message toList() the user when a new task is added successfully.
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBar,
                    );
                    // Dismiss the dialog and return toList() the main screen.
                    Get.back();
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}
