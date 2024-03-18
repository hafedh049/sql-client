import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sql_client/utils/callbacks.dart';
import 'package:sql_client/views/auth/sign_in.dart';
import 'package:sql_client/views/home.dart';

import 'utils/shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  url = jsonDecode(await rootBundle.loadString("assets/configs/config.json"))["url"];
  await init();
  await initializeDateFormatting("es_ES");
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String>(
        future: authGuarder(context),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!.isEmpty ? const SignIn() : const Home();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: blueColor)),
              ),
            );
          } else {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    snapshot.error.toString(),
                    style: GoogleFonts.itim(fontSize: 16, color: darkColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
