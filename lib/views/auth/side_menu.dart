import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sql_client/utils/shared.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../utils/callbacks.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
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
            AnimatedButton(
              //width: 300,
              height: 80,
              text: "Run Sql Query with\ndatetime variables",
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
            StatefulBuilder(
              key: null,
              builder: (BuildContext context, void Function(void Function()) _) {
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: scaffoldColor),
                        child: TextField(
                          controller: _from,
                          readOnly: true,
                          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                          decoration: InputDecoration(
                            hintText: "From",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(8),
                            hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: scaffoldColor),
                        child: TextField(
                          controller: _to,
                          readOnly: true,
                          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                          decoration: InputDecoration(
                            hintText: "To",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(8),
                            hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: TableCalendar(
                    firstDay: DateTime(1970),
                    lastDay: DateTime(2300),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (DateTime day) => isSameDay(_selectedDay, day),
                    onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        // Call `setState()` when updating the selected day
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        // Call `setState()` when updating calendar format
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      // No need to call `setState()` here
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
