import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/chat/controller/chat_controller.dart';
import 'package:chat_application/features/chat/screens/mobile_chat_screen.dart';
import 'package:chat_application/models/chat_group.dart';
import 'package:chat_application/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatGroup extends ConsumerWidget {
  const ChatGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(overallSearch);
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: StreamBuilder<List<GroupModel>>(
          stream: ref.watch(chatControllerProvider).chatGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: MediaQuery.of(context).size.height - 180,
                width: MediaQuery.of(context).size.width,
                child: const Loader(),
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var groupData = snapshot.data![index];
                  if (search.isEmpty) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    MobileChatScreen.routeName,
                                    arguments: {
                                      'name': groupData.name,
                                      'uid': groupData.groupId,
                                      'profilePic': groupData.groupPic,
                                      'isGroup': true,
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: ListTile(
                                    title: Text(
                                      groupData.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(
                                        groupData.lastMessage,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        groupData.groupPic,
                                      ),
                                      radius: 30,
                                    ),
                                    trailing: Text(
                                      DateFormat.Hm()
                                          .format(groupData.timeSent),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (groupData.name
                      .toLowerCase()
                      .contains(search.toLowerCase())) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    MobileChatScreen.routeName,
                                    arguments: {
                                      'name': groupData.name,
                                      'uid': groupData.groupId,
                                      'profilePic': groupData.groupPic,
                                      'isGroup': true,
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: ListTile(
                                    title: Text(
                                      groupData.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(
                                        groupData.lastMessage,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        groupData.groupPic,
                                      ),
                                      radius: 30,
                                    ),
                                    trailing: Text(
                                      DateFormat.Hm()
                                          .format(groupData.timeSent),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
