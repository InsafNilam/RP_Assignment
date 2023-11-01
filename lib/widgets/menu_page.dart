import 'package:animate_do/animate_do.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/models/menu_page.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class MenuItems {
  static const dashboard = MenuItem('Dashboard', Icons.table_chart_outlined);
  static const chat = MenuItem('Chat', Icons.chat_outlined);
  static const news = MenuItem('News', Icons.newspaper_rounded);
  static const remainder = MenuItem('Remainder', Icons.alarm_rounded);
  static const bot = MenuItem('Assistant', Icons.smart_toy_outlined);
  static const recognition = MenuItem('Recognition', Icons.assist_walker);

  static const all = <MenuItem>[
    dashboard,
    chat,
    news,
    remainder,
    bot,
    recognition,
  ];
}

class MenuPage extends ConsumerStatefulWidget {
  final MenuItem currentItem;
  final ValueChanged<MenuItem> onSelectedItem;
  // Create an instance of FirebaseAuth
  const MenuPage({
    Key? key,
    required this.currentItem,
    required this.onSelectedItem,
  }) : super(key: key);

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  late UserModel? user;
  bool isInitComplete = false;

  @override
  void initState() {
    super.initState();
    init().then(
      (value) => setState(
        () {
          user = value;
          isInitComplete = true;
        },
      ),
    );
  }

  Future<UserModel?> init() async {
    return await ref.read(authControllerProvider).getUserData();
  }

  void handleLogout(BuildContext context) {
    QuickAlert.show(
        context: context,
        title: 'Do you want to Sign Out?',
        type: QuickAlertType.confirm,
        barrierDismissible: true,
        cancelBtnText: 'No',
        confirmBtnText: 'Yes',
        onConfirmBtnTap: () {
          signOut(context);
        });
  }

  void signOut(BuildContext context) {
    ref.read(authControllerProvider).signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Colors.indigo,
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
            : SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    ZoomIn(
                      child: CircleAvatar(
                        backgroundColor: Colors.brown.shade800,
                        radius: 70,
                        foregroundImage: NetworkImage(
                          user?.profilePic ??
                              'https://i.ibb.co/dWmBfNJ/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 40,
                      // child: _user == null
                      //     ? const Text('Guest')
                      //     : Text(_user?.email ?? 'Guest'),
                      child: Column(
                        children: [
                          Text(user!.name),
                          const SizedBox(height: 4),
                          Text(user!.phoneNumber),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ...MenuItems.all.map(buildMenuItem).toList(),
                    const Spacer(flex: 2),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        fixedSize: const Size(120, 40),
                        foregroundColor: Colors.white,
                        // backgroundColor: _user == null ? Colors.green : Colors.red),
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.logout),
                      onPressed: () => handleLogout(context),
                      // label: _user == null ? const Text('Login') : const Text('Logout'),
                      label: const Text('Logout'),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildMenuItem(MenuItem item) => ListTileTheme(
        selectedColor: Colors.white,
        child: ListTile(
          selectedTileColor: Colors.black26,
          selected: widget.currentItem == item,
          minLeadingWidth: 20,
          leading: Icon(item.icon),
          title: Text(item.title),
          onTap: () {
            widget.onSelectedItem(item);
          },
        ),
      );
}
