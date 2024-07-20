import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/model/Message.dart';
import 'package:munturai/services/api.dart';
import 'package:munturai/widgets/widget_message2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';
import 'package:positioned_scroll_observer/positioned_scroll_observer.dart';

import '../core/colors/colors.dart';
import '../core/fonctions.dart';
import '../core/theming/app_style.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../model/Discussion.dart';
import '../model/User.dart';
import '../widgets/custom_image_view.dart';
import '../widgets/widget_message.dart';

bool light=false;
var API=Api();
class ChatView extends StatefulWidget{
  Discussion? disc;
  ChatView({Key? key,
    this.disc,
  })
      : super(
    key: key,
  );
  @override
  State<ChatView> createState() => Chat_(disc: disc);
}
class Chat_ extends State<ChatView>  with TickerProviderStateMixin{
  bool show_login=false;
  bool showimagesource=false;
  bool loadAnswer=false;
  bool showmedia=false;
  bool showSelectedMedia = false;
  bool viewSelectedMedia = false;
  bool show_answer=false;
  bool load_photo=false;
  bool show_militant=false;
  bool show_locality=false;
  bool loading=true;
  List<MessageWidget> allMessageWidgets = [];
  List<GlobalKey<MessageWidget_>> allMessageWidgetsStates = [];
  UIMessage answerTo=UIMessage();
  String media="";
  List<UIMessage> messages=[];
  PageController pageController = PageController();
  AutoScrollController scrollcontroller = AutoScrollController();
  final messagecontroller = TextEditingController();
  Discussion? disc;
  User? user;
  List<String> medias = [];
  int lastTime = 0;
  late Animation<double> animation;
  late AnimationController controller;

  late VideoPlayerController _controller;
  
  Chat_({Key? key,
    this.disc,
  });
  Timer loopCheck = Timer(Duration.zero, () { }) ;

  late final _observer = ScrollObserver.boxMulti(
    axis: Axis.vertical,
    itemCount: messages.length,
  );

  @override
  void initState() {
    messagecontroller.clear();
    load();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    animation = Tween<double>(begin: 0, end: 0.75).animate(controller)
      ..addListener(() {
        setState(() {
        });
      });
    controller.forward();
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    loopCheck = Timer(Duration.zero, () { }) ;
    messagecontroller.dispose();
    _controller.dispose();
    pageController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    if (showSelectedMedia == true) {
      showmedia=false;
      showSelectedMedia = false;
      setState(() {});
      _controller.dispose();
      return false;
    }
    else if (viewSelectedMedia == true) {
      showmedia=false;
      showSelectedMedia = false;
      viewSelectedMedia = false;
      setState(() {});
      _controller.dispose();
      return false;
    }
    else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leadingWidth: 48,
          leading: Builder(
              builder: (BuildContext context) {
                return
                Stack(
                  children: [
                    Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).primaryColorDark,),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ]
                    ),

                  ],
                );

              }) ,
          title:
            Center(
              child:
              Text(disc==null ? 'New Chat':disc!.title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtInter(color: Colors.black, weight: 'regular', size: 24),
              ),
            ),
          backgroundColor: Colors.grey[100],
          elevation: 0,
          actions: [
          ],
        ),
        body:
        Stack(
          children: [
            (showSelectedMedia  && viewSelectedMedia==false)?
            Container(
              width: BodyWidth(),
              height: BodyHeight(),
              decoration: (isImage(media.split('.').last) || isVideo(media.split('.').last))?
              BoxDecoration(
                color: Colors.black
              ): BoxDecoration(
                  color: Colors.white70
              ),
              child:
              isImage(media.split('.').last)?
              Image.file(
                  File(media),
                fit: BoxFit.contain,
                width: BodyWidth(),
                height: BodyHeight(),
              ):
              isVideo(media.split('.').last)?
              Stack(
                children: [
                  GestureDetector(
                    onTap:  (){
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child:
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(padding: getPadding(top: 200)),
                        Center(
                          child: Container(
                            width: BodyWidth(),
                            height: 300,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                        Padding(padding: getPadding(top: 100)),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child:
                          Container(
                            width: BodyWidth(),
                            padding: getPadding(left: 10,right: 10),
                            child: Row(
                              children: [
                                Text(getDuration(_controller.value.position.inMilliseconds),style: AppStyle.txtRoboto(size: 18,color: Colors.white),),
                                Flexible(
                                  child: VideoProgressIndicator(
                                    _controller,
                                    allowScrubbing: true,
                                    padding: EdgeInsets.all(8),
                                  ),
                                ),
                                Text(getDuration(_controller.value.duration.inMilliseconds),style: AppStyle.txtRoboto(size: 18,color: Colors.white),),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: (){
                          setState(() {
                          _controller.value.isPlaying
                          ? _controller.pause()
                              : _controller.play();
                          });
                      },
                      child: _controller.value.isPlaying ? SizedBox():Icon(Icons.play_circle,size: 60,color: Colors.white,),
                    ),
                  ),
                ],
              ):
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: getHorizontalSize(150),
                    height: getVerticalSize(150),
                    decoration: BoxDecoration(
                      color: UIColors.warningColor,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child:
                    Center(
                        child: Text(media.split('.').last,
                          style: AppStyle.txtInter(size: 24,
                            color: UIColors.primaryColor),)
                    ),
                  ),
                  Padding(padding: getPadding(top: 20)),
                  Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(media.split('/').last,
                          style: AppStyle.txtInter(size: 20,
                              color: UIColors.primaryColor),),
                      )
                  ),
                ],
              ),
            ):SizedBox(),
            (showSelectedMedia==false && viewSelectedMedia)?
            Container(
              width: BodyWidth(),
              height: BodyHeight(),
              decoration: (isImage(media.split('.').last) || isVideo(media.split('.').last))?
              BoxDecoration(
                  color: Colors.black
              ): BoxDecoration(
                  color: Colors.white70
              ),
              child:
                  PageView.builder(
                    controller: pageController,
                    reverse: false,
                    itemCount: medias.length,
                      itemBuilder: (context,index){
                      if(isImage(medias[index].split('.').last))
                        return
                        Image.file(
                          File(medias[index]),
                          fit: BoxFit.contain,
                          width: BodyWidth(),
                          height: BodyHeight(),
                        );
                      else {
                        VideoPlayerController videoController = new VideoPlayerController.file(File(medias[index]))
                          ..initialize().then((_) {
                            setState(() {});
                          });
                       return Stack(
                          children: [
                            GestureDetector(
                              onTap:  (){
                                setState(() {
                                  videoController.value.isPlaying
                                      ? videoController.pause()
                                      : videoController.play();
                                });
                              },
                              child: Center(
                                child: Container(
                                  width: BodyWidth(),
                                  height: 300,
                                  child: VideoPlayer(videoController),
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    videoController.value.isPlaying
                                        ? videoController.pause()
                                        : videoController.play();
                                  });
                                },
                                child: videoController.value.isPlaying ? SizedBox():Icon(Icons.play_circle,size: 60,color: Colors.white,),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child:
                              VideoProgressIndicator(
                                videoController,
                                allowScrubbing: true,
                                padding: EdgeInsets.all(8),
                              ),
                            )
                          ],
                        );
                      }
                  }),
            ):SizedBox(),
            (showSelectedMedia==false && viewSelectedMedia==false)?
            Container(
              height: BodyHeight()-110,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child:
              Column(
                children: [
                  MessageWidget2(
                    message: UIMessage(),
                    head: true,
                  ),
                  Container(
                    height: BodyHeight()-202,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.separated(
                      separatorBuilder: (context,i){
                        return Container(
                          height: getHorizontalSize(15),
                          width: double.infinity,
                        );
                      },
                      itemBuilder: (context,index){
                        return
                          MessageWidget2(
                            message: messages[index],
                            sender: messages[index].emetteur == user!.id,
                            head: false,
                          );
                      }, itemCount: messages.length,
                    ),
                  ),
                ],
              )
            ):SizedBox(),
            Align(
              alignment: Alignment.bottomCenter,
              child:
              AnimatedContainer(
                width:double.maxFinite,
                height: showimagesource ? 150 : 0 ,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    boxShadow: [BoxShadow()],
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                ),
                duration: const Duration(milliseconds: 600),
                curve: Curves.linear,
                child:
                Stack(
                  children: [
                    Padding(
                      padding: getPadding(top: 10,left: 10,right: 10),
                      child:
                      ListView(
                        children: [
                          Padding(padding: getPadding(top: 10)),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                showimagesource=false;
                              });
                              takeImage(ImageSource.gallery);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.image),
                                Padding(padding: getPadding(left: 8)),
                                Text('Gallerie',
                                  style: AppStyle.txtInter(size: 20),),
                                Spacer(),
                              ],
                            ),
                          ),
                          Padding(padding: getPadding(top: 30)),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                showimagesource=false;
                              });
                              chooseFile();
                            },
                            child:
                            Row(
                              children: [
                                Icon(Icons.file_present_sharp),
                                Padding(padding: getPadding(left: 8)),
                                Text('Document',
                                  style: AppStyle.txtInter(size: 20),),
                                Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child:
              Container(
                color: UIColors.primaryAccent,
                height: (show_answer?100:50)  + min(4,(messagecontroller.text.length ~/ 19).toInt())*8,
                child:
                SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      show_answer?
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: (){
                              //setState(() {});
                              scrollcontroller.scrollToIndex(getIndexOfmessage(answerTo.id), preferPosition: AutoScrollPosition.begin,duration: Duration(seconds: 1));
                              //scrollcontroller.highlight(getIndexOfmessage(answerTo.id));
                              allMessageWidgetsStates[getIndexOfmessage(answerTo.id)].currentState!.highlight();
                            },
                            child:
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child:
                              Container(
                                height: 37,
                                padding: getPadding(top: 5,left: 10,right: 10,bottom: 5),
                                decoration: BoxDecoration(
                                  color: UIColors.blueGray100,
                                  border: Border(top: BorderSide(color: UIColors.primaryColor,width: 4,)),
                                ),
                                child:
                                Row(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(answerTo.emetteur == user!.id? 'Vous': answerTo.emetteurName,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppStyle.txtInter(size: 16,color: UIColors.warningColor,weight: 'bold'),),
                                        Padding(padding: getPadding(left: 10)),
                                        Text(answerTo.contenu,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppStyle.txtInter(size: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child:
                            Padding(
                              padding: const EdgeInsets.only(top: 12,right: 16),
                              child: Row(
                                children: [
                                  Spacer(),
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        answerTo = UIMessage();
                                        show_answer=false;
                                      });
                                    },
                                    child:
                                    Icon(Icons.close,size: 24,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ):SizedBox(),
                      Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child:
                        Row(
                          children: [
                            showmedia?
                            SizedBox():
                            Transform.rotate(
                              angle: 70,
                              child:
                              IconButton(
                                icon: Icon(Icons.attach_file_outlined ,color: Theme.of(context).primaryColor,size: 30),
                                onPressed: () {
                                  showimagesource=!showimagesource;
                                  setState(() {});
                                },
                              ),
                            ),
                            showmedia?
                            SizedBox():
                            IconButton(
                              icon: Icon(Icons.camera_alt,color: Theme.of(context).primaryColor,size: 30),
                              onPressed: () {
                                takeImage(ImageSource.camera);
                                showmedia=true;
                                setState(() {});
                              },
                            ),
                            Container(
                              height: 40 + min(4,(messagecontroller.text.length ~/ 19).toInt())*8,
                              margin: getMargin(left: 10,top: showmedia?7: min(4,(messagecontroller.text.length ~/ 19)) >0 ?7:0),
                              decoration: BoxDecoration(
                                  color: UIColors.blueGray100,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child:
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 40 + min(4,(messagecontroller.text.length ~/ 19).toInt())*8,
                                    width: BodyWidth() - (showmedia ? 75:172),
                                    margin: getMargin(right: 10),
                                    decoration: BoxDecoration(
                                        color: UIColors.blueGray100,
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child:
                                    TextField(
                                      onChanged:(e){
                                        setState(() {});
                                      },
                                      controller: messagecontroller,
                                      style: AppStyle.txtInter(size: 20),
                                      cursorColor: UIColors.cursorColor,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: 'Message ...',
                                        fillColor: UIColors.edittextFillColor,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: getPadding(bottom: 20),
                                    child: IconButton(
                                      icon: Icon(CupertinoIcons.paperplane_fill,color: Theme.of(context).primaryColor,size: 24,),
                                      onPressed: () {
                                        setState(() {
                                          show_answer = false;
                                          loadAnswer=true;
                                        });
                                        sendQuestion();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child:
              Padding(
                padding: getPadding(bottom: 50.0),
                child: AnimatedContainer(
                  height: loadAnswer ? 50 : 0 ,
                  // height: 50,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.linear,
                  child:
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
                          color: animation.value < 0.25 ? UIColors.primaryColor : UIColors.blueGray100,
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
                          left: 8,
                        ),
                        decoration: BoxDecoration(
                          color: (animation.value >= 0.25 && animation.value <0.5) ? UIColors.primaryColor : UIColors.blueGray100,
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
                          left: 8,
                        ),
                        decoration: BoxDecoration(
                          color: (animation.value >=0.5) ? UIColors.primaryColor : UIColors.blueGray100,
                          borderRadius: BorderRadius.circular(
                            getHorizontalSize(
                              7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAvailableMedias() async {
    medias = [];
    for(var i=0;i<messages.length;i++){
      if( isImage(messages[i].media.split('.').last) &&  isVideo(messages[i].media.split('.').last) &&
      await File((await getApplicationDocumentsDirectory()).path+'/'+messages[i].media.split('/').last).exists()){
        medias.add((await getApplicationDocumentsDirectory()).path+'/'+messages[i].media.split('/').last);
      }
    }
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

  String getDuration(int time){
    return DateTime.fromMillisecondsSinceEpoch(time).format('mm:ss');
  }

  load() async{
    loading = false;
    user = await API.getUI_user().then((value) => value[0]);
    messages = await API.local_getMessagesFromDisc(disc!.id);
    // await fetchMessages();
    // if(mounted)
    //   loopCheck = Timer.periodic(Duration(seconds: 2), (timer) async{
    //     if(mounted){
    //       await fetchMessages();
    //     }
    //   }
    // );
    // else
    //   loopCheck = Timer(Duration.zero,(){});
  }

  takeImage(ImageSource imagesource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: imagesource);
    if (file != null) {
      media = file.path ?? '';
      showSelectedMedia=true;
      showSelectedMedia=true;
      showmedia=true;
      setState(() {
      });
    }
    else{
      media = '';
      showmedia=false;
    }
    setState(() {});
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

  int getIndexOfmessage(String id){
    for(var i=0;i<messages.length;i++){
      if(messages[i].id==id)
        return i;
    }
    return -1;
  }

  chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      media = result.files.single.path ?? '';
      if(isVideo(media.split('.').last))
        _controller = VideoPlayerController.file(File(media))
          ..initialize().then((_) {
            setState(() {});
          });
      _controller.addListener(() {
        setState(() {});
      });

      showSelectedMedia=true;
      showmedia=true;
      setState(() {
      });
    }
    else{
      showmedia=false;
    }
    setState(() {});
  }

  sendMessage() async {
    if(messagecontroller.text.isNotEmpty || media.isNotEmpty) {
      int time = (DateTime.now().millisecondsSinceEpoch /1000).floor();
      if(media.isNotEmpty){
        String newName='muntur'+time.toString()+'_'+user!.id.replaceAll(':', '').replaceAll('-', '') +'.'+media.split('.').last;
        File media_ = File(media);
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        File newFile = await media_.copy('$path'+'/'+newName);
        media=newFile.path;
      }
      UIMessage message = UIMessage(
        id: user!.id +':'+ time.toString(),
        temp_id: time.toString(),
        emetteur: user!.id,
        date_envoi: time,
        state: 'pending',
        contenu: (messagecontroller.text.isEmpty && (isVideo(media.split('.').last) || isImage(media.split('.').last))) ? media.split('/').last : messagecontroller.text.isEmpty ? 'none' :messagecontroller.text,
        disc_id: disc!.id,
        media: media.isEmpty ? 'none' : media,
        mediaName: media.isEmpty ? 'none' : media.split('.').last,
        answerTo: answerTo.id == 'auto' ? 'none' : answerTo.id,
      );
      disc!.last_date=time;
      disc!.last_writer=message.emetteur;
      disc!.last_message=message.contenu;
      if (disc!.id == 'auto') {
        disc!.id = message.emetteur +':'+time.toString();
        var body;
        API.local_insertDiscussion(disc!).then((value) async =>
        {
          API.createDiscussion(disc!.toJson()).then((resp) =>
          {
            if (resp.statusCode == 200){
              body = json.decode(resp.body)['data'] as Map,
              disc!.id = body['id'],
            }
          }),
          message.disc_id = disc!.id,
        });
        await API.local_insertMessage(message);
      }
      else{
        API.local_updateDiscussion(disc!);
        API.local_insertMessage(message);
      }
      messages.add(message);
      //print(messages.last.toJson());
      _observer.itemCount = messages.length;
      messagecontroller.clear();
      showSelectedMedia=false;
      showmedia=false;
      media = '';
      scrollcontroller.scrollToIndex(messages.length-1, preferPosition: AutoScrollPosition.end,duration: Duration(milliseconds: 1000));
      FocusScope.of(context).requestFocus(FocusNode());
      try{
        _controller.dispose();
      }
      on Exception catch (e){

      }
      setState(() {});
    }
  }

  sendQuestion() async {
    user = await API.getUI_user().then((value) => value[0]);
    dev.log("DEBUG : "+user!.id);
    if(messagecontroller.text.isNotEmpty || media.isNotEmpty) {
      int time = (DateTime.now().millisecondsSinceEpoch /1000).floor();
      if(media.isNotEmpty){
        String newName='muntur'+time.toString()+'_'+user!.id.replaceAll(':', '').replaceAll('-', '') +'.'+media.split('.').last;
        File media_ = File(media);
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        File newFile = await media_.copy('$path'+'/'+newName);
        media=newFile.path;
      }
      if(messages.length==0){
        disc = Discussion();
        disc!.id = user!.id +':'+time.toString();
      }
      UIMessage message = UIMessage(
        id: user!.id +':'+ time.toString(),
        temp_id: time.toString(),
        emetteur: user!.id,
        date_envoi: time,
        state: 'pending',
        contenu: (messagecontroller.text.isEmpty && (isVideo(media.split('.').last) || isImage(media.split('.').last))) ? media.split('/').last : messagecontroller.text.isEmpty ? 'none' :messagecontroller.text,
        disc_id: disc!.id,
        media: media.isEmpty ? 'none' : media,
        mediaName: media.isEmpty ? 'none' : media.split('.').last,
        answerTo: answerTo.id == 'auto' ? 'none' : answerTo.id,
      );
      if (messages.length==0) {
        disc!.id = message.emetteur +':'+time.toString();
        disc!.title = messagecontroller.text.length>30? messagecontroller.text.substring(0,30):messagecontroller.text;
        disc!.last_date=time;
        API.local_insertDiscussion(disc!).then((value) async =>
        {
          message.disc_id = disc!.id,
        });
        await API.local_insertMessage(message);
      }
      else{
        disc!.last_writer=message.emetteur;
        disc!.last_message=message.contenu;
        disc!.last_date=time;
        API.local_updateDiscussion(disc!);
        API.local_insertMessage(message);
      }
      messages.add(message);
      _observer.itemCount = messages.length;
      messagecontroller.clear();
      showSelectedMedia=false;
      showmedia=false;
      media = '';
      // try{
      //   _controller.dispose();
      // }
      // on Exception catch (e){
      // }
      var aiResp=UIMessage();
      await API.askAI(message).then((response) => {
        if(response.statusCode==200){
          aiResp = UIMessage.fromJson(json.decode(response.body)['data']),
          messages.add(aiResp),
          disc!.last_writer=aiResp.emetteur,
          disc!.last_message=aiResp.contenu,
          disc!.last_date=aiResp.date_envoi,
          API.local_updateDiscussion(disc!),
          API.local_insertMessage(aiResp),
        }
        else{
          dev.log('Muntur DEBUG: '+response.body),
        },

        setState(() {
          loadAnswer=false;
        })
      });
      scrollcontroller.scrollToIndex(messages.length-1, preferPosition: AutoScrollPosition.end,duration: Duration(milliseconds: 1000));
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        loadAnswer=false;
      });
    }
  }
  bool first=false;



  Future<void> fetchMessages() async {
    var different = false;
    var is_in = false;
    var results;
    var done;

    List<UIMessage> messages1 = [];
    bool is_in1 = false;
    var idx=0;
    var selfUser=await API.getUI_user().then((value) => value[0]);
    List<UIMessage> updatedListMessages;
      await API.getMessagesFromDisc(disc_id: disc!.id, time: (await API.getLastTimeDisc(disc!.id)+12)).then((response) async =>
      {
        if (response.statusCode == 200)
          {
            results = json.decode(response.body),
            //print(results),
            done = results['data'],
            for (var i = 0; i < done.length; i++)
              {
                messages1.add(UIMessage(
                  id: done[i]["id"],
                  disc_id: done[i]["disc_id"],
                  temp_id: done[i]["temp_id"],
                  emetteur: done[i]["emetteur"],
                  emetteurName: done[i]["emetteurName"],
                  recepteur: done[i]["recepteur"],
                  contenu: done[i]["contenu"],
                  media: done[i]["media"],
                  answerTo: done[i]["answerTo"],
                  mediaName: done[i]["mediaName"],
                  state: done[i]["state"],
                  date_envoi: done[i]["creation_date"] ?? 0,
                )),
              },
            updatedListMessages = await API.local_getMessage().then((value) => value),
            for (var i = 0; i < messages1.length; i++)
              {
                if (updatedListMessages.isEmpty)
                  {
                    await API.local_insertMessage(messages1[i]),
                  }
                else
                  {
                    is_in1 = false,
                    idx = -1,
                    for (var ie = 0; ie < updatedListMessages.length; ie++)
                      {
                        if (updatedListMessages[ie].id == messages1[i].id || updatedListMessages[ie].id == messages1[i].temp_id )
                          {
                            is_in1 = true,
                            idx = ie,
                          }
                      },
                    if (is_in1)
                      {
                        if(updatedListMessages[idx].id == messages1[i].temp_id)
                          await API.local_updateMessage(messages1[i], id: updatedListMessages[idx].id),
                        if( messages1[i].emetteur != selfUser.id && updatedListMessages[idx].announced == 'no'){
                          messages1[i].announced = 'yes',
                          await API.local_updateMessage(messages1[i])
                        },
                        if(updatedListMessages[idx].state != 'delete' && updatedListMessages[idx].state != messages1[i].state)
                          await API.local_updateMessage(messages1[i])
                      }
                    else
                      {
                        await API.local_insertMessage(messages1[i]),
                      }
                  }
              },
          }
      });
      await API.local_getMessagesFromDisc(disc!.id).then((list) =>
      {
        if(messages.isNotEmpty){
          different = true,
          for(var i = 0; i < list.length; i++){
            if(list[i].date_envoi > messages.last.date_envoi){
              messages.add(list[i]),
              setState(() {}),
            }
          },
        }
        else{
          messages = list,
          setState(() {}),
          scrollcontroller.scrollToIndex(messages.length-1, preferPosition: AutoScrollPosition.end,duration: Duration(milliseconds: 1000)),
          },
      });
      disc!.last_check = DateTime.now().millisecondsSinceEpoch~/1000;
      await API.local_updateDiscussion(disc!);
  }


}