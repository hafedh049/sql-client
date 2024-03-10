import 'dart:convert';

import 'package:animated_loading_border/animated_loading_border.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mysql1/mysql1.dart';
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

  final String _password = "admin";

  Future<void> _signIn(BuildContext context) async {
    var settings = ConnectionSettings(host: '127.0.0.1', port: 3306, user: 'root', password: null, db: 'test');
    var conn = await MySqlConnection.connect(settings);
    var results = await conn.query('select * from usr ');
    for (var row in results) {
      print('Name: ${row[0]}, email: ${row[1]}');
    }
    if (_passwordController.text.trim().isEmpty) {
      showToast("Please enter a correct password", redColor);
    } else if (_usernameController.text.trim().isEmpty) {
      showToast("Please enter a correct e-mail", redColor);
    } else {
      _passKey.currentState!.setState(() => _buttonState = true);
      _passKey.currentState!.setState(() => _buttonState = false);
      if (sha512.convert(utf8.encode(_passwordController.text)) == sha512.convert(utf8.encode(_password))) {
        showToast("Welcome Back", greenColor);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Home()));
      } else {
        showToast("Wrong Credentials", redColor);
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
            borderColor: purpleColor,
            child: Container(
              color: darkColor,
              width: MediaQuery.sizeOf(context).width * .7,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Welcome", style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.w500, color: greyColor)),
                  Container(width: MediaQuery.sizeOf(context).width, height: .3, color: greyColor, margin: const EdgeInsets.symmetric(vertical: 20)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(child: Text("Enter password to continue", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor))),
                      const SizedBox(width: 5),
                      Text("*", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: redColor)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(color: scaffoldColor, borderRadius: BorderRadius.circular(3)),
                    child: StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return TextField(
                          onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                          controller: _usernameController,
                          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: purpleColor, width: 2, style: BorderStyle.solid)),
                            border: InputBorder.none,
                            hintText: 'Username',
                            hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                            prefixIcon: _usernameController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                          ),
                          cursorColor: purpleColor,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(color: scaffoldColor, borderRadius: BorderRadius.circular(3)),
                    child: StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return TextField(
                          obscureText: !_passwordState,
                          onSubmitted: (String value) async => await _signIn(context),
                          onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                          controller: _passwordController,
                          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: purpleColor, width: 2, style: BorderStyle.solid)),
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                            prefixIcon: _passwordController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                            suffixIcon: IconButton(onPressed: () => _(() => _passwordState = !_passwordState), icon: Icon(_passwordState ? FontAwesome.eye_solid : FontAwesome.eye_slash_solid, size: 15, color: purpleColor)),
                          ),
                          cursorColor: purpleColor,
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
                              text: _buttonState ? "WAIT..." : 'CONTINUE',
                              selectedTextColor: darkColor,
                              animatedOn: AnimatedOn.onHover,
                              animationDuration: 500.ms,
                              isReverse: true,
                              selectedBackgroundColor: redColor,
                              backgroundColor: purpleColor,
                              transitionType: TransitionType.TOP_TO_BOTTOM,
                              textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                              onPress: () async => await _signIn(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedOpacity(opacity: _buttonState ? 1 : 0, duration: 300.ms, child: const Icon(FontAwesome.bookmark_solid, color: purpleColor, size: 35)),
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
