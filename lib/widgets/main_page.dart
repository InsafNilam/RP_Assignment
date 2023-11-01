import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/models/menu_page.dart';
import 'package:chat_application/screens/bot_page.dart';
import 'package:chat_application/screens/chat_page.dart';
import 'package:chat_application/screens/dashboard_page.dart';
import 'package:chat_application/screens/gesture_recognition.dart';
import 'package:chat_application/screens/news_page.dart';
import 'package:chat_application/screens/remainder_page.dart';
import 'package:chat_application/widgets/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late MenuItem currentItem;

  @override
  void initState() {
    super.initState();
    currentItem = MenuItems.dashboard;
    ref.read(authControllerProvider).setUserState(true);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      showShadow: true,
      menuBackgroundColor: Colors.indigo,
      drawerShadowsBackgroundColor: Colors.orangeAccent,
      moveMenuScreen: false,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.bounceIn,
      mainScreen: getScreen(),
      menuScreen: Builder(
        builder: (context) => MenuPage(
          currentItem: currentItem,
          onSelectedItem: (MenuItem value) {
            setState(
              () {
                currentItem = value;
                ZoomDrawer.of(context)!.close();
              },
            );
          },
        ),
      ),
    );
  }

  Widget getScreen() {
    switch (currentItem) {
      case MenuItems.dashboard:
        return const DashboardPage();
      case MenuItems.chat:
        return const ChatPage();
      case MenuItems.news:
        return const NewsPage();
      case MenuItems.remainder:
        return const RemainderPage();
      case MenuItems.bot:
        return const ChatBotPage();
      case MenuItems.recognition:
        return const GestureDriving();
      default:
        return const DashboardPage();
    }
  }
}
