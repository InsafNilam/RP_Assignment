import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/chat/controller/chat_controller.dart';
import 'package:chat_application/features/chat/screens/mobile_chat_screen.dart';
import 'package:chat_application/models/chat_contact.dart';
import 'package:chat_application/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatContactList extends ConsumerWidget {
  const ChatContactList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(overallSearch);
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: StreamBuilder<List<ChatContact>>(
            stream: ref.watch(chatControllerProvider).chatContacts(),
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
                      var chatContactData = snapshot.data![index];
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
                                          'name': chatContactData.name,
                                          'uid': chatContactData.contactId,
                                          'profilePic':
                                              chatContactData.profilePic,
                                          'isGroup': false,
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: ListTile(
                                        title: Text(
                                          chatContactData.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6.0),
                                          child: Text(
                                            chatContactData.lastMessage,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            chatContactData.profilePic,
                                          ),
                                          radius: 30,
                                        ),
                                        trailing: Text(
                                          DateFormat.Hm()
                                              .format(chatContactData.timeSent),
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
                      } else if (chatContactData.name
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
                                          'name': chatContactData.name,
                                          'uid': chatContactData.contactId,
                                          'profilePic':
                                              chatContactData.profilePic,
                                          'isGroup': false,
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: ListTile(
                                        title: Text(
                                          chatContactData.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6.0),
                                          child: Text(
                                            chatContactData.lastMessage,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            chatContactData.profilePic,
                                          ),
                                          radius: 30,
                                        ),
                                        trailing: Text(
                                          DateFormat.Hm()
                                              .format(chatContactData.timeSent),
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
                    });
              } else {
                return const SizedBox.shrink();
              }
            }),
      ),
    );
  }
}
