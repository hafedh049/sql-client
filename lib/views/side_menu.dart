import 'dart:io';
import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sql_client/models/products_model.dart';
import 'package:sql_client/utils/callbacks.dart';
import 'package:sql_client/utils/shared.dart';
import 'package:table_calendar/table_calendar.dart';

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

  final TextEditingController _hoursController = TextEditingController(text: "00");

  final TextEditingController _fileNameController = TextEditingController();

  List<Map<String, dynamic>> _runSQLQueries = <Map<String, dynamic>>[];

  late final List<Map<String, dynamic>> _exportCSVs;

  final PageController _dateController = PageController();

  @override
  void initState() {
    _exportCSVs = List<Map<String, dynamic>>.generate(
      2,
      (int index) => <String, dynamic>{
        "name": "Export Table as CSV",
        "callback": () async {
          if (kIsWeb) {
            showToast(context, "This feature is not available on web", redColor);
          } else if (products.isEmpty) {
            showToast(context, "Table is empty", redColor);
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                backgroundColor: darkColor,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Spacer(),
                        InkWell(
                          splashColor: transparentColor,
                          hoverColor: transparentColor,
                          highlightColor: transparentColor,
                          onTap: () => _fileNameController.text = List<String>.generate(8, (int index) => Random().nextInt(10).toString()).join(),
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: purpleColor),
                            padding: const EdgeInsets.all(8),
                            child: Text('GENERATE', style: GoogleFonts.itim(color: whiteColor, fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(color: scaffoldColor, borderRadius: BorderRadius.circular(3)),
                      child: StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) _) {
                          return TextField(
                            onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                            controller: _fileNameController,
                            style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: purpleColor, width: 2, style: BorderStyle.solid)),
                              border: InputBorder.none,
                              hintText: 'CSV file name',
                              hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                              prefixIcon: _fileNameController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                            ),
                            cursorColor: purpleColor,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        InkWell(
                          splashColor: transparentColor,
                          hoverColor: transparentColor,
                          highlightColor: transparentColor,
                          onTap: () async {
                            if (_fileNameController.text.trim().isEmpty) {
                              showToast(context, "Please enter a file name", redColor);
                            } else {
                              final File csvFile = File("${(await getApplicationDocumentsDirectory()).path}/${_fileNameController.text.trim()}.csv");
                              if (!(await csvFile.exists())) {
                                await csvFile.create();
                                await csvFile.writeAsString("${columns.join(',')}\n", mode: FileMode.writeOnlyAppend);
                                for (final Product product in products) {
                                  await csvFile.writeAsString("${product.columns.join(',')}\n", mode: FileMode.writeOnlyAppend);
                                }
                                // ignore: use_build_context_synchronously
                                showToast(context, "CSV file has been created and located on your document directory", redColor);
                                _fileNameController.clear();
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: purpleColor),
                            padding: const EdgeInsets.all(8),
                            child: Text('SAVE CSV', style: GoogleFonts.itim(color: whiteColor, fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          splashColor: transparentColor,
                          hoverColor: transparentColor,
                          highlightColor: transparentColor,
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: redColor),
                            padding: const EdgeInsets.all(8),
                            child: Text('CANCEL', style: GoogleFonts.itim(color: whiteColor, fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      },
    );
    super.initState();
  }

  Future<List<Map<String, dynamic>>> _loadQueries() async {
    final Dio dio = Dio();
    final int nbQueries = (await dio.get("$url/totalQuerys")).data["totalQuerys"];
    final Map<String, dynamic> queriesResponse = (await dio.get("$url/getUserQuerys", data: <String, String>{"username": userData!.get("login")})).data["Querys"];
    return <Map<String, dynamic>>[
      for (int index = 0; index < min(nbQueries, queriesResponse.length); index += 1)
        <String, dynamic>{
          "name": "Run SQL Query",
          "callback": () async {
            final ConnectionSettings settings = ConnectionSettings(host: userData!.get("host"), port: 3306, user: userData!.get("username"), password: userData!.get("password"), db: userData!.get("db"));
            final MySqlConnection conn = await MySqlConnection.connect(settings);
            final Results results = await conn.query(queriesResponse[index.toString()]);
            if (queriesResponse[index.toString()].toLowerCase().contains("select")) {
              columns = results.fields.map((Field e) => e.name!.toUpperCase()).toList();
              products = [for (final row in results) Product(row.fields.entries.map((MapEntry<String, dynamic> e) => e.value.toString()).toList())];
              pagerKey.currentState!.setState(() {});
            } else {
              // ignore: use_build_context_synchronously
              showToast(context, results.affectedRows! != 0 ? "Query Executed Successfully" : "Query Failed", results.affectedRows! != 0 ? purpleColor : redColor);
            }
          },
        },
    ];
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hoursController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: darkColor.withOpacity(.1), borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder<List<Map<String, dynamic>>>(
                future: _loadQueries(),
                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasData) {
                    _runSQLQueries = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                      ],
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: purpleColor);
                  } else {
                    return Text(snapshot.error.toString());
                  }
                }),
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
              onPress: () async {
                /*
                  /FROM/ -> 2021-01-01 00
                  /F/ -> 2021-01-01
                  /f/ -> 00
                  */
                /*
                  DATE - format: YYYY-MM-DD.
                  DATETIME - format: YYYY-MM-DD HH:MI:SS.
                  TIMESTAMP - format: YYYY-MM-DD HH:MI:SS.
                  YEAR - format YYYY or YY.
                  */
                String query = (await Dio().get("$url/queryWithTime", data: <String, String>{"username": userData!.get("login")})).data["Querys"];
                final ConnectionSettings settings = ConnectionSettings(host: userData!.get("host"), port: 3306, user: userData!.get("username"), password: userData!.get("password"), db: userData!.get("db"));
                final MySqlConnection conn = await MySqlConnection.connect(settings);
                Results? results;
                if (query.toUpperCase().contains("/FROM/")) {
                  results = await conn.query(
                    query
                        .replaceAll(
                          "/FROM/",
                          formatDate(
                            _fromSelectedDay,
                            <String>[yyyy, "-", mm, "-", dd, " ", _hoursController.text, ":00", ":00"],
                          ),
                        )
                        .replaceAll(
                          "/TO/",
                          formatDate(
                            _toSelectedDay,
                            <String>[yyyy, "-", mm, "-", dd, " ", _hoursController.text, ":00", ":00"],
                          ),
                        ),
                  );
                } else if (query.contains("/F/")) {
                  results = await conn.query(
                    query
                        .replaceAll(
                          "/F/",
                          formatDate(
                            _fromSelectedDay,
                            const <String>[yyyy, "-", mm, "-", dd],
                          ),
                        )
                        .replaceAll(
                          "/T/",
                          formatDate(
                            _toSelectedDay,
                            const <String>[yyyy, "-", mm, "-", dd],
                          ),
                        ),
                  );
                } else {
                  results = await conn.query(
                    query
                        .replaceAll(
                          "/f/",
                          formatDate(
                            _fromSelectedDay,
                            <String>[_hoursController.text, ":00", ":00"],
                          ),
                        )
                        .replaceAll(
                          "/t/",
                          formatDate(
                            _toSelectedDay,
                            <String>[_hoursController.text, ":00", ":00"],
                          ),
                        ),
                  );
                }
                columns = results.fields.map((Field e) => e.name!.toUpperCase()).toList();
                products = <Product>[for (final row in results) Product(row.fields.entries.map((MapEntry<String, dynamic> e) => e.value.toString()).toList())];
                pagerKey.currentState!.setState(() {});
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () => _dateController.animateToPage(0, duration: 300.ms, curve: Curves.ease),
                    hoverColor: transparentColor,
                    splashColor: transparentColor,
                    highlightColor: transparentColor,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: scaffoldColor),
                      child: Text("FROM", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _dateController.animateToPage(1, duration: 300.ms, curve: Curves.ease),
                    hoverColor: transparentColor,
                    splashColor: transparentColor,
                    highlightColor: transparentColor,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: scaffoldColor),
                      child: Text("TO", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: scaffoldColor, borderRadius: BorderRadius.circular(3)),
              child: StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) _) {
                  return TextField(
                    onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                    controller: _hoursController,
                    style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: purpleColor, width: 2, style: BorderStyle.solid)),
                      border: InputBorder.none,
                      hintText: 'Hours',
                      hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor),
                      prefixIcon: _hoursController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                    ),
                    inputFormatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(2), FilteringTextInputFormatter.digitsOnly],
                    cursorColor: purpleColor,
                  );
                },
              ),
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
