import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sql_client/models/products_model.dart';

const Color darkColor = Color.fromARGB(255, 20, 20, 20);
const Color whiteColor = Color.fromARGB(255, 242, 245, 249);
const Color greenColor = Color.fromARGB(255, 56, 170, 0);
const Color lightblueColor = Color.fromARGB(255, 72, 190, 255);
const Color blueColor = Color.fromARGB(255, 0, 99, 175);
const Color redColor = Colors.red;
const Color transparentColor = Colors.transparent;

String url = "";

Box? userData;

List<String> columns = List<String>.generate(10, (int index) => "");

List<Product> products = <Product>[];

final GlobalKey<State> pagerKey = GlobalKey<State>();
