import 'dart:async';
import 'dart:typed_data';
import 'package:animate_do/animate_do.dart';
import 'package:buttons_panel/buttons_panel.dart';
import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/features/gesture/controllers/drive_list.dart';
import 'package:chat_application/models/gesture.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

class GestureDriving extends ConsumerStatefulWidget {
  const GestureDriving({super.key});

  @override
  ConsumerState<GestureDriving> createState() => _GestureDrivingState();
}

class _GestureDrivingState extends ConsumerState<GestureDriving> {
  bool isInitComplete = false;
  late FlutterVision vision;
  late Future<LottieComposition> composition;
  late FlutterTts flutterTts;
  late List<String> speechDataKeys;
  late List<String> cameraDataKeys;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init().then((_) {
      setState(() {
        isInitComplete = true;
      });
    });
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
      () async =>
          await systemSpeak("Good day and welcome to Recognition Interface!"),
    );
    setState(() {});
  }

  @override
  void dispose() async {
    super.dispose();
    flutterTts.stop();
    await vision.closeYoloModel();
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  Future<void> init() async {
    vision = FlutterVision();
    flutterTts = FlutterTts();
    composition = AssetLottie('assets/radar.json').load();
    await loadYoloModel().then((_) {
      speechDataListen();
      cameraDataListen();
      initTextToSpeech();
    });
  }

  Future<void> speechDataListen() async {
    speechDataKeys =
        await ref.read(authControllerProvider).getSpeechDataKeyList();
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('speech_data');
    databaseReference.onChildAdded.listen((event) async {
      final DataSnapshot data = event.snapshot;
      if (speechDataKeys.contains(data.key)) {
        return;
      } else {
        try {
          flutterTts.stop();
          await systemSpeak(data.value.toString());
        } catch (error) {
          Future(
            () => {
              showSnackbar(
                context: context,
                content: "Error: $error",
                type: SnackBarEnum.error,
              )
            },
          );
        } finally {
          speechDataKeys.add(data.key!);
        }
      }
    });

    databaseReference.onChildRemoved.listen((event) async {
      final DataSnapshot data = event.snapshot;
      if (speechDataKeys.contains(data.key)) {
        speechDataKeys.remove(data.key);
      }
    });
  }

  Future<void> cameraDataListen() async {
    cameraDataKeys =
        await ref.read(authControllerProvider).getCameraDataKeyList();
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('esp32-cam');
    databaseReference.onChildAdded.listen((event) async {
      final DataSnapshot data = event.snapshot;
      Map<dynamic, dynamic> value = data.value as Map<dynamic, dynamic>;
      if (cameraDataKeys.contains(data.key)) {
        return;
      } else {
        try {
          if (value["photo"] != null) {
            final UriData? image = Uri.parse(value["photo"]).data;
            // Will returns your image as Uint8List
            Uint8List data = image!.contentAsBytes();
            await yoloOnImage(data);
          }
        } catch (error) {
          Future(
            () => {
              showSnackbar(
                context: context,
                content: "Error: $error",
                type: SnackBarEnum.error,
              )
            },
          );
        } finally {
          cameraDataKeys.add(data.key!);
        }
      }
    });

    databaseReference.onChildRemoved.listen((event) async {
      final DataSnapshot data = event.snapshot;
      if (cameraDataKeys.contains(data.key)) {
        cameraDataKeys.remove(data.key);
      }
    });
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
      labels: 'assets/models/labels.txt',
      modelPath: 'assets/models/model.tflite',
      modelVersion: "yolov8",
      numThreads: 2,
      useGpu: true,
    );
  }

  yoloOnImage(Uint8List byte) async {
    final image = await decodeImageFromList(byte);
    final result = await vision.yoloOnImage(
      bytesList: byte,
      imageHeight: image.height,
      imageWidth: image.width,
      iouThreshold: 0.3,
      confThreshold: 0.3,
      classThreshold: 0.3,
    );
    if (result.isNotEmpty) {
      final String content = drive
          .where((gesture) => gesture.objectKey == result[0]['tag'])
          .first
          .objectValue;
      // Future(() => {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(
      //           content: Text('Result: ${result[0]['tag']}'),
      //         ),
      //       )
      //     });
      flutterTts.stop();
      await systemSpeak(content);
    } else {
      flutterTts.stop();
      await systemSpeak('Result: None');
      // Future(() => {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //           content: Text('Result: None'),
      //         ),
      //       )
      //     });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1321),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add, color: Colors.white),
        //     onPressed: () {
        //       final DatabaseReference ref =
        //           FirebaseDatabase.instance.ref('speech_data');
        //       ref.push().set("Hello How are you");
        //     },
        //   ),
        // ],
        titleSpacing: 0,
        title: BounceInDown(child: const Text('Recognition')),
        backgroundColor: const Color(0xFF124559),
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
          : FutureBuilder<LottieComposition>(
              future: composition,
              builder: (context, snapshot) {
                var composition = snapshot.data;
                if (composition != null) {
                  return BounceInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent, // Shadow color
                                  offset: Offset(0, 0), // Offset
                                  blurRadius: 10.0, // Spread radius
                                  spreadRadius: 2.0, // Blur radius
                                ),
                              ],
                              shape: BoxShape.circle,
                              color: Color(0xFFEEE5E9),
                            ),
                            child: Lottie(
                              composition: composition,
                              height: 200,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ButtonsPanel(
                          currentIndex: currentIndex,
                          borderRadius: BorderRadius.circular(32),
                          backgroundColor: const Color(0xFFEEE5E9),
                          selectedItemBackgroundColor:
                              Theme.of(context).primaryColor,
                          selectedIconThemeData: const IconThemeData(
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          onTap: (value) =>
                              setState(() => currentIndex = value),
                          children: const [
                            Icon(Icons.camera),
                            Icon(Icons.record_voice_over_rounded),
                            Icon(Icons.storage_rounded),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 18.0,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: currentIndex == 0
                                ? _getCameraDataList()
                                : currentIndex == 1
                                    ? _getSpeechDataList()
                                    : _getDriveDefined(),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Loader();
                }
              },
            ),
    );
  }

  StreamBuilder<List<Uint8List>> _getCameraDataList() {
    return StreamBuilder<List<Uint8List>>(
      stream: ref.watch(authControllerProvider).getCameraDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasData) {
          List<Uint8List> data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final Uint8List image = data[index];
              return AnimationConfiguration.staggeredList(
                  delay: const Duration(milliseconds: 100),
                  position: index,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: ListTile(
                              dense: true,
                              title: const Text(
                                'Image Data',
                              ),
                              enabled:
                                  true, // Depending on whether a gesture should be used or not, the widgets will fade or be normal.
                              subtitle: const Text(
                                'Value -> ',
                              ),
                              leading: CircleAvatar(
                                backgroundImage: MemoryImage(
                                  image,
                                ),
                                radius: 23,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 24,
                                ),
                                color: Colors.green,
                                onPressed: () async {
                                  await yoloOnImage(image);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8)
                        ],
                      ),
                    ),
                  ));
            },
          );
        } else {
          return const Center(
            child: Text(
              "Error",
              style: TextStyle(color: Colors.red, fontSize: 24),
            ),
          );
        }
      },
    );
  }

  StreamBuilder<List<String>> _getSpeechDataList() {
    return StreamBuilder<List<String>>(
      stream: ref.watch(authControllerProvider).getSpeechDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasData) {
          List<String> data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final String speech = data[index];
              return AnimationConfiguration.staggeredList(
                delay: const Duration(milliseconds: 100),
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                      child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ListTile(
                          dense: true,
                          title: const Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Speech Data',
                            ),
                          ),
                          enabled:
                              true, // Depending on whether a gesture should be used or not, the widgets will fade or be normal.
                          subtitle: Text(
                            speech,
                          ),
                          leading: const Icon(
                            Icons.voice_chat,
                            size: 24,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.play_circle_outline_rounded,
                              size: 24,
                            ),
                            color: Colors.green,
                            onPressed: () async {
                              flutterTts.stop();
                              await systemSpeak(speech);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8)
                    ],
                  )),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text(
              "Error",
              style: TextStyle(color: Colors.red, fontSize: 24),
            ),
          );
        }
      },
    );
  }

  Widget _getDriveDefined() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ListView.builder(
        itemCount: drive.length,
        padding: const EdgeInsets.only(top: 4),
        itemBuilder: (BuildContext context, int index) {
          Gesture gesture = drive[index];
          return AnimationConfiguration.staggeredList(
            delay: const Duration(milliseconds: 200),
            position: index,
            child: SlideAnimation(
              child: FadeInAnimation(
                child: Column(
                  children: [
                    Container(
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
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.play_circle_outline_rounded,
                            size: 24,
                          ),
                          color: Colors.green,
                          onPressed: () async {
                            flutterTts.stop();
                            await systemSpeak(gesture.objectValue);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
