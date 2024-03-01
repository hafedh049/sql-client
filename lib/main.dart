import 'package:flutter/material.dart';
import 'package:sql_client/views/auth/sign_in.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SignIn(),
      theme: ThemeData.dark(),
    );
  }
}
