import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sql_client/utils/shared.dart';
import 'package:toastification/toastification.dart';

void showToast(BuildContext context, String message, Color color) {
  toastification.show(
    context: context,
    title: Text(message),
    autoCloseDuration: const Duration(seconds: 5),
  );
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
}
