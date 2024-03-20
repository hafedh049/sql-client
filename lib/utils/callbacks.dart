import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sql_client/utils/shared.dart';
import 'package:toastification/toastification.dart';

void showToast(BuildContext context, String message, Color color) {
  toastification.show(
    context: context,
    title: Text(color == redColor ? "Error" : "Notificación", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: color)),
    description: Text(message, style: GoogleFonts.itim(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
    autoCloseDuration: const Duration(seconds: 5),
  );
}

Future<String> authGuarder(BuildContext context) async {
  try {
    final Response response = await Dio().post("$url/login", data: <String, String>{"username": userData!.get("login"), "password": userData!.get("pwd")});
    if (response.statusCode == 200 && response.data["data"]["authorized"]) {
      return userData!.get("login");
    }
    userData!.put("login", "");
    userData!.put("pwd", "");
    return "";
  } catch (e) {
    return "";
  }
}

Future<void> init() async {
  Hive.init((await getApplicationDocumentsDirectory()).path);
  userData = await Hive.openBox("userData");
  if (!userData!.containsKey("username")) {
    userData!.put("username", "root");
  }
  if (!userData!.containsKey("password")) {
    userData!.put("password", null);
  }
  if (!userData!.containsKey("host")) {
    userData!.put("host", "127.0.0.1");
  }
  if (!userData!.containsKey("db")) {
    userData!.put("db", "test");
  }
  if (!userData!.containsKey("port")) {
    userData!.put("port", "3306");
  }
  if (!userData!.containsKey("login")) {
    userData!.put("login", "");
  }
  if (!userData!.containsKey("server")) {
    userData!.put("server", "MySQL");
  }
}
