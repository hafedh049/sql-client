import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sql_client/utils/shared.dart';

import '../../utils/callbacks.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final List<Map<String, dynamic>> _runSQLQueries = List<Map<String, dynamic>>.generate(
    10,
    (int index) => <String, dynamic>{
      "name": "Run SQL Query",
      "callback": () => showToast("Run SQL Query clicked", greenColor),
    },
  );

  final List<Map<String, dynamic>> _exportCSVs = List<Map<String, dynamic>>.generate(
    10,
    (int index) => <String, dynamic>{
      "name": "Export Table as CSV",
      "callback": () => showToast("Table exported as CSV", greenColor),
    },
  );

  final TextEditingController _from = TextEditingController();
  final TextEditingController _to = TextEditingController();

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: darkColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              itemBuilder: (BuildContext context, int index) => AnimatedButton(
                width: 300,
                height: 60,
                text: _runSQLQueries[index]["name"],
                selectedTextColor: darkColor,
                animatedOn: AnimatedOn.onHover,
                animationDuration: 500.ms,
                isReverse: true,
                selectedBackgroundColor: redColor,
                backgroundColor: purpleColor,
                transitionType: TransitionType.TOP_TO_BOTTOM,
                textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                onPress: _runSQLQueries[index]["callback"],
              ),
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
              itemCount: _runSQLQueries.length,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 20),
          for (Map<String, dynamic> export in _exportCSVs) ...<Widget>[
            AnimatedButton(
              //width: 300,
              height: 60,
              text: export["name"],
              selectedTextColor: darkColor,
              animatedOn: AnimatedOn.onHover,
              animationDuration: 500.ms,
              isReverse: true,
              selectedBackgroundColor: redColor,
              backgroundColor: purpleColor,
              transitionType: TransitionType.TOP_TO_BOTTOM,
              textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
              onPress: export["callback"],
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[],
            ),
          ],
        ],
      ),
    );
  }
}
