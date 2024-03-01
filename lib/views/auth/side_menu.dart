import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  CalendarFormat _fromCalendarFormat = CalendarFormat.month;
  DateTime _fromFocusedDay = DateTime.now();
  DateTime _fromSelectedDay = DateTime.now();

  CalendarFormat _toCalendarFormat = CalendarFormat.month;
  DateTime _toFocusedDay = DateTime.now();
  DateTime _toSelectedDay = DateTime.now();

  final List<Map<String, dynamic>> _runSQLQueries = List<Map<String, dynamic>>.generate(
    10,
    (int index) => <String, dynamic>{
      "name": "Run SQL Query",
      "callback": () => showToast("Run SQL Query clicked", greenColor),
    },
  );

  final List<Map<String, dynamic>> _exportCSVs = List<Map<String, dynamic>>.generate(
    2,
    (int index) => <String, dynamic>{
      "name": "Export Table as CSV",
      "callback": () => showToast("Table exported as CSV", greenColor),
    },
  );

  String _from = "From";
  String _to = "To";

  final PageController _dateController = PageController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: darkColor, borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (Map<String, dynamic> runSQL in _runSQLQueries) ...<Widget>[
              AnimatedButton(
                height: 40,
                text: runSQL["name"],
                selectedTextColor: darkColor,
                animatedOn: AnimatedOn.onHover,
                animationDuration: 500.ms,
                isReverse: true,
                selectedBackgroundColor: redColor,
                backgroundColor: purpleColor,
                transitionType: TransitionType.TOP_TO_BOTTOM,
                textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                onPress: runSQL["callback"],
              ),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 20),
            for (Map<String, dynamic> export in _exportCSVs) ...<Widget>[
              AnimatedButton(
                height: 40,
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
            ],
            AnimatedButton(
              height: 40,
              text: "Run Sql Query with datetime variables",
              selectedTextColor: darkColor,
              animatedOn: AnimatedOn.onHover,
              animationDuration: 500.ms,
              isReverse: true,
              selectedBackgroundColor: redColor,
              backgroundColor: purpleColor,
              transitionType: TransitionType.TOP_TO_BOTTOM,
              textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
              onPress: () {},
            ),
            const SizedBox(height: 20),
            StatefulBuilder(
              key: null,
              builder: (BuildContext context, void Function(void Function()) _) {
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () => _dateController.jumpToPage(0),
                        hoverColor: transparentColor,
                        splashColor: transparentColor,
                        highlightColor: transparentColor,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: scaffoldColor),
                          child: Text(_from, style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _dateController.jumpToPage(1),
                        hoverColor: transparentColor,
                        splashColor: transparentColor,
                        highlightColor: transparentColor,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: scaffoldColor),
                          child: Text(_to, style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: PageView(
                controller: _dateController,
                children: <Widget>[
                  TableCalendar(
                    firstDay: DateTime(1970),
                    lastDay: DateTime(2300),
                    focusedDay: _fromFocusedDay,
                    calendarFormat: _fromCalendarFormat,
                    selectedDayPredicate: (DateTime day) => isSameDay(_fromSelectedDay, day),
                    onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                      if (!isSameDay(_fromSelectedDay, selectedDay)) {
                        setState(
                          () {
                            _fromSelectedDay = selectedDay;
                            _fromFocusedDay = focusedDay;
                          },
                        );
                      }
                    },
                    onFormatChanged: (CalendarFormat format) {
                      if (_fromCalendarFormat != format) {
                        setState(
                          () {
                            _fromCalendarFormat = format;
                          },
                        );
                      }
                    },
                    onPageChanged: (DateTime focusedDay) {
                      _fromFocusedDay = focusedDay;
                    },
                  ),
                  TableCalendar(
                    firstDay: DateTime(1970),
                    lastDay: DateTime(2300),
                    focusedDay: _toFocusedDay,
                    calendarFormat: _toCalendarFormat,
                    selectedDayPredicate: (DateTime day) => isSameDay(_toSelectedDay, day),
                    onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                      if (!isSameDay(_toSelectedDay, selectedDay)) {
                        setState(
                          () {
                            _toSelectedDay = selectedDay;
                            _toFocusedDay = focusedDay;
                          },
                        );
                      }
                    },
                    onFormatChanged: (CalendarFormat format) {
                      if (_toCalendarFormat != format) {
                        setState(
                          () {
                            _toCalendarFormat = format;
                          },
                        );
                      }
                    },
                    onPageChanged: (DateTime focusedDay) {
                      _toFocusedDay = focusedDay;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
