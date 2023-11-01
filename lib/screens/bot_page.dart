import 'package:animate_do/animate_do.dart';
import 'package:chat_application/common/widgets/feature_box.dart';
import 'package:chat_application/features/open_ai/openai_service.dart';
import 'package:chat_application/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final speechToText = SpeechToText();
  final OpenAIService openAIService = OpenAIService();
  FlutterTts flutterTts = FlutterTts();
  String speech = "";
  String? generatedContent;
  String? generatedImageURL;
  double? _progress;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      speech = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
        backgroundColor: Colors.white,
        title: BounceInDown(
          child: const Text(
            'Assistant',
            style: TextStyle(color: Colors.black),
          ),
        ),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        margin: const EdgeInsets.only(
                          top: 4.0,
                        ),
                        decoration: const BoxDecoration(
                          color: Pallete.assistantCircleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      height: 123,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/assistant.png',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeInRight(
              child: Visibility(
                visible: generatedImageURL == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40.0).copyWith(
                    top: 30.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0).copyWith(
                      topLeft: Radius.zero,
                    ),
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null
                          ? 'Good Morning, What can i do for you?'
                          : generatedContent!,
                      style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 24 : 18,
                        fontFamily: 'CeraPro',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageURL != null)
              Padding(
                padding: const EdgeInsets.all(10.0).copyWith(top: 10),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: ZoomIn(
                        child: Image.network(generatedImageURL!),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: IconButton(
                              onPressed: () {
                                FileDownloader.downloadFile(
                                    url: generatedImageURL!.trim(),
                                    onProgress:
                                        (String? fileName, double progress) {
                                      setState(() {
                                        _progress = progress;
                                      });
                                    },
                                    onDownloadCompleted: (String path) {
                                      setState(() {
                                        _progress = null;
                                      });
                                      const snackBar = SnackBar(
                                        content: Text(
                                            'Image Downloaded was Successfull'),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        snackBar,
                                      );
                                    },
                                    onDownloadError: (String error) {
                                      const snackBar = SnackBar(
                                        content: Text('Something Went Wrong'),
                                      );

                                      // Displays a message toList() the user when a new task is added successfully.
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        snackBar,
                                      );
                                    });
                              },
                              icon: _progress != null
                                  ? const Icon(Icons.downloading)
                                  : const Icon(Icons.download)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageURL == null,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.only(top: 10.0, left: 22.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedImageURL == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      mainText: 'ChatGPT',
                      subText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: const Duration(milliseconds: 400),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      mainText: 'Dall-E',
                      subText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: const Duration(milliseconds: 600),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      mainText: 'Smart Voice Assistant',
                      subText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: const Duration(milliseconds: 800),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final content = await openAIService.isArtPromptAPI(speech);
              if (content.contains('https')) {
                generatedImageURL = content;
                generatedContent = null;
                setState(() {});
              } else {
                generatedContent = content;
                generatedImageURL = null;
                setState(() {});
                await systemSpeak(content);
              }
              await stopListening();
            } else {
              await initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
