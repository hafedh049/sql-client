import 'dart:io';
import 'dart:math';

import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  final List<String> _queryNames = const <String>[
    "Actualizar proveedores",
    "Ventas por hora",
    "Ventas por dia",
    "Ventas por semana",
    "Cifras vendedores",
    "Medias venderores",
    "Actualizacion general",
  ];
  CalendarFormat _fromCalendarFormat = CalendarFormat.month;
  DateTime _fromFocusedDay = DateTime.now();
  DateTime _fromSelectedDay = DateTime.now();

  CalendarFormat _toCalendarFormat = CalendarFormat.month;
  DateTime _toFocusedDay = DateTime.now();
  DateTime _toSelectedDay = DateTime.now();

  String _fromHours = "00";
  String _toHours = "00";

  int _selectedTab = 0;

  final GlobalKey<State<StatefulWidget>> _fromToKey = GlobalKey<State<StatefulWidget>>();

  final TextEditingController _fileNameController = TextEditingController();

  List<Map<String, dynamic>> _runSQLQueries = <Map<String, dynamic>>[];

  late final List<Map<String, dynamic>> _exportCSVs;

  final PageController _dateController = PageController();

  final DropdownController _fromHoursDropdownController = DropdownController();
  final DropdownController _toHoursDropdownController = DropdownController();

  @override
  void initState() {
    _exportCSVs = List<Map<String, dynamic>>.generate(
      1,
      (int index) => <String, dynamic>{
        "name": "Exportar a excel",
        "callback": () async {
          if (products.isEmpty) {
            showToast(context, "La mesa esta vacia", redColor);
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                backgroundColor: whiteColor,
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
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: blueColor),
                            padding: const EdgeInsets.all(8),
                            child: Text('GENERAR', style: GoogleFonts.itim(color: whiteColor, fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
                      child: StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) _) {
                          return TextField(
                            onChanged: (String value) => value.trim().length <= 1 ? _(() {}) : null,
                            controller: _fileNameController,
                            style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20),
                              border: const OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 2, style: BorderStyle.solid)),
                              hintText: 'Nombre del archivo de Excel',
                              hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                              prefixIcon: _fileNameController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, size: 15, color: greenColor),
                            ),
                            cursorColor: blueColor,
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
                              showToast(context, "Por favor ingrese un nombre de archivo", redColor);
                            } else {
                              final File csvFile = File("${(await getApplicationDocumentsDirectory()).path}/${_fileNameController.text.trim()}.csv");
                              if (!(await csvFile.exists())) {
                                await csvFile.create();
                                await csvFile.writeAsString("${columns.join(',')}\n", mode: FileMode.writeOnlyAppend);
                                for (final Product product in products) {
                                  await csvFile.writeAsString("${product.columns.join(',')}\n", mode: FileMode.writeOnlyAppend);
                                }
                                // ignore: use_build_context_synchronously
                                showToast(context, "El archivo CSV ha sido creado y ubicado en su directorio de documentos.", redColor);
                                _fileNameController.clear();
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: blueColor),
                            padding: const EdgeInsets.all(8),
                            child: Text('GUARDAR EXCEL', style: GoogleFonts.itim(color: whiteColor, fontSize: 16, fontWeight: FontWeight.w500)),
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
                            child: Text('CANCELAR', style: GoogleFonts.itim(color: whiteColor, fontSize: 16, fontWeight: FontWeight.w500)),
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
      for (int index = 0; index < min(nbQueries, queriesResponse.length % 7); index += 1)
        <String, dynamic>{
          "name": _queryNames[index],
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
              showToast(context, results.affectedRows! != 0 ? "Consulta ejecutada exitosamente" : "Consulta fallida", results.affectedRows! != 0 ? blueColor : redColor);
            }
          },
        },
    ];
  }

  @override
  void dispose() {
    _dateController.dispose();
    _fileNameController.dispose();
    _toHoursDropdownController.dispose();
    _fromHoursDropdownController.dispose();
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
                            selectedBackgroundColor: greenColor,
                            backgroundColor: blueColor,
                            transitionType: TransitionType.TOP_TO_BOTTOM,
                            textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                            onPress: runSQL["callback"],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: blueColor);
                  } else {
                    return Text(snapshot.error.toString());
                  }
                }),
            for (Map<String, dynamic> export in _exportCSVs) ...<Widget>[
              AnimatedButton(
                height: 40,
                text: export["name"],
                selectedTextColor: darkColor,
                animatedOn: AnimatedOn.onHover,
                animationDuration: 500.ms,
                isReverse: true,
                selectedBackgroundColor: greenColor,
                backgroundColor: blueColor,
                transitionType: TransitionType.TOP_TO_BOTTOM,
                textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                onPress: export["callback"],
              ),
              const SizedBox(height: 20),
            ],
            AnimatedButton(
              height: 40,
              text: "Confirmar fechas",
              selectedTextColor: darkColor,
              animatedOn: AnimatedOn.onHover,
              animationDuration: 500.ms,
              isReverse: true,
              selectedBackgroundColor: greenColor,
              backgroundColor: blueColor,
              transitionType: TransitionType.TOP_TO_BOTTOM,
              textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
              onPress: () async {
                try {
                  String query = (await Dio().get("$url/queryWithTime", data: <String, String>{"username": userData!.get("login")})).data["Querys"];
                  final ConnectionSettings settings = ConnectionSettings(host: userData!.get("host"), port: 3306, user: userData!.get("username"), password: userData!.get("password"), db: userData!.get("db"));
                  final MySqlConnection conn = await MySqlConnection.connect(settings);
                  if (query.toLowerCase().startsWith("select")) {
                    Results results = await conn.query(
                      query
                          .replaceAll("/fd/", _fromSelectedDay.day.toString())
                          .replaceAll("/fm/", _fromSelectedDay.month.toString())
                          .replaceAll("/fy/", _fromSelectedDay.year.toString())
                          .replaceAll(
                            "/fh/",
                            _fromHours,
                          )
                          .replaceAll(
                            "/th/",
                            _toHours,
                          )
                          .replaceAll("/td/", _toSelectedDay.day.toString())
                          .replaceAll("/tm/", _toSelectedDay.month.toString())
                          .replaceAll("/ty/", _toSelectedDay.year.toString()),
                    );
                    columns = results.fields.map((Field e) => e.name!.toUpperCase()).toList();
                    pagerKey.currentState!.setState(
                      () {
                        products = <Product>[for (final row in results) Product(row.fields.entries.map((MapEntry<String, dynamic> e) => e.value.toString()).toList())];
                      },
                    );
                  } else {
                    Results results = await conn.query(query);
                    if (results.affectedRows != 0) {
                    } else {
                      // ignore: use_build_context_synchronously
                      showToast(context, "ACTUALIZACIÓN COMPLETADA", greenColor);
                    }
                  }
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  showToast(context, e.toString(), redColor);
                }
              },
            ),
            const SizedBox(height: 20),
            StatefulBuilder(
                key: _fromToKey,
                builder: (BuildContext context, void Function(void Function()) _) {
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _(() => _selectedTab = 0);
                            _dateController.animateToPage(0, duration: 300.ms, curve: Curves.ease);
                          },
                          hoverColor: transparentColor,
                          splashColor: transparentColor,
                          highlightColor: transparentColor,
                          child: AnimatedContainer(
                            duration: 300.ms,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: _selectedTab == 0 ? blueColor : lightblueColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Desde", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor)),
                                const SizedBox(height: 10),
                                Text(
                                  formatDate(_fromSelectedDay, const <String>[dd, "/", mm, "/", yyyy]),
                                  style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _(() => _selectedTab = 1);
                            _dateController.animateToPage(1, duration: 300.ms, curve: Curves.ease);
                          },
                          hoverColor: transparentColor,
                          splashColor: transparentColor,
                          highlightColor: transparentColor,
                          child: AnimatedContainer(
                            duration: 300.ms,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: _selectedTab == 1 ? blueColor : lightblueColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Hasta", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor)),
                                const SizedBox(height: 10),
                                Text(
                                  formatDate(_toSelectedDay, const <String>[dd, "/", mm, "/", yyyy]),
                                  style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
                    child: CoolDropdown<String>(
                      dropdownItemOptions: DropdownItemOptions(
                        textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                        selectedTextStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: lightblueColor),
                        selectedBoxDecoration: BoxDecoration(color: lightblueColor.withOpacity(.2)),
                      ),
                      resultOptions: ResultOptions(textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor)),
                      defaultItem: CoolDropdownItem(label: "00", value: "00"),
                      dropdownList: <CoolDropdownItem<String>>[
                        for (int hour = 00; hour < 60; hour += 1)
                          CoolDropdownItem(
                            label: hour.toString().padLeft(2, "0"),
                            value: hour.toString().padLeft(2, "0"),
                          ),
                      ],
                      controller: _fromHoursDropdownController,
                      onChange: (String value) => _fromHours = value,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
                    child: CoolDropdown<String>(
                      dropdownItemOptions: DropdownItemOptions(
                        textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor),
                        selectedTextStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: lightblueColor),
                        selectedBoxDecoration: BoxDecoration(color: lightblueColor.withOpacity(.2)),
                      ),
                      resultOptions: ResultOptions(textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: darkColor)),
                      defaultItem: CoolDropdownItem(label: "00", value: "00"),
                      dropdownList: <CoolDropdownItem<String>>[
                        for (int hour = 00; hour < 60; hour += 1)
                          CoolDropdownItem(
                            label: hour.toString().padLeft(2, "0"),
                            value: hour.toString().padLeft(2, "0"),
                          ),
                      ],
                      controller: _toHoursDropdownController,
                      onChange: (String value) => _toHours = value,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: PageView(
                controller: _dateController,
                children: <Widget>[
                  StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) _) {
                      return TableCalendar(
                        locale: "es_US",
                        firstDay: DateTime(1970),
                        lastDay: DateTime(2300),
                        focusedDay: _fromFocusedDay,
                        calendarFormat: _fromCalendarFormat,
                        selectedDayPredicate: (DateTime day) => isSameDay(_fromSelectedDay, day),
                        onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                          if (!isSameDay(_fromSelectedDay, selectedDay)) {
                            _fromSelectedDay = selectedDay;
                            _fromFocusedDay = focusedDay;
                            _fromToKey.currentState!.setState(() {});
                          }
                        },
                        onFormatChanged: (CalendarFormat format) {
                          if (_fromCalendarFormat != format) {
                            _fromCalendarFormat = format;
                          }
                        },
                        onPageChanged: (DateTime focusedDay) {
                          _fromFocusedDay = focusedDay;
                        },
                      );
                    },
                  ),
                  StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) _) {
                      return TableCalendar(
                        locale: "es_ES",
                        firstDay: DateTime(1970),
                        lastDay: DateTime(2300),
                        focusedDay: _toFocusedDay,
                        calendarFormat: _toCalendarFormat,
                        selectedDayPredicate: (DateTime day) => isSameDay(_toSelectedDay, day),
                        onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                          if (!isSameDay(_toSelectedDay, selectedDay)) {
                            _(
                              () {
                                _toSelectedDay = selectedDay;
                                _toFocusedDay = focusedDay;
                              },
                            );
                            _fromToKey.currentState!.setState(() {});
                          }
                        },
                        onFormatChanged: (CalendarFormat format) {
                          if (_toCalendarFormat != format) {
                            _(
                              () {
                                _toCalendarFormat = format;
                              },
                            );
                          }
                        },
                        onPageChanged: (DateTime focusedDay) {
                          _toFocusedDay = focusedDay;
                        },
                      );
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
