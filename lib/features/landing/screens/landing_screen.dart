import 'package:animate_do/animate_do.dart';
import 'package:chat_application/features/landing/screens/boarding_page.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late final Future<LottieComposition> _composition;

  @override
  void initState() {
    super.initState();
    _composition = AssetLottie('assets/landing.json').load();
  }

  void navigateToBoardingScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      OnBoardingPage.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<LottieComposition>(
          future: _composition,
          builder: (context, snapshot) {
            var composition = snapshot.data;
            if (composition != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Lottie(
                        composition: composition,
                        width: MediaQuery.of(context).size.width - 50,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SlideInRight(
                        child: const Text(
                          "Let's get started",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SlideInRight(
                        delay: const Duration(milliseconds: 500),
                        child: const Text(
                          "Never a better time than now to start",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      BounceInUp(
                        delay: const Duration(seconds: 1),
                        child: SizedBox(
                          height: 64,
                          width: 260,
                          child: Stack(
                            children: [
                              Container(
                                height: 64,
                                width: 64,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: CustomButton(
                                  onPressed: () =>
                                      navigateToBoardingScreen(context),
                                  text: "Get Started",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              );
            } else {
              return Column(
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
              );
            }
          },
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({Key? key, required this.onPressed, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.blue, // Border color
            width: 2.0,
          ),
        ),
        margin: const EdgeInsets.only(top: 8, left: 8),
        child: SizedBox(
          height: 64, // Set desired height of the container
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.arrow_forward,
                color: Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   const CustomButton({super.key, required this.text, required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ButtonStyle(
//         foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//         backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
//         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//           RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(25.0),
//           ),
//         ),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 16,
//         ),
//       ),
//     );
//   }
// }
