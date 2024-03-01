import 'package:flutter/material.dart';
import 'package:sql_client/utils/shared.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: scaffoldColor,
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: <Widget>[],
        ),
      ),
    );
  }
}
