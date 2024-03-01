import 'package:flutter/material.dart';
import 'package:sql_client/utils/shared.dart';

import '../../utils/callbacks.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final List<Map<String, dynamic>> _runSQLQueries = <Map<String, dynamic>>[
    <String, dynamic>{
      "name": "Run SQL Query",
      "callback": () => showToast("Run SQL Query clicked", greenColor),
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: darkColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[],
      ),
    );
  }
}
