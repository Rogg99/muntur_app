import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/screen/login.dart';
import 'package:munturai/screen/presentation.dart';
import 'package:munturai/widgets/custom_image_view.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/Token.dart';

import 'package:munturai/services/api.dart';

import '../core/fonctions.dart';
import 'home.dart';

Color dot1 = UIColors.blueGray100;
Color dot2 = UIColors.blueGray100;
Color dot3 = UIColors.blueGray100;
Color dot4 = UIColors.blueGray100;
Color dot5 = UIColors.blueGray100;
Color dot6 = UIColors.blueGray100;


class SplashscreenScreen extends StatefulWidget {
  SplashscreenScreen({Key? key})
      : super(
          key: key,
        );
  @override
  State<SplashscreenScreen> createState() => Animated();
}

class Animated extends State<SplashscreenScreen> with TickerProviderStateMixin {
  String uitheme='light';
  late Animation<double> animation;
  late AnimationController controller;
  final API = Api();
  var results;
  @override
  void initState() {
      getKey('theme').then((value) => (){
        log('AppTheme : $value');
          uitheme=value;
       setState(() {
       });
     });
    super.initState();
    int i = 1;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    animation = Tween<double>(begin: 0, end: 6).animate(controller)
      ..addListener(() {
        setState(() {
        });
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isCompleted) {
      Token? tokenFromAPI;
      API.getTokens().then((value) => {
            if (value.length > 0)
              {
                log('Muntur DEBUG: local token time :  ' + value[0].time.floor().toString()),
                log('Muntur DEBUG: actual time :  ' + (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString()),
                if (value[0].time > DateTime.now().millisecondsSinceEpoch / 1000)
                  {
                    log('Muntur DEBUG: local token access not expired :  ' + value[0].access),
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())),
                  }
                else
                  {
                    log('Muntur DEBUG: local token access expired '),
                    log('Muntur DEBUG: refreshing token '),
                    API.login(value[0].email, value[0].password).then((response) => {
                          if (response.statusCode == 200)
                            {
                              results = json.decode(response.body),
                              log("DEBUG Muntur : new token access ,  : " + results['access'].toString()),
                              API
                                  .updateToken(Token(
                                      password: value[0].password,
                                      email: value[0].email,
                                      refresh: results['access'],
                                      access: results['access'],
                                      time: DateTime.now().millisecondsSinceEpoch / 1000 + (3600 * 24)))
                                  .then((resp) =>
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())),
                              ),
                            }
                          else
                            {
                              results = json.decode(response.body),
                              log("DEBUG Muntur : refreshing token failed : " + results['access'].toString()),
                              log("DEBUG Muntur : connecting with local token"),
                              API.login(value[0].email, value[0].password).then((response2) => {
                                    if (response2.statusCode == 200)
                                      {
                                        tokenFromAPI = Token.fromJson(jsonDecode(response.body)),
                                        tokenFromAPI!.time = DateTime.now().millisecondsSinceEpoch / 1000,
                                        tokenFromAPI!.password = value[0].password,
                                        tokenFromAPI!.email = value[0].email,
                                        API.getTokens().then((value2) => {
                                              if (value2.isNotEmpty)
                                                {
                                                  API.updateToken(tokenFromAPI!).then((value2) => {
                                                        log('Muntur DEBUG: connected successfully'),
                                                        Navigator.pushReplacement(context,
                                                            MaterialPageRoute(builder: (context) => HomeScreen())),
                                                      }),
                                                }
                                            }),
                                      }
                                    else
                                      {
                                        log('Muntur DEBUG: auto login failed'),
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())),
                                      }
                                  }),
                            }
                        }),
                  }
              }
            else
              Timer(
                  Duration(seconds: 1),
                  () =>
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PresentationScreen())),
              ),
          });
    }
    return Scaffold(
      backgroundColor: UIColors.primaryAccent,
      body: Container(
        width: double.maxFinite,
        padding: getPadding(
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImageView(
              fit: BoxFit.fitWidth,
              imagePath: ImageConstant.logo_dark,
              height: 100,
              width: BodyWidth(),
              margin: getMargin(
                top: 42,
              ),
            ),
            Padding(
              padding: getPadding(
                top: 71,
                bottom: 30,
              ),
              child: Text(
                "",
                maxLines: null,
                textAlign: TextAlign.center,
                style: AppStyle.txtInter(weight: 'bold',size: 24,color: UIColors.primaryColor),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: getSize(
                    15,
                  ),
                  width: getSize(
                    15,
                  ),
                  decoration: BoxDecoration(
                    color: animation.value >= 1.0 ? UIColors.primaryColor : UIColors.blueGray100,
                    borderRadius: BorderRadius.circular(
                      getHorizontalSize(
                        7,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: getSize(
                    15,
                  ),
                  width: getSize(
                    15,
                  ),
                  margin: getMargin(
                    left: 19,
                  ),
                  decoration: BoxDecoration(
                    color: animation.value >= 2.0 ? UIColors.primaryColor : UIColors.blueGray100,
                    borderRadius: BorderRadius.circular(
                      getHorizontalSize(
                        7,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: getSize(
                    15,
                  ),
                  width: getSize(
                    15,
                  ),
                  margin: getMargin(
                    left: 19,
                  ),
                  decoration: BoxDecoration(
                    color: animation.value >= 3.0 ? UIColors.primaryColor : UIColors.blueGray100,
                    borderRadius: BorderRadius.circular(
                      getHorizontalSize(
                        7,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: getSize(
                    15,
                  ),
                  width: getSize(
                    15,
                  ),
                  margin: getMargin(
                    left: 19,
                  ),
                  decoration: BoxDecoration(
                    color: animation.value >= 4.0 ? UIColors.primaryColor : UIColors.blueGray100,
                    borderRadius: BorderRadius.circular(
                      getHorizontalSize(
                        7,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: getSize(
                    15,
                  ),
                  width: getSize(
                    15,
                  ),
                  margin: getMargin(
                    left: 19,
                  ),
                  decoration: BoxDecoration(
                    color: animation.value >= 5.0 ? UIColors.primaryColor : UIColors.blueGray100,
                    borderRadius: BorderRadius.circular(
                      getHorizontalSize(
                        7,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: getSize(
                    15,
                  ),
                  width: getSize(
                    15,
                  ),
                  margin: getMargin(
                    left: 19,
                  ),
                  decoration: BoxDecoration(
                    color: animation.value >= 6.0 ? UIColors.primaryColor : UIColors.blueGray100,
                    borderRadius: BorderRadius.circular(
                      getHorizontalSize(
                        7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
