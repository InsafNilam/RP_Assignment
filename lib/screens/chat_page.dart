import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:chat_application/colors.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/features/gesture/screens/gesture_database.dart';
import 'package:chat_application/features/gesture/widgets/add_dailog.dart';
import 'package:chat_application/features/groups/screens/create_group.dart';
import 'package:chat_application/features/groups/widgets/chat_group.dart';
import 'package:chat_application/features/select_contacts/screens/contact_screen.dart';
import 'package:chat_application/features/chat/widgets/chat_contact_list.dart';
import 'package:chat_application/features/status/screens/confirm_screen.dart';
import 'package:chat_application/features/status/screens/contact_screen.dart';
import 'package:chat_application/services/firebase_messaging.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

final overallSearch = StateProvider<String>((ref) => '');

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<ChatPage> {
  late NotificationServices notificationService;
  late PageController pageController;
  int selectedIndex = 0;
  String search = "";
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

  init() async {
    notificationService = NotificationServices();
    pageController = PageController(initialPage: selectedIndex);
    notificationService.firebaseNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: appBarColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.amber,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: EasySearchBar(
          title: BounceInDown(
            child: Text(
              'Connect ➛ ${selectedIndex == 0 ? 'Chat' : selectedIndex == 1 ? 'Group' : selectedIndex == 2 ? 'Status' : 'DB'}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: tabColor,
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () => ZoomDrawer.of(context)!.toggle(),
          ),
          actions: [
            BounceInDown(
              delay: const Duration(seconds: 1),
              child: IconButton(
                icon: const Icon(Icons.photo_camera, color: Colors.white),
                onPressed: () async {
                  File? pickedImage = await pickImageFromCamera(context);
                  if (pickedImage != null) {
                    Get.toNamed(
                      ConfirmScreen.routeName,
                      arguments: pickedImage,
                    );
                  }
                },
              ),
            ),
          ],
          searchCursorColor: Colors.grey.shade400,
          searchBackIconTheme: const IconThemeData(color: Colors.white),
          searchClearIconTheme: const IconThemeData(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
          searchHintStyle: TextStyle(color: Colors.grey.shade400),
          searchHintText: 'Search',
          openOverlayOnSearch: false,
          searchBackgroundColor: appBarColor,
          searchTextStyle: const TextStyle(color: Colors.white),
          onSearch: (String value) {
            ref.read(overallSearch.notifier).update((state) => value);
            setState(() {
              search = value;
            });
          },
          suggestionBackgroundColor: Colors.white,
          searchTextKeyboardType: TextInputType.text,
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
            : PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                children: const <Widget>[
                  ChatContactList(),
                  ChatGroup(),
                  StatusContactScreen(),
                  GestureDatabase(),
                ],
              ),
        bottomNavigationBar: WaterDropNavBar(
          waterDropColor: tabColor,
          backgroundColor: appBarColor,
          bottomPadding: 10,
          inactiveIconColor: Colors.white,
          onItemSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
            pageController.animateToPage(
              selectedIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
            );
          },
          selectedIndex: selectedIndex,
          barItems: [
            BarItem(
              filledIcon: Icons.chat_rounded,
              outlinedIcon: Icons.chat_outlined,
            ),
            BarItem(
              filledIcon: Icons.people_alt_rounded,
              outlinedIcon: Icons.people_alt_outlined,
            ),
            BarItem(
              filledIcon: Icons.photo_album,
              outlinedIcon: Icons.photo_album_outlined,
            ),
            BarItem(
              filledIcon: Icons.sd_storage_rounded,
              outlinedIcon: Icons.sd_storage_outlined,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (selectedIndex == 0) {
              Get.toNamed(
                ContactScreen.routeName,
              );
            } else if (selectedIndex == 1) {
              Get.toNamed(
                CreateGroupScreen.routeName,
              );
            } else if (selectedIndex == 2) {
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
                Get.toNamed(
                  ConfirmScreen.routeName,
                  arguments: pickedImage,
                );
              }
            } else {
              AddDialogWidget.show(context);
            }
          },
          backgroundColor: tabColor,
          child: Icon(
            selectedIndex == 0
                ? Icons.add_card_rounded
                : selectedIndex == 1
                    ? Icons.group_add_outlined
                    : selectedIndex == 2
                        ? Icons.add_a_photo_outlined
                        : Icons.new_label_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
