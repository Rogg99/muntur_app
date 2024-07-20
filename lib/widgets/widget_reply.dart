import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/services/api.dart';
import 'package:munturai/widgets/widget_comment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/colors/colors.dart';
import '../core/fonctions.dart';
import '../model/Comment.dart';
import '../screen/infoView.dart';
var API=Api();

class  widgetReply extends StatefulWidget{
  Comment? info;
  widgetComment_? parent;
  widgetReply({
    Key? key,
    required this.info,
    required this.parent,
  }):super(key: key);
  @override
  State<widgetReply> createState() => widgetReply_(info: info,parent: parent);
}

class widgetReply_ extends State<widgetReply>{
  Comment? info;
  widgetComment_? parent;
  widgetReply_({
    Key? key,
    required this.info,
    required this.parent,
  });
  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: getPadding(top: 15),
        width: double.infinity,
        child:
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                  Padding(padding: getPadding(left: 25)),
                  Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      child: Center(
                          child:
                          info!.userPhoto!='none'?
                          Container(
                            margin: getMargin(all:8),
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1000),
                                color: UIColors.boxFillColor,
                                image:
                                DecorationImage(
                                  image: NetworkImage('http://muntur.steps4u.net/api/muntur'+info!.userPhoto),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ):
                          Icon(Icons.account_circle_rounded,size: 32,color: Colors.grey,)
                      ),
                  ),
                  Container(
                    padding: getPadding(left: 5, top: 5, right: 5, bottom: 5,),
                    margin: getMargin(right: 5, left: 5,),
                    width: ((MediaQuery.of(context).size.width) * 0.8) - 25,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: UIColors.blueGray100),
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              info!.userName + ' > '+info!.replyUserName,
                              maxLines: 1,
                              style: AppStyle.txtStream(size: 18,weight: 'bold'),
                            ),
                          ],
                        ),
                        (info!.image!='' && info!.image.toLowerCase()!='none')?
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image:DecorationImage(
                                  image: NetworkImage(info!.image),
                                  fit: BoxFit.cover
                              )
                          ),
                        ):SizedBox(),
                        GestureDetector(
                          onLongPress: (){
                            Clipboard.setData(ClipboardData(text: info!.contenu))
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
                                  info!.contenu,
                                  maxLines: null,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtStream(size: 18)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Padding(padding: getPadding(top: 5)),
            Padding(
              padding: getPadding(left: 32),
              child: Row(
                children: [
                  //Icon(Icons.timelapse,size: 18,),
                  Padding(padding: getPadding(left: 21 + 20)),
                  Text(getDuree(info!.time.toDouble()),style: AppStyle.txtRoboto(size: 18),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  Padding(padding: getPadding(left: 30)),
                  GestureDetector(child: Text('Répondre',style: AppStyle.txtRoboto(size: 18),maxLines: 2,overflow: TextOverflow.ellipsis,),
                  onTap: (){
                    parent!.parent!.linealComment = parent!;
                    parent!.parent!.replyTo.lineal = parent!.info!.id;
                    parent!.parent!.replyTo.replyTo = info!.id;
                    parent!.parent!.replyTo.userName = info!.userName;
                    parent!.parent!.replyTo.userId = info!.userId;
                    parent!.parent!.show_answer = true;
                    parent!.parent!.showkeyboard();
                    parent!.parent!.linealComment = parent!;
                    parent!.parent!.setState(() {});
                  },),
                  Spacer(),
                  Text(info!.likes.toString(),style: AppStyle.txtRoboto(size: 18),maxLines: 2,overflow: TextOverflow.ellipsis,),
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
                  Padding(padding: getPadding(left: 10)),
                ],
              ),
            ),
            Padding(padding: getPadding(top: 10)),
          ],

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
    duree = DateTime.fromMillisecondsSinceEpoch(time.toInt()*1000).format('dd-MM-yy');
      //duree = (periode/(3600*24)).floor().toString() + 'j';
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
