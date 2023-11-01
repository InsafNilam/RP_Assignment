import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import 'package:chat_application/colors.dart';
import 'package:chat_application/common/utils/get_prediction.dart';
import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/features/calls/controller/call_controller.dart';
import 'package:chat_application/features/chat/widgets/bottom_field.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:chat_application/features/chat/widgets/chat_list.dart';
import 'package:floating_overlay/floating_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final gestureContainer = StateProvider<bool>((ref) => false);

class MobileChatScreen extends ConsumerStatefulWidget {
  static const String routeName = 'mobile-chat-screen';
  final String name;
  final String uid;
  final String profilePic;
  final bool isGroup;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.isGroup,
  }) : super(key: key);

  @override
  ConsumerState<MobileChatScreen> createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends ConsumerState<MobileChatScreen> {
  late CameraController cameraController;
  late FlutterVision vision;
  late List<CameraDescription> cameras;
  late FloatingOverlayController controller;

  @override
  void initState() {
    super.initState();
    controller = FloatingOverlayController.absoluteSize(
      maxSize: const Size(300, 300),
      minSize: const Size(200, 200),
      start: const Offset(30, 80),
      padding: const EdgeInsets.all(10.0),
      constrained: true,
    );
  }

  Future<void> init() async {
    vision = FlutterVision();
    cameras = await availableCameras();
    cameraController = CameraController(cameras.first, ResolutionPreset.low);
    await cameraController.initialize().then((value) {
      loadYoloModel().then((value) {
        ref.read(detectionRunning.notifier).update((state) => false);
      });
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

  @override
  void dispose() {
    super.dispose();
    controller.close();
    vision.closeYoloModel();
    vision.closeTesseractModel();
    cameraController.dispose();
  }

  void makeCall(BuildContext context, WidgetRef ref) {
    ref.read(callControllerProvider).makeCall(
          context,
          widget.uid,
          widget.name,
          widget.profilePic,
          widget.isGroup,
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: appBarColor,
              title: widget.isGroup
                  ? Text(widget.name)
                  : StreamBuilder<UserModel>(
                      stream:
                          ref.read(authControllerProvider).userData(widget.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Loader();
                        } else if (snapshot.hasData) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ZoomIn(
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(snapshot.data!.profilePic),
                                  radius: 18,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              BounceInDown(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.name),
                                    Text(
                                      snapshot.data!.isOnline
                                          ? 'online'
                                          : 'offline',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
              centerTitle: false,
              titleSpacing: 0,
              leading: SlideInLeft(
                delay: const Duration(seconds: 5),
                child: IconButton(
                  onPressed: () {
                    ref
                        .read(gestureContainer.notifier)
                        .update((state) => false);
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                ),
              ),
              actions: [
                BounceInDown(
                  delay: const Duration(seconds: 5),
                  child: IconButton(
                    onPressed: () {
                      if (controller.isFloating &&
                          !ref.read(detectionRunning)) {
                        controller.hide();
                      } else if (!ref.read(detectionRunning)) {
                        ref
                            .read(gestureContainer.notifier)
                            .update((state) => true);
                        controller.show();
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                    ),
                  ),
                ),
                // BounceInDown(
                //   delay: const Duration(seconds: 5),
                //   child: PopupMenuButton(
                //     icon: const Icon(
                //       Icons.more_vert,
                //     ),
                //     itemBuilder: (context) => [
                //       PopupMenuItem(
                //           child: const Row(
                //             children: [
                //               Icon(
                //                 Icons.call,
                //                 size: 20,
                //                 color: Colors.black,
                //               ),
                //               SizedBox(
                //                 width: 10,
                //               ),
                //               Text('Audio Call'),
                //             ],
                //           ),
                //           onTap: () => {}),
                //       PopupMenuItem(
                //         child: const Row(
                //           children: [
                //             Icon(
                //               Icons.video_call,
                //               size: 20,
                //               color: Colors.black,
                //             ),
                //             SizedBox(
                //               width: 10,
                //             ),
                //             Text('Video Call'),
                //           ],
                //         ),
                //         onTap: () => makeCall(context, ref),
                //       ),
                //       PopupMenuItem(
                //         child: const Row(
                //           children: [
                //             Icon(
                //               Icons.delete_forever,
                //               size: 20,
                //               color: Colors.black,
                //             ),
                //             SizedBox(
                //               width: 10,
                //             ),
                //             Text('Delete Chat'),
                //           ],
                //         ),
                //         onTap: () {},
                //       ),
                //     ],
                //   ),
                // ),
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.more_vert),
                // ),
              ],
            ),
            body: FloatingOverlay(
              controller: controller,
              floatingChild: ZoomIn(
                child: SizedBox.square(
                  dimension: 300.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: YoloVideo(
                      vision: vision,
                      cameras: cameras,
                      controller: cameraController,
                    ),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ChatList(
                      receiverUserId: widget.uid,
                      isGroup: widget.isGroup,
                    ),
                  ),
                  BounceInUp(
                    delay: const Duration(seconds: 5),
                    child: BottomChatField(
                      receiverUserId: widget.uid,
                      isGroup: widget.isGroup,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: appBarColor,
            body: Padding(
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
            ),
          );
        }
      },
    );
  }
}
