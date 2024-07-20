import 'dart:ui';
import 'package:flutter/material.dart';

import '../fonctions.dart';

class UIColors  with ChangeNotifier {
  static Color primaryColor = fromHex('#7F4EC4');
  static Color primaryDark = Colors.black;
  static Color primaryAccent_dark = Colors.black;
  static Color primaryAccent_light = fromHex('#ffffff');
  static Color primaryAccent = primaryAccent_light;
  static Color dark_light = fromHex('#000000');
  static Color dark_dark = fromHex('#ffffff');
  static Color dark = dark_light;
  static Color edittextFillColor = fromHex('#BED4CC');
  static Color boxFillColor = fromHex('#C6B1E3');
  static Color boxStrokeColor = primaryDark;
  static Color warningColor = fromHex('#F19101');
  static Color errorColor = Colors.red;
  static Color successColor = primaryColor;
  static Color labelColor = primaryColor;
  static Color hintTextColor = fromHex('#7C8D86');
  static Color cursorColor = primaryDark;
  static Color blueGray100 = fromHex('#d9d9d9');
  static Color txtInactive = Colors.black12;

  void darkMode(){
    primaryAccent=primaryAccent_dark;
    dark=dark_dark;
  }

  void lightMode(){
    primaryAccent=primaryAccent_light;
    dark=dark_light;
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static ThemeData lightTheme(){
    return new ThemeData(
      primaryColor: primaryColor,
      primaryColorDark: primaryDark,
      primaryColorLight: primaryAccent_light,
      visualDensity: VisualDensity.standard,
      brightness: Brightness.light,
    );
  }
  static ThemeData darkTheme(){
    return new ThemeData(
      primaryColor: primaryColor,
      primaryColorDark: primaryDark,
      primaryColorLight: primaryAccent_dark,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.standard,
    );
  }

  late ThemeData _themeData;
  ThemeData getTheme() => _themeData;

  ThemeNotifier() {
    getKey('theme').then((value) {
      print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme();
      } else {
        print('setting dark theme');
        _themeData = darkTheme();
      }
      notifyListeners();
    });
  }

  setDarkMode() async {
    _themeData = darkTheme();
    saveKey('theme', 'dark');
    notifyListeners();
  }

  setLightMode() async {
    _themeData = lightTheme();
    saveKey('theme', 'light');
    notifyListeners();
  }

}
