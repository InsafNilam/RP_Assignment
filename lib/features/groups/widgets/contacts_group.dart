import 'package:chat_application/common/widgets/error.dart';
import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/features/groups/screens/create_group.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

final selectedGroupContact = StateProvider<List<UserModel>>((ref) => []);

class ContactGroupScreen extends ConsumerStatefulWidget {
  const ContactGroupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContactGroupScreen> createState() => _ContactGroupState();
}

class _ContactGroupState extends ConsumerState<ContactGroupScreen> {
  List<int> selectedIndex = [];

  void selectContact(int index, UserModel user) {
    if (selectedIndex.contains(index)) {
      selectedIndex.removeAt(index);
    } else {
      selectedIndex.add(index);
    }
    setState(() {});
    ref.read(selectedGroupContact.notifier).update((state) => [...state, user]);
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(groupSearch);
    return ref.watch(getUserProvider).when(
        data: (users) {
          return Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                if (search.isEmpty) {
                  return AnimationConfiguration.staggeredList(
                    delay: const Duration(milliseconds: 500),
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: InkWell(
                          onTap: () => selectContact(index, user),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: selectedIndex.contains(index)
                                  ? Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(user.profilePic),
                                          radius: 30,
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: const SizedBox.shrink()),
                                        ),
                                        Positioned(
                                          top: -14,
                                          left: -14,
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.done,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.profilePic),
                                      radius: 30,
                                    ),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                user.phoneNumber,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (user.name
                        .toLowerCase()
                        .contains(search.toLowerCase()) ||
                    user.phoneNumber.contains(search)) {
                  return AnimationConfiguration.staggeredList(
                    delay: const Duration(milliseconds: 500),
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: InkWell(
                          onTap: () => selectContact(index, user),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: selectedIndex.contains(index)
                                  ? Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(user.profilePic),
                                          radius: 30,
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: const SizedBox.shrink()),
                                        ),
                                        Positioned(
                                          top: -14,
                                          left: -14,
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.done,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.profilePic),
                                      radius: 30,
                                    ),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                user.phoneNumber,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          );
        },
        error: (error, trace) => ErrorScreen(
              error: error.toString(),
            ),
        loading: () => const Loader());
  }
}
