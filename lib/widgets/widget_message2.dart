
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/model/Message.dart';
import 'package:munturai/screen/chat.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:video_player/video_player.dart';

import '../core/theming/app_style.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../model/Discussion.dart';
import '../model/User.dart';
import '../services/api.dart';

var API=Api();
class MessageWidget2 extends StatefulWidget{
  UIMessage? message;
  bool sender;
  bool head;
  MessageWidget2({
    Key? key,
    required this.message,
    this.sender = true,
    this.head = false,
  }) : super(
    key: key,
  );

  @override
  State<MessageWidget2> createState() => MessageWidget2_(message: message,sender: sender,head:head);
}

class MessageWidget2_ extends State<MessageWidget2> {
  UIMessage? message;
  bool sender;
  bool head;

  MessageWidget2_({
    required this.message,
    required this.sender,
    required this.head,
  });

  Color _color = Colors.transparent;
  Timer timer=Timer(Duration.zero, () { });

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int messagelength = message!.contenu.length >= 36 ? 36 : message!.contenu.length;
    double proportion=(((MediaQuery.of(context).size.width) * 0.6))/(36);
    double messageSize = (messagelength*proportion)+50;
    //print(messagelength);
    return
      AnimatedContainer(
        // Provide an optional curve to make the animation feel smoother.
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          color: _color,
        ),
        child: Padding(
          padding: getPadding(
            top: 14,
          ),
          child:
          head?
            Container(
            padding: getPadding(
              top: 12,
              bottom: 12,
            ),
            width: BodyWidth()-40,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
            ),
            child:
            Padding(
              padding:
              getPadding(
                left: 38,
                right: 38,
                top: 3,
                bottom: 4,
              ),
              child: Text(
                "Start a new discussion with Muntur AI,Ask me any question you want !",
                maxLines: null,
                textAlign: TextAlign.center,
                style: AppStyle.txtInter(size: 20,color: Colors.grey),
              ),
            ),
          ):
            Row(
                mainAxisAlignment: sender ? MainAxisAlignment.end:MainAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: (MediaQuery.of(context).size.width) * 0.7, minWidth: 60),
                    child:
                    Container(
                      padding: getPadding(left: 5, top: 5, right: 5, bottom: 5,),
                      margin: getMargin(right: 5, left: 5,),
                      width: messageSize,
                      decoration: sender
                          ? BoxDecoration(borderRadius: BorderRadius.circular(10),color: UIColors.blueGray100)
                          : BoxDecoration(borderRadius: BorderRadius.circular(10),color: UIColors.boxFillColor),
                      child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onLongPress: (){
                              Clipboard.setData(ClipboardData(text: message!.contenu))
                                  .then((value) { //only if ->
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('message copié dans le presse papier'),
                                ));}); // -> show a notification
                            },
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                child: Text(
                                    message!.contenu,
                                    maxLines: null,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtPoppins(size: 20)
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ),
      );

  }

  String getDate(num time,{bool hh_mm=false,bool yy_mm=false}){
    if(hh_mm)
      return DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('kk:mm');
    if(yy_mm){
      var days=['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
      var months=['Janvier','Fevrier','Mars','Avril','Mai','Juin','Juillet','Aout'
        ,'Septembre','Octobre','Novembre','Decembre'];
      String day = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).day.toString();
      String dayCalendar = days[DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).weekday-1];
      String month = months[DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).month-1];
      String year = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).year.toString();
      String date= dayCalendar+', '+day+' '+month+' '+year;
      return date;
    }
    String duree='';
    double actual=DateTime.now().millisecondsSinceEpoch/1000;
    double periode = actual-time;
    if(periode/3600<1)
      duree = (periode/60).floor().toString() + 'min';
    else if(periode/3600<24)
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('kk:mm');
    else
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('MM/dd');
    return duree;
  }



}
