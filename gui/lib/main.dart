// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:example_project/view/pages/main_page.dart';
import 'infrastructure/get_it.dart';

///This is your main here you add all the processes you want to start before your UI is built.
void main() {
  registerManager();
  checkTypeConnection();
  initVideo();
  init();
  runApp(const MainPage());
}
