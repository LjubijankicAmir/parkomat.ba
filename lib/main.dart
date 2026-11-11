import 'package:flutter/material.dart';
import 'package:parkomat/app.dart';
import 'package:parkomat/core/di/injection.dart';

void main() {
  configureDependencies();
  runApp(const ParkomatApp());
}
