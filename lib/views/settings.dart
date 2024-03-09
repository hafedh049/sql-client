import 'package:animated_loading_border/animated_loading_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

import '../utils/callbacks.dart';
import '../utils/shared.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _passwordState = false;
  bool _buttonState = false;

  final GlobalKey<State> _passKey = GlobalKey<State>();
  final TextEditingController _rootController = TextEditingController(text: "root");
  final TextEditingController _passwordController = TextEditingController(text: "");
  final TextEditingController _localhostController = TextEditingController(text: "127.0.0.1");
  final TextEditingController _dbController = TextEditingController(text: "my_db");

  Future<void> _connectMySQL() async {
    _buttonState = false;
    if (_rootController.text != "root") {
      showToast("Please enter a correct username", redColor);
    } else if (_passwordController.text != "") {
      showToast("Please enter a correct password", redColor);
    } else if (_localhostController.text.trim().isEmpty) {
      showToast("Please enter a correct localhost", redColor);
    } else if (_dbController.text.trim().isEmpty) {
      showToast("Please enter a correct database name", redColor);
    } else {
      _buttonState = true;
    }
  }

  @override
  void dispose() {
    _rootController.dispose();
    _passwordController.dispose();
    _localhostController.dispose();
    _dbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AnimatedLoadingBorder(
        borderWidth: 4,
        cornerRadius: 15,
        borderColor: purpleColor,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: darkColor),
          width: MediaQuery.sizeOf(context).width * .7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Welcome", style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.w500, color: greyColor)),
              Container(width: MediaQuery.sizeOf(context).width, height: .3, color: greyColor, margin: const EdgeInsets.symmetric(vertical: 20)),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: scaffoldColor, borderRadius: BorderRadius.circular(3)),
                child: StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) _) {
                    return TextField(
                      onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                      controller: _rootController,
                      style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: purpleColor, width: 2, style: BorderStyle.solid)),
                        border: InputBorder.none,
                        hintText: 'Username',
                        hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                        prefixIcon: _rootController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
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
              Container(
                decoration: BoxDecoration(color: scaffoldColor, borderRadius: BorderRadius.circular(3)),
                child: StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) _) {
                    return TextField(
                      onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                      controller: _localhostController,
                      style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: purpleColor, width: 2, style: BorderStyle.solid)),
                        border: InputBorder.none,
                        hintText: 'Username',
                        hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                        prefixIcon: _localhostController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
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
                      onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                      controller: _dbController,
                      style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: purpleColor, width: 2, style: BorderStyle.solid)),
                        border: InputBorder.none,
                        hintText: 'Password',
                        hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                        prefixIcon: _dbController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
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
                          onPress: () async => await _connectMySQL(),
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
    );
  }
}
