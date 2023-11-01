import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/config/agora_config.dart';
import 'package:chat_application/features/calls/controller/call_controller.dart';
import 'package:chat_application/models/chat_call.dart';
import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final CallModel call;
  final bool isGroup;
  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroup,
  }) : super(key: key);

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  AgoraClient? client;
  String baseURL = 'https://chatcallserver-production.up.railway.app';

  @override
  void initState() {
    super.initState();
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraConfig.appId,
        channelName: widget.channelId,
        tokenUrl: baseURL,
      ),
    );
    initAgora();
  }

  void initAgora() async {
    await client!.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    client!.engine.leaveChannel();
    client!.engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: client == null
          ? const Loader()
          : SafeArea(
              child: Stack(
                children: [
                  AgoraVideoViewer(
                    client: client!,
                    layoutType: Layout.floating,
                    enableHostControls:
                        true, // Add this to enable host controls
                  ),
                  AgoraVideoButtons(
                    client: client!,
                    addScreenSharing:
                        false, // Add this to enable screen sharing
                    disconnectButtonChild: IconButton(
                        onPressed: () async {
                          await client!.engine.leaveChannel();
                          await client!.engine.release();
                          Future(() {
                            ref.read(callControllerProvider).endCall(
                                  context,
                                  widget.call.callerId,
                                  widget.call.receiverId,
                                );
                            Get.back();
                          });
                        },
                        icon: const Icon(Icons.call_end)),
                  ),
                ],
              ),
            ),
    );
  }
}
