import 'package:animate_do/animate_do.dart';
import 'package:chat_application/colors.dart';
import 'package:chat_application/common/widgets/error.dart';
import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/features/select_contacts/controller/contact_controller.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ContactScreen extends ConsumerStatefulWidget {
  static const String routeName = '/contact-screen';
  const ContactScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  String search = '';
  void selectUser(WidgetRef ref, UserModel user, BuildContext context) {
    ref.read(contactControllerProvider).selectUser(user, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EasySearchBar(
        title: BounceInDown(
          child: const Text(
            'Select Contacts',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
          setState(() {
            search = value;
          });
        },
        suggestionBackgroundColor: Colors.white,
        searchTextKeyboardType: TextInputType.text,
      ),
      body: ref.watch(getUserProvider).when(
          data: (users) => Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var user = users[index];
                        final key = ValueKey(user.uid);
                        if (search.isEmpty) {
                          return AnimationConfiguration.staggeredList(
                            delay: const Duration(milliseconds: 500),
                            position: index,
                            child: SlideAnimation(
                              child: FadeInAnimation(
                                child: Card(
                                  key: key,
                                  elevation:
                                      4, // Add a subtle shadow to the card
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: InkWell(
                                    onTap: () => selectUser(ref, user, context),
                                    child: ListTile(
                                      title: Text(
                                        user.name,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(user.phoneNumber),
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user.profilePic),
                                        radius: 30,
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
                                child: Card(
                                  key: key,
                                  elevation:
                                      4, // Add a subtle shadow to the card
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: InkWell(
                                    onTap: () => selectUser(ref, user, context),
                                    child: ListTile(
                                      title: Text(
                                        user.name,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(user.phoneNumber),
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user.profilePic),
                                        radius: 30,
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
                  ),
                ],
              ),
          error: (error, trace) => ErrorScreen(
                error: error.toString(),
              ),
          loading: () => const Loader()),
    );
  }
}

// FutureBuilder<List<UserModel>>(
//             future: ref.read(authControllerProvider).getUsers(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Loader();
//               } else if (snapshot.hasData) {
//                 return Expanded(
//                   child: ListView.builder(
//                       itemCount: snapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         var user = snapshot.data![index];
//                         final key = ValueKey(user.uid);
//                         return Card(
//                           key: key,
//                           elevation: 4, // Add a subtle shadow to the card
//                           margin: const EdgeInsets.symmetric(
//                             vertical: 8,
//                             horizontal: 8,
//                           ), 
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10) 
//                           ),
//                           child: InkWell(
//                             onTap: () => selectUser(ref, user, context),
//                             child: ListTile(
//                               title: Text(
//                                 user.name,
//                                 style: const TextStyle(fontSize: 18),
//                               ),
//                               subtitle: Text(user.phoneNumber),
//                               leading: CircleAvatar(
//                                 backgroundImage: NetworkImage(user.profilePic),
//                                 radius: 30,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                 );
//               } else {
//                 return const SizedBox.shrink();
//               }
//             }));