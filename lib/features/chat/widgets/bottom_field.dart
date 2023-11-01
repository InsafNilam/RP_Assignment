import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:chat_application/colors.dart';
import 'package:chat_application/common/enums/message_enum.dart';
import 'package:chat_application/common/providers/message_provider.dart';
import 'package:chat_application/common/utils/get_prediction.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/features/chat/controller/chat_controller.dart';
import 'package:chat_application/features/chat/screens/mobile_chat_screen.dart';
import 'package:chat_application/features/chat/widgets/message_preview.dart';
import 'package:chat_application/features/gesture/controllers/boxes.dart';
import 'package:chat_application/features/gesture/controllers/gesture_list.dart';
import 'package:chat_application/models/gesture.dart';
import 'package:chat_application/services/firebase_messaging.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroup;

  const BottomChatField({
    Key? key,
    required this.receiverUserId,
    required this.isGroup,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  late TextEditingController _messageController;
  late TextEditingController _gestureController;
  late NotificationServices _notifications;
  late FlutterSoundRecorder _soundRecorder;
  late FocusNode _focusNode;

  bool isShowButtonContainer = false;
  bool isShowSendButton = false;
  bool isShowEmojiContainer = false;

  bool _isRecorderInit = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _gestureController = TextEditingController();
    _notifications = NotificationServices();
    _soundRecorder = FlutterSoundRecorder();
    _focusNode = FocusNode();
    _notifications.getRecieverToken(widget.receiverUserId);
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone Permission not Allowed');
    }
    await _soundRecorder.openRecorder();
    _isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
            context,
            _messageController.text.trim(),
            widget.receiverUserId,
            widget.isGroup,
          );
      if (widget.isGroup == false) {
        await _notifications.sendNotification(
          body: _messageController.text,
          senderId: FirebaseAuth.instance.currentUser!.uid,
        );
      }
      setState(() {
        _messageController.text = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!_isRecorderInit) {
        openAudio();
        return;
      }
      if (_isRecording) {
        await _soundRecorder.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder.startRecorder(toFile: path);
      }
      setState(() {
        _isRecording = !_isRecording;
      });
    }
  }

  void sendFileMessage(File file, MessageEnum messageEnum) async {
    ref.read(chatControllerProvider).sendFileMessage(
          context,
          file,
          widget.receiverUserId,
          messageEnum,
          widget.isGroup,
        );
    if (widget.isGroup == false) {
      await _notifications.sendNotification(
        body: messageEnum.type,
        senderId: FirebaseAuth.instance.currentUser!.uid,
      );
    }
  }

  void sendGIFMessage(String gifURL) async {
    ref.read(chatControllerProvider).sendGIFMessage(
          context,
          gifURL,
          widget.receiverUserId,
          widget.isGroup,
        );
    if (widget.isGroup == false) {
      await _notifications.sendNotification(
        body: "GIF",
        senderId: FirebaseAuth.instance.currentUser!.uid,
      );
    }
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectCameraImage() async {
    File? image = await pickImageFromCamera(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void selectGIF() async {
    final gif = await pickGIF(
      context,
    );
    if (gif != null) {
      sendGIFMessage(gif.url);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _gestureController.dispose();
    _soundRecorder.closeRecorder();
    _focusNode.dispose();
    _isRecorderInit = false;
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void hideKeyboard() {
    _focusNode.unfocus();
  }

  void showKeyboard() {
    _focusNode.requestFocus();
  }

  void toggleButton() {
    setState(() {
      isShowButtonContainer = !isShowButtonContainer;
    });
  }

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      hideEmojiContainer();
      showKeyboard();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    bool isShowMessageReply = messageReply != null;

    if (ref.watch(detectionRunning)) {
      final message = ref.watch(detectedWords);
      if (message.isNotEmpty) {
        String value;
        Gesture? gesture = Boxes.getGesture(message);
        if (gesture != null && gesture.objectUse) {
          value = '${gesture.objectValue} ';
        } else {
          // Use the message property
          value =
              '${gestures.where((gesture) => gesture.objectKey == message).first.objectValue} ';
        }
        _gestureController.text = _gestureController.text + value;
      }
    }

    if (ref.watch(gestureContainer)) {
      if (_focusNode.hasFocus ||
          isShowButtonContainer ||
          isShowMessageReply ||
          isShowEmojiContainer) {
        isShowMessageReply = false;
        _focusNode.unfocus();
        setState(() {
          isShowButtonContainer = false;
          isShowEmojiContainer = false;
        });
      }
    }

    return Column(
      children: [
        isShowMessageReply ? const MessagePreview() : const SizedBox.shrink(),
        isShowButtonContainer ? buildBottomButton() : const SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ref.watch(gestureContainer)
              ? BounceInUp(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10).copyWith(
                        bottomLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 200,
                      maxHeight: 400,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Result: ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _gestureController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.black87),
                            maxLines: 8,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: 'Hand Gesture Result goes here...',
                              hintStyle: const TextStyle(color: Colors.black54),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.0).copyWith(
                                  bottomLeft: const Radius.circular(30.0),
                                  topRight: const Radius.circular(30.0),
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.purple,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.0).copyWith(
                                  bottomLeft: const Radius.circular(30.0),
                                  topRight: const Radius.circular(30.0),
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(top: 8.0),
                                decoration: BoxDecoration(
                                  color: ref.watch(detectionRunning)
                                      ? Colors.grey.shade400
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    if (!ref.read(detectionRunning)) {
                                      if (_gestureController.text != '') {
                                        _gestureController.text = "";
                                      }
                                      ref
                                          .read(gestureContainer.notifier)
                                          .update((state) => false);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(top: 8.0),
                                decoration: BoxDecoration(
                                  color: ref.watch(detectionRunning)
                                      ? Colors.grey.shade400
                                      : tabColor,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    if (!ref.read(detectionRunning)) {
                                      if (_gestureController.text != "") {
                                        _messageController.text =
                                            _messageController.text +
                                                _gestureController.text;
                                        _gestureController.text = "";
                                        setState(() {
                                          isShowSendButton = true;
                                        });
                                      }
                                      ref
                                          .read(gestureContainer.notifier)
                                          .update((state) => false);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.done_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        focusNode: _focusNode,
                        controller: _messageController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() => isShowSendButton = true);
                          } else {
                            setState(() => isShowSendButton = false);
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: mobileChatBoxColor,
                          prefixIcon: IconButton(
                            onPressed: toggleEmojiKeyboardContainer,
                            icon: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: toggleButton,
                            icon: const Icon(
                              Icons.attach_file,
                              color: Colors.grey,
                            ),
                          ),
                          hintText: 'Type a message!',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: CircleAvatar(
                        backgroundColor: const Color(0XFF128C7E),
                        radius: 25,
                        child: GestureDetector(
                          onTap: sendTextMessage,
                          child: Icon(
                            isShowSendButton
                                ? Icons.send
                                : _isRecording
                                    ? Icons.close
                                    : Icons.mic,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        isShowEmojiContainer
            ? SizedBox(
                height: 300,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _messageController.text =
                          _messageController.text + emoji.emoji;
                    });
                    if (!isShowSendButton) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    }
                  },
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }

  Widget buildBottomButton() {
    return BounceInUp(
      child: Container(
        margin: const EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0),
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0XFF128C7E),
            borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: toggleButton,
                      child: const Icon(
                        Icons.close,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      radius: 25,
                      child: GestureDetector(
                        onTap: selectVideo,
                        child: const Icon(
                          Icons.video_collection_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3.0,
                    ),
                    const Text(
                      "Video",
                      style: TextStyle(color: Colors.amber),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.greenAccent,
                      radius: 25,
                      child: GestureDetector(
                        onTap: selectImage,
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3.0,
                    ),
                    const Text(
                      "Photo",
                      style: TextStyle(color: Colors.amber),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orangeAccent,
                      radius: 25,
                      child: GestureDetector(
                        onTap: selectGIF,
                        child: const Icon(
                          Icons.gif_box_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3.0,
                    ),
                    const Text(
                      "GIF",
                      style: TextStyle(color: Colors.amber),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 25,
                      child: GestureDetector(
                        onTap: selectCameraImage,
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3.0,
                    ),
                    const Text(
                      "Camera",
                      style: TextStyle(color: Colors.amber),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
