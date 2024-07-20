import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/screen/splashscreen.dart';
import 'package:munturai/services/api.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/core/colors/colors.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
var API = Api();

ThemeMode _themeMode = ThemeMode.light;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('fr_FR');
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  if (kIsWeb) {

    // Initialize FFI
    //sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfiWeb;
    // Android-specific code
  }

  //await saveKey('theme','dark');
  try {
    if(await API.getUI_user().then((value) => value.length)>0){
    var selfUser=await API.getUI_user().then((value) => value[0]);
    var updatedListMessages = await API.local_getMessage().then((value) => value);
    for (var ie = 0; ie < updatedListMessages.length; ie++)
      {
        if(updatedListMessages[ie].emetteur!=selfUser.id && (updatedListMessages[ie].state=='received' || updatedListMessages[ie].state=='sent')){
          updatedListMessages[ie].announced='no';
          API.local_updateMessage(updatedListMessages[ie]);
        }
      }
    }
    if (await API.getTokens().then((value) => value.length) < 0) {
      await API.createTables();
    } else {
      API.keepTokenAlive(force: true);
      API.syncData();
    }
  }
  on Exception catch (e) {
    final Map<String, dynamic> emptyUnit =  {
      "month_preinscriptions": 0,
      "month_inscriptions": 0,
      "day_preinscriptions": 0,
      "day_inscriptions": 0,
      "_18_19s": 0,
      "diaspora": 0,
      "militant": {
        "id": "none",
        "nom": "none",
        "prenom": "none",
        "score": 0
      },
      "commune": {
        "id": "none",
        "name": "none",
        "score": 0
      },
      "departement": {
        "id": "none",
        "name": "none",
        "score": 0
      },
      "region": {
        "id": "none",
        "name": "none",
        "score": 0
      },
      "subdivisions":[]
    };
    await saveKey('theme','light');
    await saveKey('language','français');
    await saveKey('global-day_inscriptions', emptyUnit.toString());
    await saveKey('global-month_inscriptions', emptyUnit.toString());
    await saveKey('global-day_preinscriptions', emptyUnit.toString());
    await saveKey('global-month_preinscriptions', emptyUnit.toString());
    await saveKey('global-all_couverture', '0');
    await saveKey('global-month_couverture', '0');
    await saveKey('day_inscriptions', '0');
    await saveKey('month_inscriptions', '0');
    await saveKey('day_preinscriptions','0');
    await saveKey('month_preinscriptions', '0');
    await saveKey('all_preinscriptions', '0');
    await saveKey('all_inscriptions', '0');
    await saveKey('day_inscriptions_rank', '0');
    await saveKey('month_inscriptions_rank', '0');
    await saveKey('day_preinscriptions_rank','0');
    await saveKey('month_preinscriptions_rank', '0');
    await saveKey('all_preinscriptions_rank', '0');
    await saveKey('all_inscriptions_rank', '0');
    await saveKey('localityStats', emptyUnit.toString());
    await API.createTables();
  }

  try{
    int.parse(await getKey('last_update'));
  }
  on Exception catch(e){
    await saveKey('theme','light');
    await saveKey('language','français');
    await saveKey('last_update', '0');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  MyApp({Key? key})
      : super(
    key: key,
  );
  // The navigator key is necessary to navigate using static methods
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => MyApp_();
}

class MyApp_ extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: UIColors.lightTheme(),
      darkTheme: UIColors.darkTheme(),
      themeMode: _themeMode,
      title: 'muntur',
      debugShowCheckedModeBanner: false,
      home: SplashscreenScreen(),
    );
  }
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}
