import 'package:chat_application/colors.dart';
import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/status/controller/status_controller.dart';
import 'package:chat_application/features/status/screens/status_screen.dart';
import 'package:chat_application/models/status_model.dart';
import 'package:chat_application/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class StatusContactScreen extends ConsumerWidget {
  const StatusContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.read(overallSearch);
    return FutureBuilder<List<StatusModel>>(
      future: ref.read(statusControllerProvider).getStatus(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height - 180,
            width: MediaQuery.of(context).size.width,
            child: const Loader(),
          );
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var statusData = snapshot.data![index];
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
                                StatusScreen.routeName,
                                arguments: statusData,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  statusData.username,
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    statusData.profilePic,
                                  ),
                                  radius: 30,
                                ),
                              ),
                            ),
                          ),
                          const Divider(color: dividerColor, indent: 85),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (statusData.username
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
                                StatusScreen.routeName,
                                arguments: statusData,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  statusData.username,
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    statusData.profilePic,
                                  ),
                                  radius: 30,
                                ),
                              ),
                            ),
                          ),
                          const Divider(color: dividerColor, indent: 85),
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
    );
  }
}
