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
  final TextEditingController _rootController = TextEditingController(text: userData!.get("username"));
  final TextEditingController _passwordController = TextEditingController(text: userData!.get("password") ?? "");
  final TextEditingController _localhostController = TextEditingController(text: userData!.get("host"));
  final TextEditingController _dbController = TextEditingController(text: userData!.get("db"));

  Future<void> _connectMySQL(BuildContext context) async {
    _buttonState = false;
    if (_rootController.text.isEmpty) {
      showToast(context, "Por favor ingrese un nombre de usuario correcto", redColor);
    } else if (_localhostController.text.trim().isEmpty) {
      showToast(context, "Por favor ingrese un host local correcto", redColor);
    } else if (_dbController.text.trim().isEmpty) {
      showToast(context, "Por favor ingrese un nombre de base de datos correcto", redColor);
    } else {
      _buttonState = true;
      userData!.put("username", _rootController.text);
      userData!.put("password", _passwordController.text.isEmpty ? null : _passwordController.text);
      userData!.put("host", _localhostController.text);
      userData!.put("db", _dbController.text);
      Navigator.pop(context);
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
        borderColor: blueColor,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: lightblueColor.withOpacity(.1)),
          width: MediaQuery.sizeOf(context).width * .7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("CONEXIÓN DE BASE DE DATOS", style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.w500, color: darkColor)),
              Container(width: MediaQuery.sizeOf(context).width, height: .3, color: darkColor, margin: const EdgeInsets.symmetric(vertical: 20)),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
                child: StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) _) {
                    return TextField(
                      onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                      controller: _rootController,
                      style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: blueColor, width: 2, style: BorderStyle.solid)),
                        hintText: 'Nombre de usuario',
                        hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                        prefixIcon: _rootController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                      ),
                      cursorColor: blueColor,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
                child: StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) _) {
                    return TextField(
                      obscureText: !_passwordState,
                      onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                      controller: _passwordController,
                      style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: blueColor, width: 2, style: BorderStyle.solid)),
                        hintText: 'Contraseña',
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
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
                child: StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) _) {
                    return TextField(
                      onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                      controller: _localhostController,
                      style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: blueColor, width: 2, style: BorderStyle.solid)),
                        hintText: 'Servidor local',
                        hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                        prefixIcon: _localhostController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                      ),
                      cursorColor: blueColor,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
                child: StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) _) {
                    return TextField(
                      onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                      controller: _dbController,
                      style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: blueColor, width: 2, style: BorderStyle.solid)),
                        hintText: 'Nombre de la base de datos',
                        hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                        prefixIcon: _dbController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                      ),
                      cursorColor: blueColor,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
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
                              text: _buttonState ? "ESPERAR..." : 'AHORRAR',
                              selectedTextColor: darkColor,
                              animatedOn: AnimatedOn.onHover,
                              animationDuration: 500.ms,
                              isReverse: true,
                              selectedBackgroundColor: blueColor,
                              backgroundColor: blueColor,
                              transitionType: TransitionType.TOP_TO_BOTTOM,
                              textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                              onPress: () async => await _connectMySQL(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedOpacity(opacity: _buttonState ? 1 : 0, duration: 300.ms, child: const Icon(FontAwesome.bookmark_solid, color: blueColor, size: 35)),
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  AnimatedButton(
                    width: 150,
                    height: 40,
                    text: "CANCELAR",
                    selectedTextColor: darkColor,
                    animatedOn: AnimatedOn.onHover,
                    animationDuration: 500.ms,
                    isReverse: true,
                    selectedBackgroundColor: redColor,
                    backgroundColor: redColor,
                    transitionType: TransitionType.TOP_TO_BOTTOM,
                    textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                    onPress: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
