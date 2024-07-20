import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/model/Discussion.dart';
import 'package:munturai/model/Garage.dart';
import 'package:munturai/model/Message.dart';
import 'package:munturai/screen/chat.dart';
import 'package:munturai/screen/garage.dart';
import 'package:munturai/services/api.dart';

import '../model/Info.dart';
import '../model/User.dart';
var API=Api();

class widgetGarage extends StatefulWidget{
  Garage garage;
  widgetGarage({
    Key? key,
    required this.garage,
  }):super(key: key);

  @override
  State<StatefulWidget> createState() => widgetGarage_(garage: garage);


}

class widgetGarage_ extends State<StatefulWidget>{
  Garage garage;
  widgetGarage_({
    Key? key,
    required this.garage,
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => GarageDetails(garage: garage)));
          },
      child:  Container(
        padding: getPadding(all: 2),
        width: double.infinity,
        decoration: BoxDecoration(
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
                  (garage.photo!='none' && garage.photo!='')?
                  Container(
                    margin: getMargin(all:8),
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image:
                        DecorationImage(
                          image: NetworkImage('http://'+API.Api_+garage.photo),
                          fit: BoxFit.cover,
                        )
                    ),
                  ):
                  Container(
                    margin: getMargin(all:8),
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      color: UIColors.primaryAccent,
                      borderRadius: BorderRadius.circular(10),
                      image:
                        DecorationImage(
                            image: AssetImage(ImageConstant.garage),
                            fit: BoxFit.contain
                        ),
                    ),
                  ),
              ),
            ),
            Container(
              padding: getPadding(left: 10,right: 10),
              width: size.width-122,
              child:
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Text(garage.nom,style: AppStyle.txtInter(size: 22,weight: 'bold'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                      Text(garage.description,style: AppStyle.txtInter(size: 18),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Text('Note : '+garage.rating.toString()+'/5',style: AppStyle.txtInter(size: 16,color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
            Spacer(),
            Text(garage.distance>1000?(garage.distance/1000).toString().substring(0,3)+' Km':(garage.distance).floor().toString().substring(0,3)+' m',style: AppStyle.txtInter(size: 18,weight: 'bold'),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      )
    );
  }
}
