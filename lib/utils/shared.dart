import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sql_client/models/products_model.dart';

const Color scaffoldColor = Color.fromARGB(255, 32, 35, 38);
const Color purpleColor = Color.fromARGB(255, 124, 120, 239);
const Color darkColor = Color.fromARGB(255, 20, 20, 20);
const Color whiteColor = Color.fromARGB(255, 242, 245, 249);
const Color greyColor = Color.fromARGB(255, 166, 170, 176);
const Color greenColor = Colors.greenAccent;
const Color blueColor = Colors.blueAccent;
const Color redColor = Colors.red;
const Color transparentColor = Colors.transparent;

String url = "";

Box? userData;

List<String> columns = List<String>.generate(10, (int index) => "");

List<Product> products = <Product>[];

final GlobalKey<State> pagerKey = GlobalKey<State>();
