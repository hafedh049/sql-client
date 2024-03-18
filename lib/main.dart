import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sql_client/utils/callbacks.dart';
import 'package:sql_client/views/auth/sign_in.dart';

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
    return const MaterialApp(debugShowCheckedModeBanner: false, home: SignIn());
  }
}
