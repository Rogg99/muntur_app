import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:munturai/services/api.dart';

import '../core/colors/colors.dart';
import '../core/theming/app_style.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../model/Info.dart';
import '../model/User.dart';
import '../widgets/custom_image_view.dart';
import '../widgets/widget_info.dart';

bool light=false;
var API=Api();
class Infos extends StatefulWidget{
  Infos({Key? key})
      : super(
    key: key,
  );
  @override
  State<Infos> createState() => Infos_();
}
class Infos_ extends State<Infos>  with TickerProviderStateMixin{
  bool isLoading=true;
  List<Info> infos = [];
  @override
  void initState() {
    fetchInfos();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).primaryColorDark,),
                onPressed: () { Navigator.of(context).pop(); },
              );
            }) ,
        title:
        Padding(
          padding: getPadding(left: 100),
          child:
          Text("A la une",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppStyle.txtInter(color: Colors.black, weight: 'regular', size: 24),
          ),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: isLoading ?
      Center(
          child: CircularProgressIndicator(
            color: UIColors.primaryColor,
          )):
      Container(
        padding: getPadding(left: 16,right: 16),
        child:
        ListView.separated(
          separatorBuilder: (context,i){
            return Padding(padding: getPadding(top: 15));
          },
          itemBuilder: (context,index){
            return
              widgetInfo(
                info:infos[index]
              );
          }, itemCount: infos.length,
        )
      ),
    );
  }

  fetchInfos() async {
    print('fetching new infos');
    List<Info> infos_ = [];
    var datas=[];
    var results;
    await API.getInfos().then((response) => {
      if (response.statusCode == 200)
        {
          results = json.decode(response.body),
          datas = results['data'],
          for (var i = 0; i < datas.length; i++)
            {
              infos_.add(Info(
                id: datas[i]["id"],
                path: datas[i]['path'],
                statut: datas[i]['statut'],
                image: 'http://'+API.Api_+'/api/muntur'+datas[i]['image'],
                title: datas[i]['title'],
                time: datas[i]['time'],
              )),
            },
        },
        infos = infos_,
        isLoading = false,
        setState(() {})
    });
  }

}