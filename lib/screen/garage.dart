import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/model/Garage.dart';
import 'package:munturai/services/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/colors/colors.dart';
import '../core/theming/app_style.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../model/Token.dart';
import '../model/User.dart';
import '../utils/divisionsFilter.dart';
import '../widgets/custom_image_view.dart';

bool light=false;
var API=Api();

Future<void> _launchUrl(Uri _url) async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
class GarageDetails extends StatefulWidget{
  Garage garage;
  GarageDetails({Key? key,required this.garage})
      : super(
    key: key,
  );
  @override
  State<GarageDetails> createState() => GarageDetails_(garage: garage);
}
class GarageDetails_ extends State<GarageDetails>{
  Garage garage;
  String setTitle='';
  bool showfilter=false;
  bool showimagesource=false;
  bool load_photo=false;
  double height=200;
  String photo='';
  int pageIndex=0;

  GarageDetails_({Key? key,required this.garage});

  @override
  void initState() {
    //getDatas();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).primaryColorDark,),
                onPressed: () {
                    Navigator.of(context).pop();
                  },
              );
        }) ,
        title:
          Padding(
            padding: getPadding(left: 100),
            child:
              Text("Infos Garage",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtInter(color: Colors.black, weight: 'regular', size: 24),
              ),
          ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          children: [
            Container(
              height: getVerticalSize(200,),
              width: BodyWidth(),
              decoration: BoxDecoration(
                  color: UIColors.boxFillColor,
                  image: (garage.photo!='none' && garage.photo!='None' && garage.photo.isNotEmpty)?
                  DecorationImage(
                    image: FileImage(File('/data/user/0/com.steps.davinci.muntuai/app_flutter/'+garage.photo.split('/').last)),
                    fit: BoxFit.cover,
                  ):DecorationImage(
                      image: AssetImage('assets/images/avatar.jpg'),
                      fit: BoxFit.cover
                  )
              ),
            ),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(garage.nom,style: AppStyle.txtInter(size: 24,weight: 'bold'),),
                  Spacer(),
                ],
              ),
            ),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child:
              Text(garage.description,style: AppStyle.txtInter(size: 18,weight: 'bold'),),
            ),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.location_on),
                  Spacer(),
                  Text(garage.ville+" , "+garage.pays,style: AppStyle.txtInter(size: 18,weight: 'bold'),),
                  Spacer(),
                ],
              ),
            ),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.email),
                  Spacer(),
                  Text(garage.email,style: AppStyle.txtInter(size: 18,weight: 'bold'),),
                  Spacer(),
                  GestureDetector(child: Text("Send mail",style: AppStyle.txtInter(size: 16,color: UIColors.primaryColor),),
                    onTap: (){
                      var url = Uri.parse('mailTo:'+garage.email);
                      launchUrl(url);

                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.phone),
                  Spacer(),
                  Text("Telephone 1 : ",style: AppStyle.txtInter(size: 16),),
                  Spacer(),
                  Text(garage.telephone1,style: AppStyle.txtInter(size: 18,weight: 'bold'),),
                  Spacer(),
                  (garage.telephone1!='none' && garage.telephone1!='')?
                  GestureDetector(child: Text("Call",style: AppStyle.txtInter(size: 18,color: UIColors.primaryColor),),
                  onTap: (){
                    if(garage.telephone1!='none' && garage.telephone1!='') {
                      var url = Uri.parse('phone:+237' + garage.telephone1);
                      launchUrl(url);
                    }
                  },
                  ):SizedBox(),
                ],
              ),
            ),
            Padding(
              padding: getPadding(top: 15,left: 16,right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.phone),
                  Spacer(),
                  Text("Telephone 2 : ",style: AppStyle.txtInter(size: 16),),
                  Spacer(),
                  Text(garage.telephone2,style: AppStyle.txtInter(size: 18,weight: 'bold'),),
                  Spacer(),
                  (garage.telephone2!='none' && garage.telephone2!='')?
                  GestureDetector(child: Text("Call",style: AppStyle.txtInter(size: 18,color: UIColors.primaryColor),),
                    onTap: (){
                      if(garage.telephone2!='none' && garage.telephone2!='') {
                        var url = Uri.parse('phone:+237' + garage.telephone2);
                        launchUrl(url);
                      }
                    },
                  ):SizedBox(),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

}


