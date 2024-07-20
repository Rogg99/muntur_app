import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:munturai/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getwidget/getwidget.dart';

Text texte(String data,
    {color = Colors.black,
    fontSize = 22.0,
    fontStyle = FontStyle.normal,
    fontWeight = FontWeight.normal,
    textAlign = TextAlign.center}) {
  return Text(
    data,
    textAlign: textAlign,
    style: TextStyle(color: color, fontStyle: fontStyle, fontSize: fontSize, fontWeight: fontWeight),
  );
}

Icon icone(IconData icon, {color: Colors.blue, size: 20.0}) {
  return Icon(
    icon,
    color: color,
    size: size,
  );
}

void navigate(BuildContext context, Composant) {
  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
    return Composant;
  }));
}

Future<bool?> toast(String message, {color = Colors.green}) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
      backgroundColor: color);
}

gftoast(BuildContext context, String message,
    {position = GFToastPosition.CENTER, bgcolor = GFColors.DANGER, duration = 5}) {
  return GFToast.showToast(message, context,
      toastPosition: position,
      backgroundColor: bgcolor,
      toastDuration: duration,
      trailing: const Icon(
        Icons.notifications,
        color: GFColors.SUCCESS,
      ));
}

void loading() {
  EasyLoading.show(status: 'muntur ...', maskType: EasyLoadingMaskType.black);
}

void stopLoading() {
  EasyLoading.dismiss();
}

Future<String> waitTask() async {
  await Future.delayed(const Duration(seconds: 5));
  return 'completed';
}

Future<bool> saveKey(String key, String value) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString(key, value);
  //log('Saved key: ' + key);
  return true;
}

Future<String> getKey(String key) async {
  //log('getting key: ' + key);
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String value = sharedPreferences.getString(key) ?? '';
  return value;
}

GFAppBar appBar(String title) {
  return GFAppBar(
    title: texte(title, color: Colors.white),
    actions: <Widget>[
      GFIconButton(
        icon: const Icon(
          Icons.account_circle,
          color: Colors.white,
        ),
        onPressed: () {
          print("mettre à jour son profil");
        },
        type: GFButtonType.transparent,
      ),
    ],
  );
}

GFDrawer drawer(BuildContext context, User user) {
  return GFDrawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        GFDrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  color: Colors.blue,
                  height: 70.0,
                  child: Center(
                    child: detailImage(user.photo),
                  )),
              Center(
                child: Column(
                  children: [
                    texte('${user.sexe} ${user.nom} ${user.prenom}', color: Colors.white, fontSize: 15.0),
                    texte('${user.email}', color: Colors.white, fontSize: 15.0)
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );
}

Image detailImage(String img) {
  Uint8List bytes = base64.decode(img);
  return Image.memory(bytes, fit: BoxFit.fill);
}

ImageProvider detailImage1(String img) {
  Uint8List bytes = base64.decode(img);
  return MemoryImage(bytes);
}
