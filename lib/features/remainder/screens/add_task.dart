import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/common/widgets/input_field.dart';
import 'package:chat_application/features/remainder/controller/task_controller.dart';
import 'package:chat_application/models/task.dart';
import 'package:chat_application/pallete.dart';
import 'package:chat_application/services/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late NotificationServices notifyHelper;
  DateTime _selectedDate = DateTime.now();
  String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(hours: 1, minutes: 10)))
      .toString();
  String _startTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 10)))
      .toString();
  int _selectedRemind = 5;
  List<int> remindList = [
    5,
    10,
    15,
    20,
  ];

  String _selectedRepeat = "None";
  List<String> repeatList = [
    "None",
    "Daily",
    "Weekly",
    "Monthly",
  ];

  int _selectedColor = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
    notifyHelper = NotificationServices();
  }

  Future<void> getDate() async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (pickerDate != null) {
      setState(() {
        _selectedDate = pickerDate;
      });
    } else {
      debugPrint("It's null or Something went wrong");
    }
  }

  Future<void> getTime(bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_startTime.split(':')[0]),
        minute: int.parse(_startTime.split(':')[1].split(" ")[0]),
      ),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime == null) {
      debugPrint('Time Cancelled');
    } else if (isStartTime == true) {
      setState(() {
        _startTime = pickedTime.format(context);
      });
    } else if (isStartTime == false) {
      setState(() {
        _endTime = pickedTime.format(context);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _noteController.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF1d2034),
      appBar: AppBar(
        backgroundColor: const Color(0XFF014e4b),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InputField(
                title: 'Title',
                controller: _titleController,
                hint: 'Enter your Title',
              ),
              InputField(
                title: 'Note',
                controller: _noteController,
                hint: 'Enter your Note',
              ),
              InputField(
                title: 'Date',
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  onPressed: () {
                    getDate();
                  },
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      title: 'Start Time',
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () {
                          getTime(true);
                        },
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: InputField(
                      title: 'End Time',
                      hint: _endTime,
                      widget: IconButton(
                        onPressed: () {
                          getTime(false);
                        },
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              InputField(
                title: 'Remind',
                hint: '$_selectedRemind minutes early',
                widget: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DropdownButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    underline: Container(
                      height: 0,
                    ),
                    items: remindList
                        .map<DropdownMenuItem<String>>(
                          (int value) => DropdownMenuItem<String>(
                            value: value.toString(),
                            child: Text(
                              value.toString(),
                              style: const TextStyle(
                                color: Color(0xFF0e2e3b),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedRemind = int.parse(value!);
                      });
                    },
                    iconSize: 32,
                    elevation: 4,
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              InputField(
                title: 'Repeat',
                hint: _selectedRepeat,
                widget: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DropdownButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    underline: Container(height: 0),
                    items: repeatList
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Color(0xFF0e2e3b),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedRepeat = value!;
                      });
                    },
                    iconSize: 32,
                    elevation: 4,
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 18.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Color",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Wrap(
                        children: List<Widget>.generate(
                          3,
                          (int index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: index == 0
                                    ? Pallete.bluishColor
                                    : index == 1
                                        ? Pallete.pinkishColor
                                        : Pallete.yellowishColor,
                                child: _selectedColor == index
                                    ? const Icon(
                                        Icons.done,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_titleController.text.isNotEmpty &&
                          _noteController.text.isNotEmpty) {
                        Task task = Task(
                          note: _noteController.text,
                          title: _titleController.text,
                          date: DateFormat.yMd().format(_selectedDate),
                          startTime: _startTime,
                          endTime: _endTime,
                          remind: _selectedRemind,
                          repeat: _selectedRepeat,
                          color: _selectedColor,
                          isCompleted: 0,
                        );

                        int id = await _taskController.addTask(task: task);

                        String start = _startTime.replaceAll(' ', "");
                        DateTime startTime =
                            DateFormat("h:mma").parse(start).subtract(
                                  Duration(minutes: _selectedRemind),
                                );
                        String time = DateFormat('HH:mm').format(startTime);

                        await notifyHelper.scheduledNotification(
                          id,
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          int.parse(time.split(':')[0]),
                          int.parse(time.split(':')[1]),
                          _selectedRepeat,
                          task,
                        );
                        Get.back();
                      } else {
                        showSnackbar(
                          content: 'All fields are required!',
                          context: context,
                          type: SnackBarEnum.info,
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 12.0),
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Pallete.bluishColor,
                      ),
                      child: const Center(
                        child: Text(
                          'Create Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
