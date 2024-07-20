import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/Discussion.dart';
import 'package:munturai/model/Message.dart';
import 'package:munturai/screen/chat.dart';
import 'package:munturai/services/api.dart';

import '../model/Info.dart';
import '../model/User.dart';
var API=Api();

class widgetDiscussion extends StatefulWidget{
  Discussion? disc;
  User? user;
  widgetDiscussion({
    Key? key,
    required this.disc,
    required this.user,
  }):super(key: key);

  @override
  State<StatefulWidget> createState() => widgetDiscussion_(disc: disc, user: user);


}

class widgetDiscussion_ extends State<StatefulWidget>{
  Discussion? disc;
  User? user;
  widgetDiscussion_({
    Key? key,
    required this.disc,
    required this.user,
  });
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
            // var usr = await API.getUI_user().then((value) => value[0]);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatView(disc: disc)));
          },
      child:  Container(
        padding: getPadding(all: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: UIColors.boxFillColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child:
        Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: Center(
                  child:
                  disc!.photo!='none'?
                  Container(
                    margin: getMargin(all:8),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        color: UIColors.boxFillColor,
                        image:
                        DecorationImage(
                          image: NetworkImage('http://'+API.Api_+disc!.photo),
                          fit: BoxFit.cover,
                        )
                    ),
                  ):
                  Container(
                    margin: getMargin(all:8),
                    height: getVerticalSize(200,),
                    width: getVerticalSize(200,),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        color: UIColors.primaryAccent,
                        image:DecorationImage(
                            image: AssetImage(ImageConstant.logo_dark),
                            fit: BoxFit.contain
                        )
                    ),
                  ),
              ),
            ),
            Container(
              padding: getPadding(left: 10,right: 10),
              width: size.width-150,
              child:
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Text(disc!.title,style: AppStyle.txtInter(size: 22,weight: 'bold'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Text(getDate(disc!.last_date),style: AppStyle.txtInter(size: 18),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      )
    );
  }
  String getDate(num time){
    String duree='';
    double actual=DateTime.now().millisecondsSinceEpoch/1000;
    double periode = actual-time;
    if(periode/3600<1) {
        duree = (periode / 60).floor().toString() + ' min';
    }
    else if( periode/3600 <24)
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('kk:mm');
    else
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('dd/MM');
    return duree;
  }
}
