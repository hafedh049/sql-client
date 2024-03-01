import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sql_client/utils/shared.dart';

void showToast(String message, Color color) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: color,
    fontSize: 16,
    textColor: whiteColor,
    timeInSecForIosWeb: 2,
    webPosition: "right",
    webShowClose: true,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM_RIGHT,
    webBgColor: "rgb(${color.red},${color.green},${color.blue})",
  );
}
