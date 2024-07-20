import 'package:flutter/material.dart';
import 'package:munturai/screen/splashscreen.dart';


class AppRoutes {
  static const String splashscreenScreen = 'splashscreen';
  static Map<String, WidgetBuilder> routes = {
    splashscreenScreen: (context) => SplashscreenScreen(),
  };
}
