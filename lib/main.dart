// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_application/colors.dart';
import 'package:chat_application/common/widgets/error.dart';
import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/features/landing/screens/landing_screen.dart';
import 'package:chat_application/features/remainder/helper/db_helper.dart';
import 'package:chat_application/firebase_options.dart';
import 'package:chat_application/models/gesture.dart';
import 'package:chat_application/router.dart';
import 'package:chat_application/widgets/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// import 'services/firebase_messaging.dart';

Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage remoteMessage,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();
  // Registers an adapter for the Gesture model class.
  Hive.registerAdapter(GestureAdapter());
  // Opens a Hive box named "gesture_box" for storing instances of the Gesture class.
  await Hive.openBox<Gesture>('gesture_box');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat',
        theme: ThemeData.light(useMaterial3: false).copyWith(
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: const AppBarTheme(
            color: appBarColor,
          ),
        ),
        onGenerateRoute: ((settings) => generateRoute(settings)),
        home: ref.watch(userDataAuthProvider).when(data: (user) {
          if (user == null) {
            return const LandingPage();
          }
          return const MainPage();
        }, error: (err, trace) {
          return ErrorScreen(error: err.toString());
        }, loading: () {
          return const Loader();
        }));
  }
}
