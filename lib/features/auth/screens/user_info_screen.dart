import 'dart:io';

import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-info';
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController statusController;
  bool reasonValidation = true;
  File? image;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    statusController = TextEditingController(
      text: 'Hey There, I am using Connect',
    );
    statusController.addListener(() {
      setState(() {
        reasonValidation = statusController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    statusController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    String name = nameController.text.trim();
    String status = statusController.text.trim();

    if (name.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .saveUserDataToFirebase(context, name, status, image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0XFF3E363F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                ClipPath(
                  clipper: TopClipper(),
                  child: SizedBox(
                    height: size.height / 2.5,
                    width: size.width,
                    child: Container(
                      color: const Color.fromARGB(255, 36, 180, 36),
                      child: CustomPaint(
                        painter: ArcPainter(),
                        child: Align(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              image == null
                                  ? const CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        'https://i.ibb.co/dWmBfNJ/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg',
                                      ),
                                      radius: 64,
                                    )
                                  : CircleAvatar(
                                      backgroundImage: FileImage(
                                        image!,
                                      ),
                                      radius: 64,
                                    ),
                              Positioned(
                                bottom: -10,
                                left: 80,
                                child: IconButton(
                                  onPressed: selectImage,
                                  icon: const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: size.width * 0.95,
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      hintStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  width: size.width * 0.95,
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: statusController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter your status here...',
                      hintStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your status";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 36, 180, 36),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            storeUserData();
          }
        },
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}

class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path orangeArc = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 125)
      ..quadraticBezierTo(
          size.width / 2, size.height * 1.05, size.width, size.height - 125)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    return orangeArc;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path whiteArc = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 125)
      ..quadraticBezierTo(
          size.width / 2, size.height - 100, size.width, size.height - 295)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(whiteArc, Paint()..color = const Color(0XFF3E363F));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
