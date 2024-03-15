// ignore_for_file: use_build_context_synchronously

import 'package:animated_loading_border/animated_loading_border.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sql_client/utils/shared.dart';

import '../../utils/callbacks.dart';
import '../home.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _passwordState = false;

  bool _buttonState = false;

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _usernameController = TextEditingController();

  final GlobalKey<State> _passKey = GlobalKey<State>();

  Future<void> _signIn(BuildContext context) async {
    if (_passwordController.text.trim().isEmpty) {
      showToast(context, "Please enter a correct password", redColor);
    } else if (_usernameController.text.trim().isEmpty) {
      showToast(context, "Please enter a correct e-mail", redColor);
    } else {
      _passKey.currentState!.setState(() => _buttonState = true);
      _passKey.currentState!.setState(() => _buttonState = false);
      final response = await Dio().post("$url/login", data: <String, String>{"username": _usernameController.text, "password": _passwordController.text});

      if (response.statusCode == 200) {
        if (response.data["data"]["authorized"]) {
          showToast(context, "Welcome Back", greenColor);
          userData!.put("login", _usernameController.text);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Home()));
        } else {
          showToast(context, "THIS USER IS NOT AUTHORIZED", redColor);
        }
      } else {
        showToast(context, "WRONG CREDENTIALS", redColor);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: scaffoldColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: AnimatedLoadingBorder(
            borderWidth: 4,
            borderColor: blueColor,
            child: Container(
              color: lightblueColor.withOpacity(.1),
              width: MediaQuery.sizeOf(context).width * .7,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Welcome", style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.w500, color: darkColor)),
                  Container(width: MediaQuery.sizeOf(context).width, height: .3, color: darkColor, margin: const EdgeInsets.symmetric(vertical: 20)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(child: Text("Enter your credentials", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor))),
                      const SizedBox(width: 5),
                      Text("*", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: redColor)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(color: lightblueColor.withOpacity(.1), borderRadius: BorderRadius.circular(5)),
                    child: StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return TextField(
                          onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                          controller: _usernameController,
                          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: blueColor, width: 2, style: BorderStyle.solid)),
                            border: InputBorder.none,
                            hintText: 'Username',
                            hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                            prefixIcon: _usernameController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                          ),
                          cursorColor: blueColor,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                    child: StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return TextField(
                          obscureText: !_passwordState,
                          onSubmitted: (String value) async => await _signIn(context),
                          onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                          controller: _passwordController,
                          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: blueColor, width: 2, style: BorderStyle.solid)),
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                            prefixIcon: _passwordController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                            suffixIcon: IconButton(onPressed: () => _(() => _passwordState = !_passwordState), icon: Icon(_passwordState ? FontAwesome.eye_solid : FontAwesome.eye_slash_solid, size: 15, color: blueColor)),
                          ),
                          cursorColor: blueColor,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  StatefulBuilder(
                    key: _passKey,
                    builder: (BuildContext context, void Function(void Function()) _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IgnorePointer(
                            ignoring: _buttonState,
                            child: AnimatedButton(
                              width: 150,
                              height: 40,
                              text: _buttonState ? "WAIT..." : 'SIGN-IN',
                              selectedTextColor: darkColor,
                              animatedOn: AnimatedOn.onHover,
                              animationDuration: 500.ms,
                              isReverse: true,
                              selectedBackgroundColor: redColor,
                              backgroundColor: blueColor,
                              transitionType: TransitionType.TOP_TO_BOTTOM,
                              textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                              onPress: () async => await _signIn(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedOpacity(opacity: _buttonState ? 1 : 0, duration: 300.ms, child: const Icon(FontAwesome.bookmark_solid, color: blueColor, size: 35)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
