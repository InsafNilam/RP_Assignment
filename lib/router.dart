import 'dart:io';

import 'package:chat_application/common/widgets/error.dart';
import 'package:chat_application/features/auth/screens/login_screen.dart';
import 'package:chat_application/features/auth/screens/otp_screen.dart';
import 'package:chat_application/features/auth/screens/user_info_screen.dart';
import 'package:chat_application/features/groups/screens/create_group.dart';
import 'package:chat_application/features/landing/screens/boarding_page.dart';
import 'package:chat_application/features/select_contacts/screens/contact_screen.dart';
import 'package:chat_application/features/chat/screens/mobile_chat_screen.dart';
import 'package:chat_application/features/status/screens/confirm_screen.dart';
import 'package:chat_application/features/status/screens/status_screen.dart';
import 'package:chat_application/models/status_model.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case OnBoardingPage.routeName:
      return MaterialPageRoute(builder: (context) => const OnBoardingPage());
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case OTPScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final verificationId = arguments['verificationId'];

      return MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
        ),
      );
    case UserInfoScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    case ContactScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const ContactScreen(),
      );
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final profilePic = arguments['profilePic'];
      final isGroup = arguments['isGroup'];

      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
            name: name, uid: uid, profilePic: profilePic, isGroup: isGroup),
      );
    case ConfirmScreen.routeName:
      final file = settings.arguments as File;
      return MaterialPageRoute(
        builder: (context) => ConfirmScreen(
          file: file,
        ),
      );
    case StatusScreen.routeName:
      final status = settings.arguments as StatusModel;
      return MaterialPageRoute(
        builder: (context) => StatusScreen(
          status: status,
        ),
      );
    case CreateGroupScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(error: "This page doesn't exist"),
        ),
      );
  }
}
