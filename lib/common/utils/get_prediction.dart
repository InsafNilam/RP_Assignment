import 'package:camera/camera.dart';
import 'package:chat_application/features/chat/screens/mobile_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vision/flutter_vision.dart';

final detectedWords = StateProvider<String>((ref) => '');
final detectionRunning = StateProvider<bool>((ref) => false);

class YoloVideo extends ConsumerStatefulWidget {
  final FlutterVision vision;
  final List<CameraDescription> cameras;
  final CameraController controller;
  const YoloVideo({
    Key? key,
    required this.vision,
    required this.cameras,
    required this.controller,
  }) : super(key: key);

  @override
  ConsumerState<YoloVideo> createState() => _YoloVideoState();
}

class _YoloVideoState extends ConsumerState<YoloVideo> {
  CameraImage? cameraImage;
  bool isDetecting = false;
  int selectedCamera = 0;

  switchCamera() async {
    int direction = selectedCamera == 0 ? 1 : 0;
    widget.controller.setDescription(widget.cameras[direction]);
    setState(() {
      selectedCamera = direction;
      isDetecting = false;
    });
    ref.read(detectionRunning.notifier).update((state) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: CameraPreview(
                widget.controller,
              ),
            ),
            Positioned(
              top: 115,
              left: 85,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1,
                        color: Colors.white,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        switchCamera();
                      },
                      icon: const Icon(
                        Icons.cameraswitch_outlined,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1,
                        color: Colors.white,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: isDetecting
                        ? IconButton(
                            onPressed: () async {
                              stopDetection();
                            },
                            icon: const Icon(
                              Icons.stop,
                              color: Colors.red,
                            ),
                            iconSize: 40,
                          )
                        : IconButton(
                            onPressed: () async {
                              ref
                                  .read(detectionRunning.notifier)
                                  .update((state) => true);
                              if (!ref.watch(gestureContainer)) {
                                ref
                                    .read(gestureContainer.notifier)
                                    .update((state) => true);
                              }
                              await startDetection();
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            iconSize: 40,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadYoloModel() async {
    await widget.vision.loadYoloModel(
      labels: 'assets/models/labels.txt',
      modelPath: 'assets/models/model.tflite',
      modelVersion: "yolov8",
      numThreads: 1,
      useGpu: true,
    );
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await widget.vision.yoloOnFrame(
      bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
      imageHeight: cameraImage.height,
      imageWidth: cameraImage.width,
      iouThreshold: 0.3,
      confThreshold: 0.3,
      classThreshold: 0.3,
    );

    if (result.isNotEmpty) {
      if (ref.read(detectedWords) != result[0]['tag']) {
        ref.read(detectedWords.notifier).update((_) => result[0]['tag']);
      } else if (ref.read(detectedWords) == '') {
        ref.read(detectedWords.notifier).update((_) => result[0]['tag']);
      }
    }
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    if (widget.controller.value.isStreamingImages) {
      return;
    }
    await widget.controller.startImageStream((image) async {
      if (isDetecting) {
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
  }

  Future<void> stopDetection() async {
    widget.controller.stopImageStream();
    setState(() {
      isDetecting = false;
    });
    ref.read(detectionRunning.notifier).update((state) => false);
    ref.read(detectedWords.notifier).update((state) => '');
  }
}
