import 'package:chat_application/common/enums/snackbar_enum.dart';
import 'package:chat_application/common/utils/utils.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final Future<LottieComposition> _composition;
  final phoneController = TextEditingController();
  Country _country = Country(
    phoneCode: '94',
    countryCode: "LK",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Sri Lanka",
    example: "Sri Lanka",
    displayName: "Sri Lanka",
    displayNameNoCountryCode: 'LK',
    e164Key: '',
  );

  @override
  void initState() {
    super.initState();
    _composition = AssetLottie('assets/login_in.json').load();
  }

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
        context: context,
        countryListTheme: const CountryListThemeData(bottomSheetHeight: 550),
        onSelect: (value) {
          setState(() {
            _country = value;
          });
        });
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isNotEmpty &&
        (phoneNumber.length <= 10 && phoneNumber.length > 8)) {
      return ref.read(authControllerProvider).signInWithPhone(
            context,
            '+${_country.phoneCode}$phoneNumber',
          );
    } else {
      showSnackbar(
        context: context,
        content:
            "To Proceed:-> Double-check your phone number is in the correct format and not empty",
        type: SnackBarEnum.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );

    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FutureBuilder<LottieComposition>(
            future: _composition,
            builder: (context, snapshot) {
              var composition = snapshot.data;
              if (composition != null) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Container(
                        width: 200,
                        height: 200,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple.shade50,
                        ),
                        child: Lottie(
                          composition: composition,
                          height: 150,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Add your Phone Number. We'll send you a verification code",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          setState(() {
                            phoneController.text = value;
                          });
                        },
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                            hintText: "Enter Phone Number",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    const BorderSide(color: Colors.black12)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    const BorderSide(color: Colors.black12)),
                            prefixIcon: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 15.0),
                              child: InkWell(
                                onTap: pickCountry,
                                child: Text(
                                  '${_country.flagEmoji} +${_country.phoneCode}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            suffixIcon: phoneController.text.length > 9
                                ? Container(
                                    height: 30,
                                    width: 30,
                                    margin: const EdgeInsets.all(10.0),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                    child: const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                : null),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: sendPhoneNumber,
                          text: 'Login',
                        ),
                      ),
                    ],
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
        ));
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
