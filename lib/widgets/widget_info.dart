import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/screen/infoView.dart';
import 'package:munturai/services/api.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/fonctions.dart';
import '../model/Info.dart';
var API=Api();

class  widgetInfo extends StatefulWidget{
  Info? info;
  bool clickable;
  widgetInfo({
    Key? key,
    required this.info,
    this.clickable=true,
  }):super(key: key);
  @override
  State<widgetInfo> createState() => widgetInfo_(info: info,clickable: clickable);
}

class widgetInfo_ extends State<widgetInfo>{
  Info? info;
  bool clickable;
  widgetInfo_({
    Key? key,
    required this.info,
    this.clickable=true,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        /*
        Uri url = Uri.parse(info!.path);
        launchUrlString(url.toString(),
            mode:LaunchMode.inAppWebView);
         */
        if (clickable)
          Navigator.of(context).push( MaterialPageRoute(builder: (context) => InfoView(info: info)));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white38,
        ),
        child:
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(info!.title,style: AppStyle.txtRoboto(size: 20,weight: 'bold'),),
            ),
            Padding(padding: getPadding(top: 5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(info!.contenu!='none'?info!.contenu:'',style: AppStyle.txtRoboto(size: 20),
              textAlign: TextAlign.left,
              ),
            ),
            Padding(padding: getPadding(top: 15)),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image:info!.image.startsWith('http')? DecorationImage(
                    image: NetworkImage(info!.image),
                    fit: BoxFit.cover
                ):DecorationImage(
                    image: AssetImage(info!.image),
                    fit: BoxFit.cover
                )
              ),
            ),
            Padding(padding: getPadding(top: 8)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
              child: Row(
                children: [
                  Icon(Icons.timelapse),
                  Padding(padding: getPadding(left: 5)),
                  Text(getDuree(info!.time.toDouble()),style: AppStyle.txtRoboto(size: 18),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  Spacer(),
                  info!.liked!='no'?
                  GestureDetector(
                    child: Icon(Icons.favorite,color: Colors.red,),
                    onTap: (){
                      info!.liked='no';
                      info!.likes-=1;
                      setState(() {});
                      //unlike();
                    },
                  ):
                  GestureDetector(
                    child: Icon(Icons.favorite_border),
                    onTap: (){
                      info!.liked='yes';
                      info!.likes+=1;
                      setState(() {});
                      //like();
                    },
                  ),
                  Text(info!.likes.toString(),style: AppStyle.txtRoboto(size: 18),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  Padding(padding: getPadding(left: 20)),
                  Icon(Icons.messenger_outline),
                  GestureDetector(
                      onTap: (){
                        if (clickable)
                        Navigator.of(context).push( MaterialPageRoute(builder: (context) => InfoView(info: info,keyboardFocus: true,)));
                      },
                      child: Text(info!.comments.toString(),style: AppStyle.txtRoboto(size: 18),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                  Padding(padding: getPadding(left: 20)),
                  GestureDetector(
                    child: Icon(Icons.share),
                    onTap: (){
                      print('sharing');
                      Share.share('muntur: Je partage avec vous l\'info '+info!.path);
                    },
                  ),
                  Padding(padding: getPadding(left: 10)),
                ],
              ),
            ),
          ],

        ),
      ),
    );
  }

  String getDuree(double time){
    String duree='';
    double actual=DateTime.now().millisecondsSinceEpoch/1000;
    double periode = actual-time;
    if(periode/3600<1)
      duree = (periode/60).floor().toString() + 'min';
    else if(periode/3600<24)
      duree = (periode/3600).floor().toString() + 'h';
    else
      duree = (periode/(3600*24)).floor().toString() + 'j';
    return duree;
  }

  like()async{
    var user = await API.getUI_user().then((value) => value[0]);
    await API.like(json.encode({
      'user': user.id,
      'info': info!.id
    })).then((response) => {
      if(response.statusCode==200){
        info!.liked = (json.decode(response.body)['data'] as Map)['id']
      }
      else{
        print(response.body)
      },
      setState((){})
    });
  }

  unlike()async{
    await API.unLike(info!.liked).then((response) => {
      if(response.statusCode==200){
        info!.liked = 'no'
      }
      else{
        print(response.body)
      },
      setState((){})
    });
  }


}
