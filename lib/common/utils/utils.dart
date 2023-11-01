import 'dart:io';
import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

void showSnackbar({
  required BuildContext context,
  required String content,
  required SnackBarEnum type,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 90,
            decoration: BoxDecoration(
              color: type == SnackBarEnum.info
                  ? const Color(0xFF3B71CA)
                  : type == SnackBarEnum.success
                      ? const Color(0xFF14A44D)
                      : type == SnackBarEnum.warning
                          ? const Color(0xFFE4A11B)
                          : const Color(0xFFC72C41),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 42,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type == SnackBarEnum.info
                            ? "Info"
                            : type == SnackBarEnum.success
                                ? 'Success'
                                : type == SnackBarEnum.warning
                                    ? 'Warning'
                                    : 'Error',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        content,
                        maxLines: 3,
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
              ),
              child: SvgPicture.asset(
                'assets/bubbles.svg',
                height: 40,
                width: 40,
                colorFilter: type == SnackBarEnum.info
                    ? const ColorFilter.mode(
                        Color(0xFF0851C9),
                        BlendMode.srcIn,
                      )
                    : type == SnackBarEnum.success
                        ? const ColorFilter.mode(
                            Color(0xFF0F8C41),
                            BlendMode.srcIn,
                          )
                        : type == SnackBarEnum.warning
                            ? const ColorFilter.mode(
                                Color(0xFFC98B0E),
                                BlendMode.srcIn,
                              )
                            : const ColorFilter.mode(
                                Color(0xFF801336),
                                BlendMode.srcIn,
                              ),
              ),
            ),
          ),
          Positioned(
            top: -12,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/fail.svg',
                  height: 40,
                ),
                Positioned(
                  top: 10,
                  child: SvgPicture.asset(
                    'assets/close.svg',
                    height: 16,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    Future(
      () => showSnackbar(
        context: context,
        content: e.toString(),
        type: SnackBarEnum.error,
      ),
    );
  }
  return image;
}

Future<File?> pickImageFromCamera(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    Future(
      () => showSnackbar(
        context: context,
        content: e.toString(),
        type: SnackBarEnum.error,
      ),
    );
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    Future(
      () => showSnackbar(
        context: context,
        content: e.toString(),
        type: SnackBarEnum.error,
      ),
    );
  }
  return video;
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  GiphyGif? gif;
  try {
    gif = await Giphy.getGif(
      context: context,
      apiKey: 'NJLJEykJ3p88cxljRYmQ4sllRLKIhpjz',
    );
  } catch (err) {
    Future(
      () => showSnackbar(
        context: context,
        content: err.toString(),
        type: SnackBarEnum.error,
      ),
    );
  }
  return gif;
}
