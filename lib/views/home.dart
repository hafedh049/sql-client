import 'package:flutter/material.dart';
import 'package:sql_client/views/side_menu.dart';
import 'package:sql_client/views/sql_table.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            children: <Widget>[
              Expanded(child: SQLTable()),
              SizedBox(width: 20),
              SideMenu(),
            ],
          ),
        ),
      );
}
