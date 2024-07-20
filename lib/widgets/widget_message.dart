
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
class MessageWidget extends StatefulWidget{
  GlobalKey _containerKey = GlobalKey();
  GlobalKey? idKey;
  UIMessage? message;
  UIMessage answerTo;
  int answerIndex;
  Discussion? disc;
  Chat_ chatView;
  User? usr;
  bool show_time;
  MessageWidget({
    Key? key,
    required this.idKey,
    required this.message,
    required this.answerTo,
    this.answerIndex = 0,
    required this.disc,
    required this.usr,
    required this.chatView,
    this.show_time=false,
  }) : super(
    key: key,
  );

  @override
  State<MessageWidget> createState() => MessageWidget_(key:idKey,disc: disc,usr: usr,message: message,answerTo: answerTo,answer_index: answerIndex,chatView: chatView);
}

class MessageWidget_ extends State<MessageWidget> {
  GlobalKey _containerKey = GlobalKey();
  Key? key;
  UIMessage? message;
  UIMessage answerTo;
  int answer_index;
  Discussion? disc;
  Chat_ chatView;
  User? usr;
  bool show_time;
  bool load_photo = false;
  bool media_isDownloaded = false;
  String size_type='12,5 MB APK';
  late VideoPlayerController _controller;

  MessageWidget_({
    required this.message,
    required this.disc,
    required this.chatView,
    required this.usr,
    this.show_time = false,
    this.answer_index = 0,
    required this.key ,
    required this.answerTo,
  });

  Color _color = Colors.transparent;
  Timer timer=Timer(Duration.zero, () { });

  @override
  void initState() {
    _controller = VideoPlayerController.file(File(''))..initialize();

    if(isVideo(message!.media.split('.').last)){
      if(message!.media.startsWith('/data/'))
      _controller = VideoPlayerController.file(File(message!.media))
        ..initialize().then((_) {
          setState(() {});
        });
      else{
        _controller = VideoPlayerController.networkUrl(Uri(
            scheme: 'http',
            host: 'muntur.steps4u.net',
            path: 'api/muntur/media/'+message!.media))
          ..initialize().then((_) {
            setState(() {});
          });
      }
    }
    if(message!.emetteur == usr!.id)
      syncMessage();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    timer = Timer(Duration.zero, () { });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool sending = (usr!.id==message!.emetteur);
    bool show_name = (disc!.type=='forum');
    int messagelength = message!.contenu.length >= 36 ? 36 : message!.contenu.length;
    int answerlength = answerTo.contenu.length >= 36 ? 36 : message!.contenu.length;
    double proportion=(((MediaQuery.of(context).size.width) * 0.6))/(36);
    if(message!.answerTo!='none'){
      messagelength = max(messagelength, answerlength);
    }
    double messageSize = (messagelength*proportion)+50;
    //print(messagelength);
    return
      SwipeTo(
        key: key,
        onRightSwipe: (details) {
          chatView.answerTo = message!;
          chatView.show_answer = true;
          chatView.setState(() {});
        },
        onLeftSwipe: (details) {
          chatView.answerTo = message!;
          chatView.show_answer = true;
          chatView.setState(() {});
        },
        child:
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
                  Row(
                    mainAxisAlignment: sending ? MainAxisAlignment.end:MainAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: (MediaQuery.of(context).size.width) * 0.6, minWidth: 60),
                        child:
                        Container(
                          padding: getPadding(left: 5, top: 5, right: 5, bottom: 5,),
                          margin: getMargin(right: 5, left: 5,),
                          width: (message!.mediaName!='none' || message!.media!='none')?(MediaQuery.of(context).size.width) * 0.6:messageSize,
                          decoration: sending
                              ? BoxDecoration(borderRadius: BorderRadius.circular(10),color: UIColors.blueGray100)
                              : BoxDecoration(borderRadius: BorderRadius.circular(10),color: UIColors.boxFillColor),
                          child:
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              (show_name && !sending)?
                              Text(
                                message!.emetteur,
                                maxLines: null,
                                style: AppStyle.txtArimoHebrewSubset(weight: 'bold').copyWith(
                                  letterSpacing: getHorizontalSize(
                                    0.26,
                                  ),
                                ),
                              ):SizedBox(),
                              message!.answerTo!='none'?
                              GestureDetector(
                                onTap: (){
                                  chatView.scrollcontroller.scrollToIndex(answer_index, preferPosition: AutoScrollPosition.begin,duration: Duration(seconds: 1));
                                  //(chatView.allMessageWidgets[answer_index]._containerKey.currentState as MessageWidget_).highlight();
                                  chatView.allMessageWidgetsStates[answer_index].currentState!.highlight();
                                },
                                child: Container(
                                  height: 36,
                                  padding: getPadding(top: 5,left: 10,right: 10,bottom: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    border: Border(top: BorderSide(color: UIColors.primaryColor,width: 4,)),
                                  ),
                                  child:
                                  ListView(
                                    children: [
                                      Text(answerTo.emetteur == usr!.id? 'Vous': answerTo.emetteurName,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyle.txtInter(size: 16,color: UIColors.warningColor,weight: 'bold'),),
                                      Padding(padding: getPadding(left: 10)),
                                      Text(answerTo.contenu,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyle.txtInter(size: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ):SizedBox(),
                              (message!.media!='none' && (isImage(message!.media.split('.').last)
                                  || isVideo(message!.media.split('.').last)))?
                              GestureDetector(
                                onTap: () async {
                                  if(await File('/data/user/0/com.steps.davinci.muntuai/app_flutter/'+message!.media.split('/').last).exists()){
                                    await chatView.getAvailableMedias();
                                    chatView.setState(() {});
                                    var index=0;
                                    for(var i=0;i<chatView.medias.length;i++){
                                      if(chatView.medias[i].split('/').last == message!.media.split('/').last){
                                        index=i;
                                        break;
                                      }
                                    }
                                    chatView.pageController.animateToPage(index, duration: Duration.zero, curve: Curves.linear);
                                    chatView.viewSelectedMedia=true;
                                    chatView.setState(() {});
                                  }
                                },
                                child:
                                isImage(message!.media.split('.').last)?
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  height: getVerticalSize(330,),
                                  width: (MediaQuery.of(context).size.width) * 0.6,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: UIColors.boxFillColor,
                                      image:(media_isDownloaded || sending)?
                                      DecorationImage(
                                          image: FileImage(File('/data/user/0/com.steps.davinci.muntuai/app_flutter/'+message!.media.split('/').last)),
                                          fit: BoxFit.fill
                                      ):DecorationImage(
                                          image: AssetImage('assets/images/empty.jpg'),
                                          fit: BoxFit.fill
                                      )
                                  ),
                                  child:
                                  (media_isDownloaded==false && sending==false)?
                                  Center(
                                    child:
                                    GestureDetector(
                                      onTap: (){
                                        load_photo = true;
                                        setState(() {});
                                        downloadMedia();
                                      },
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.download,),
                                            Text('Télécharger',style: AppStyle.txtInter(color: UIColors.primaryColor),)
                                          ],
                                        ),
                                      ),
                                    ),
                                  )    :
                                  (load_photo && sending==false)?
                                  Center(
                                    child:
                                    Center(
                                        child: CircularProgressIndicator(
                                          color: UIColors.primaryColor,
                                        )),
                                  ): SizedBox(),
                                ):
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  height: getVerticalSize(330,),
                                  width: (MediaQuery.of(context).size.width) * 0.6,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: UIColors.boxFillColor,
                                  ),
                                  child:
                                      Stack(
                                        children: [
                                          VideoPlayer(
                                            _controller
                                          ),
                                          (media_isDownloaded==false && sending==false)?
                                          Center(
                                            child:
                                            GestureDetector(
                                              onTap: (){
                                                load_photo = true;
                                                setState(() {});
                                                downloadMedia();
                                              },
                                              child: Center(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.download,),
                                                    Text('Télécharger',style: AppStyle.txtInter(color: UIColors.primaryColor),)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )    :
                                          (load_photo && sending==false)?
                                          Center(
                                            child:
                                            Center(
                                                child: CircularProgressIndicator(
                                                  color: UIColors.primaryColor,
                                                )),
                                          ): SizedBox(),
                                        ],
                                      )
                                ),
                              ):SizedBox(),
                              (message!.mediaName!='none' && isImage(message!.media.split('.').last)==false
                                  && isVideo(message!.media.split('.').last)==false)?
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.all(5),
                                height: getVerticalSize(70,),
                                width: (MediaQuery.of(context).size.width) * 0.6,
                                child:
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 45,
                                      margin: getMargin(right:10 ,left :5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          color: UIColors.warningColor,
                                      ),
                                      child:
                                      (media_isDownloaded==false && sending==false)?
                                      Center(
                                        child:
                                        GestureDetector(
                                          onTap: (){
                                            load_photo = true;
                                            setState(() {});
                                            downloadMedia();
                                          },
                                          child:
                                          Icon(Icons.download,),
                                        ),
                                      ):
                                      (load_photo  && sending==false)?
                                      Center(
                                        child:
                                        Center(
                                            child: CircularProgressIndicator(
                                              color: UIColors.primaryColor,
                                            )),
                                      ): Icon(Icons.note,),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if(await File((await getApplicationDocumentsDirectory()).path+'/'+message!.media.split('/').last).exists()){
                                        OpenFile.open((await getApplicationDocumentsDirectory()).path+'/'+message!.media.split('/').last);
                                        }
                                      },
                                      child: Container(
                                        width:  (MediaQuery.of(context).size.width) * 0.6 - 85,
                                        child:
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child:
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  message!.media.split('/').last +'',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.clip,
                                                  style: AppStyle.txtInter(size: 16).copyWith(
                                                    letterSpacing: getHorizontalSize(
                                                      0.26,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                               message!.mediaSize +'  '+message!.mediaName.split('.').last,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppStyle.txtInter(size: 14,color:Colors.black12).copyWith(
                                                  letterSpacing: getHorizontalSize(
                                                    0.26,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ):SizedBox(),
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
                                        style: AppStyle.txtStream(size: 18)
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child:
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      getDate(message!.date_envoi ,hh_mm: true),
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyle.txtArimoHebrewSubset(color: Colors.blueGrey).copyWith(
                                        letterSpacing: getHorizontalSize(
                                          0.28,
                                        ),
                                      ),
                                    ),
                                    sending ?
                                    Padding(padding: getPadding(left: 10)):
                                    SizedBox(),
                                    sending ?
                                    //message!.state=='read'? Icon(Icons.done_all,color: Colors.lightBlue,size: 12):
                                    //message!.state=='received'? Icon(Icons.done_all,color: Colors.blueGrey,size: 12):
                                    (message!.state=='sent' || message!.state=='received' || message!.state=='read')? Icon(Icons.check,size: 12):
                                    message!.state=='failed'? Icon(Icons.warning,color: Colors.red,size: 12):
                                    Icon(Icons.access_time,size: 12,):SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
        ),
      );

  }

  bool isImage(String extension){
    var image_extensions=['JPG', 'PNG', 'GIF', 'WebP', 'BMP','WBMP'];
    //print(extension);
    for(var i=0;i<image_extensions.length;i++)
      if(extension.toLowerCase() == image_extensions[i].toLowerCase())
        return true;
    return false;
  }

  bool isVideo(String extension){
    var image_extensions=['MP4', 'avi', 'ogg'];
    for(var i=0;i<image_extensions.length;i++)
      if(extension == image_extensions[i].toLowerCase())
        return true;
    return false;
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


  double getWidth() {
    final RenderBox renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox;
    return renderBox.size.width;
  }

  downloadMedia() async {
      await API.downloadMedia(message!.media).then((file) async =>
      {
        media_isDownloaded=false,
        if(file.path!='')
          media_isDownloaded = true,
        load_photo=false,
        setState(() {}),
      });
  }

  Future<bool> mediaIsinLocal(String file) async {
    final directory = await getApplicationDocumentsDirectory();
    return await File(directory.path + '/' +file.split('/').last).exists();
  }

  syncMessage() async{
    if(message!.emetteur==usr!.id && message!.state!='read' && message!.state!='delete')
      timer = Timer.periodic(Duration(seconds: 5), (t) async{
        var prev=message!.state;
        if(message!.state =='pending'){
          //print('syncing message ...');
            await API.createMessage(message!).then((response) async => {
              if(response.statusCode==200){
                message!.state = 'sent',
                API.local_updateMessage(message!),
              }
              else{
                print(await response.body.toString()),
              },
              setState(() {})
            });
        }
        /*
        else{
          await API.getMessage(message!.id).then((resp) async => {
            if(message!.contenu=='kool')
              print(resp.body),
            if (resp.statusCode==200){
              message!.state == (json.decode(resp.body)['data'] as Map)['state'],
              if (!mounted) {
              timer.cancel(),
              } else {
              setState(() {}),
              },
              await API.local_updateMessage(message!),
            }
          });
        }
        */
      });
    else{
      timer = Timer(Duration.zero, () { });
    }
  }

  Future<void> highlight() async {
    _color = Color.fromRGBO(241,145,1, 0.5);
    setState(() {});
    await Timer(Duration(seconds: 2), () {
      _color = Colors.transparent;
      setState(() {});
    });
  }
}
