import 'package:animate_do/animate_do.dart';
import 'package:chat_application/features/remainder/controller/task_controller.dart';
import 'package:chat_application/features/remainder/screens/add_task.dart';
import 'package:chat_application/features/remainder/widget/task_tile.dart';
import 'package:chat_application/models/task.dart';
import 'package:chat_application/pallete.dart';
import 'package:chat_application/services/firebase_messaging.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RemainderPage extends StatefulWidget {
  const RemainderPage({super.key});

  @override
  State<RemainderPage> createState() => _RemainderPageState();
}

class _RemainderPageState extends State<RemainderPage> {
  DateTime _selectedDate = DateTime.now();
  late TaskController _taskController;
  late NotificationServices notifyHelper;
  bool isInitComplete = false;

  @override
  void initState() {
    super.initState();
    init().then((_) {
      setState(() {
        isInitComplete = true;
      });
    });
  }

  Future<void> init() async {
    _taskController = TaskController();
    notifyHelper = NotificationServices();
    await notifyHelper.initializeRemainderNotification();
    await notifyHelper.requestPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _taskController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF122923),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_delete_outlined,
                      size: 22,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Delete Remainders'),
                  ],
                ),
                onTap: () async {
                  _taskController.deleteAll();
                  await notifyHelper.cancelAllNotifications();
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      size: 22,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Revoke Notification'),
                  ],
                ),
                onTap: () async {
                  await notifyHelper.cancelAllNotifications();
                },
              ),
            ],
          ),
        ],
        title: BounceInDown(
          child: const Text(
            "Remainder",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0XFF00888c),
      ),
      body: !isInitComplete
          ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 25,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: LoadingAnimationWidget.fourRotatingDots(
                      size: 25,
                      color: Colors.amber.shade400,
                    ),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  margin:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SlideInLeft(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.yMMMd().format(DateTime.now()),
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFe6f99d),
                                ),
                              ),
                            ),
                            Text(
                              'Today',
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7db9b3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SlideInRight(
                        child: GestureDetector(
                          onTap: () async {
                            await Get.to(
                              () => const AddTaskPage(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                            );
                            _taskController.getTasks();
                          },
                          child: Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Pallete.bluishColor,
                            ),
                            child: const Center(
                              child: Text(
                                '+ Add Task',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                ZoomIn(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20.0, left: 20.0),
                    child: DatePicker(
                      DateTime.now(),
                      height: 100,
                      width: 80,
                      initialSelectedDate: DateTime.now(),
                      selectionColor: Pallete.bluishColor,
                      selectedTextColor: Colors.white,
                      dateTextStyle: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      dayTextStyle: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      monthTextStyle: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      onDateChange: (selectedDate) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                      itemCount: _taskController.taskList.length,
                      itemBuilder: (context, index) {
                        Task task = _taskController.taskList[index];
                        if (task.repeat == 'Daily' &&
                            DateFormat('MM/dd/yyyy')
                                .parse(task.date!)
                                .isBefore(_selectedDate)) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            child: SlideAnimation(
                              child: FadeInAnimation(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showBottomSheet(
                                          context,
                                          task,
                                        );
                                      },
                                      child: TaskTile(
                                        task: task,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (task.repeat == 'Weekly' &&
                            _selectedDate.weekday ==
                                DateFormat('MM/dd/yyyy')
                                    .parse(task.date!)
                                    .weekday &&
                            DateFormat('MM/dd/yyyy')
                                .parse(task.date!)
                                .isBefore(_selectedDate)) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            child: SlideAnimation(
                              child: FadeInAnimation(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showBottomSheet(
                                          context,
                                          task,
                                        );
                                      },
                                      child: TaskTile(
                                        task: task,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (task.repeat == 'Monthly' &&
                            _selectedDate.day ==
                                DateFormat('MM/dd/yyyy')
                                    .parse(task.date!)
                                    .day &&
                            DateFormat('MM/dd/yyyy')
                                .parse(task.date!)
                                .isBefore(_selectedDate)) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            child: SlideAnimation(
                              child: FadeInAnimation(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showBottomSheet(
                                          context,
                                          task,
                                        );
                                      },
                                      child: TaskTile(
                                        task: task,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (task.date ==
                            DateFormat.yMd().format(_selectedDate)) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            child: SlideAnimation(
                              child: FadeInAnimation(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showBottomSheet(
                                          context,
                                          task,
                                        );
                                      },
                                      child: TaskTile(
                                        task: task,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 4.0),
          height: task.isCompleted == 1
              ? MediaQuery.of(context).size.height * 0.24
              : MediaQuery.of(context).size.height * 0.32,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 6,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey.shade300,
                ),
              ),
              const Spacer(),
              task.isCompleted == 1
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        _taskController.updateTask(task.id!);
                        notifyHelper.cancelNotification(task.id!);
                        Get.back();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Pallete.bluishColor,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                          color: Pallete.bluishColor,
                        ),
                        child: Text(
                          "Task Completed",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _taskController.delete(task);
                  notifyHelper.cancelNotification(task.id!);
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.greenAccent,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.red,
                  ),
                  child: Text(
                    'Delete Task',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.transparent,
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      },
    );
  }
}
