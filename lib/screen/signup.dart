import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/services/api.dart';

import '../core/colors/colors.dart';
import '../core/fonctions.dart';
import '../model/Token.dart';
import '../model/User.dart';
import '../utils/divisionsFilter.dart';
import 'home.dart';

/// Flutter code sample for [PageView].




class Signup extends StatefulWidget {
  const Signup({Key? key})
      : super(
    key: key,
  );

  @override
  State<Signup> createState() => Signup_();
}

final API=Api();
class Signup_ extends State<Signup> {
  bool sexe=false,privacyPolicy=false,
      show_loading=false;
  bool loading_datas=true;
  bool sympathisant=false;
  String photo='';
  int pageIndex=0;
  String selectedRegion = '';
  String selectedDepartement = '';
  String selectedDepartementOrg = '';
  String selectedCommune = '';

  List<String> allPays = countries_fr;
  List<String> allDepartements = alldeps();
  String selectedPays = 'Cameroun';

  List<String> emptyList=['Aucun'];
  List<String> viewableCommuneList=[];
  List<String> viewableRegionList = regions;
  List<String> viewableDeptList=[];
  List<String> allPartis=['Non       ','RDPC','MRC','UPC','PCRN','SDF','UDC','CPP','MANIDEM','BRIEC','UMS','RDMC','FSNC','ANDP',
    'CN','MR','AFP','MDIR','ADD','UNDP','PURS','PDC','BDC'];

  String textFieldMessage = "";
  String parrain = "none";
  String parti = "none";

  final namecontroller = TextEditingController();
  final prenomcontroller = TextEditingController();
  final parraincontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final pwdcontroller = TextEditingController();
  final pwdCfcontroller = TextEditingController();
  final birthdaycontroller = TextEditingController();
  final birthmonthcontroller = TextEditingController();
  final birthyearcontroller = TextEditingController();
  final regioncontroller = TextEditingController();
  final payscontroller = TextEditingController();
  final departementcontroller = TextEditingController();
  final deporgcontroller = TextEditingController();
  final cnicontroller = TextEditingController();
  final numerocecontroller = TextEditingController();
  final editioncontroller = TextEditingController();
  final matriculecontroller = TextEditingController();


  late Color emailFieldColor = UIColors.primaryColor;
  late Color matriculeFieldColor = UIColors.primaryColor;
  late Color pwdFieldColor = UIColors.primaryColor;
  late Color pwdCfFieldColor = UIColors.primaryColor;
  late Color parrainFieldColor = UIColors.primaryColor;
  late Color cniFieldColor = UIColors.primaryColor;
  late Color ceFieldColor = UIColors.primaryColor;
  late Color nomFieldColor = UIColors.primaryColor;
  late Color prenomFieldColor = UIColors.primaryColor;
  late Color dayFieldColor = UIColors.primaryColor;
  late Color monthFieldColor = UIColors.primaryColor;
  late Color yearFieldColor = UIColors.primaryColor;
  late Color phoneFieldColor = UIColors.primaryColor;
  late Color textFieldColor = UIColors.primaryColor;

  @override
  void initState() {
    parti=allPartis[0];
    selectedDepartementOrg=allDepartements[0];
    selectedRegion=viewableRegionList[0];
    viewableDeptList=depsFromReg(selectedRegion);
    selectedDepartement=viewableDeptList[0];
    viewableCommuneList=comsFromDep(selectedDepartement);
    selectedCommune=viewableCommuneList[0];
    //API.Notifify('titre', 'message', payload: 'test');
    super.initState();
  }

  @override
  void dispose() {
    viewableCommuneList=[];
    viewableDeptList=[];
    viewableRegionList=[];
    super.dispose();
  }
  final PageController pagecontroller = PageController();
  final ScrollController scrollcontroller = ScrollController();
  // Define the function that scroll to an item
  void _scrollToIndex(index) {
    scrollcontroller.animateTo((BodyWidth()- (index>1?50:380)) * index,
        duration: const Duration(seconds: 2), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UIColors.primaryColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: UIColors.primaryColor,
          leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).primaryColorDark,),
                  onPressed: () { Navigator.of(context).pop(); },
                );
              }) ,
          title:
          Padding(
            padding: getPadding(left: 20),
            child:
            Text("",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtInter(color: Colors.black, weight: 'regular', size: 24),
            ),
          ),
          elevation: 0,
        ),
      body:
      ListView(
        children: [
          Container(
            height: 60,
            padding: getPadding(top: 20),
            child: ListView(
              controller: scrollcontroller,
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Text('1- Informations personnelles    ',style: AppStyle.txtInter(size: pageIndex==0?22:18,
                  color: pageIndex==0?UIColors.primaryAccent:UIColors.blueGray100,),),
                Text('2- Territorialité    ',style: AppStyle.txtInter(size: pageIndex==1?22:18,
                  color: pageIndex==1?UIColors.primaryAccent:UIColors.blueGray100,),),
                Text('3- Militantisme    ',style: AppStyle.txtInter(size: pageIndex==2?22:18,
                  color: pageIndex==2?UIColors.primaryAccent:UIColors.blueGray100,),),
                Text('4- Parrainage    ',style: AppStyle.txtInter(size: pageIndex==3?22:18,
                  color: pageIndex==3?UIColors.primaryAccent:UIColors.blueGray100,),),
              ],
            ),
          ),
          Container(
            height: BodyHeight()-120,
            child:
            PageView(
              controller: pagecontroller,
              children: <Widget>[
                ListView(
                  children: [
                    Row(
                      mainAxisAlignment:MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: (){
                          },
                          child:
                          Text(' ',style: AppStyle.txtInter(size: 18,color: UIColors.primaryAccent),),
                        ),
                      ],
                    ),
                    Container(
                      margin: getMargin(left: 20,right: 20,top: 20),
                      padding: getPadding(all: 15),
                      decoration: BoxDecoration(
                          color: UIColors.primaryAccent,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: getPadding(
                              bottom: 4,
                              left: 22,
                            ),
                            child: Text(
                              textFieldMessage,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppStyle.txtError,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.person),
                              Padding(padding: getPadding(left: 8)),
                              Text('Nom',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                TextField(
                                  controller: namecontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Nom',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:nomFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Padding(padding: getPadding(left: 32)),
                              Text('Prénom',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                TextField(
                                  controller: prenomcontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Prénom',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: prenomFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Icon(Icons.email),
                              Padding(padding: getPadding(left: 8)),
                              Text('Email',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                TextField(
                                  controller: emailcontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'example@mail.com',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: emailFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Icon(Icons.lock),
                              Padding(padding: getPadding(left: 8)),
                              Text('Mot de Passe',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                TextField(
                                  controller: pwdcontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  maxLines: 1,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'mot de passe',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: pwdFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Padding(padding: getPadding(left: 32)),
                              Text('Confirmer',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                TextField(
                                  controller: pwdCfcontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  maxLines: 1,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'confirmer mot de passe',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: pwdCfFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Icon(Icons.phone),
                              Padding(padding: getPadding(left: 8)),
                              Text('Téléphone',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                TextField(
                                  controller: phonecontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: '+237 671....',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: phoneFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Icon(Icons.man),
                              Padding(padding: getPadding(left: 8)),
                              Text('Sexe',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Text('Homme',
                                style: AppStyle.txtInter(color: sexe==false?UIColors.primaryColor:UIColors.blueGray100,size: 16),
                              ),
                              Switch(
                                value: sexe,
                                activeColor: UIColors.primaryColor,
                                onChanged: (bool value) {
                                  sexe=!sexe;
                                  setState(() {
                                  });
                                },
                              ),
                              Text('Femme',
                                style: AppStyle.txtInter(color: sexe?UIColors.primaryColor:UIColors.blueGray100,size: 16),
                              ),
                            ],
                          ),
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Icon(Icons.cake_outlined),
                              Padding(padding: getPadding(left: 8)),
                              Text('Birthday',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 60,
                                margin: getMargin(right: 10),
                                child:
                                TextField(
                                  controller: birthdaycontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Jour',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: dayFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 60,
                                margin: getMargin(right: 10),
                                child:
                                TextField(
                                  controller: birthmonthcontroller,
                                  keyboardType: TextInputType.number,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Mois',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: monthFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 60,
                                child:
                                TextField(
                                  controller: birthyearcontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Année',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: yearFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: getPadding(top: 30)),
                    Row(
                      children: [
                        Spacer(),
                        TextButton(
                          onPressed: (){
                            if(pageIndex==3){
                              register();
                              show_loading=true;
                            }
                            else{
                              pageIndex++;
                              textFieldMessage='';
                              pagecontroller.animateToPage(pageIndex, duration: Duration(seconds: 1), curve: Curves.easeIn);
                              _scrollToIndex(pageIndex);
                            }
                            setState(() {

                            });
                          },
                          child:
                          Stack(
                            children: [
                              Container(
                                height: 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: UIColors.primaryAccent,
                                ),
                                child:
                                Center(child:
                                Text(pageIndex>2?'Terminer':'Suivant', style: AppStyle.txtInter(size: 20,color: UIColors.primaryColor),),),
                              ),
                              Visibility(
                                visible: show_loading,
                                child:
                                Padding(
                                    padding: getPadding(top: 20,left: 150),
                                    child:
                                    Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: UIColors.primaryColor,
                                        )
                                    )
                                ),
                              ),
                            ],
                          ) ,
                        ),
                      ],
                    ),
                    Padding(padding: getPadding(top: 30)),
                  ],
                ),
                ListView(
                  children: [
                    Padding(
                      padding: getPadding(
                        bottom: 4,
                        left: 22,
                      ),
                      child: Text(
                        textFieldMessage,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppStyle.txtError,
                      ),
                    ),
                    Container(
                      margin: getMargin(left: 20,right: 20,top: 20),
                      padding: getPadding(all: 15),
                      decoration: BoxDecoration(
                          color: UIColors.primaryAccent,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Column(
                        children: [
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Icon(Icons.place),
                              Padding(padding: getPadding(left: 8)),
                              Text('Pays',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                DropdownButton(
                                    value:selectedPays,
                                    isExpanded:true,
                                    items: allPays.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item,style: AppStyle.txtInter(size: 20),),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.arrow_drop_down_rounded),
                                    onChanged: (String? value){
                                      selectedPays=value!;
                                      viewableRegionList = value=="Cameroun" ? regions : emptyList;
                                      selectedRegion=viewableRegionList[0];
                                      setState(() {
                                      });
                                    }),
                              ),
                            ],
                          ),//pays
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Padding(padding: getPadding(left: 32)),
                              Text('Région',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                DropdownButton(
                                    value:selectedRegion,
                                    isExpanded:true,
                                    items: viewableRegionList.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item,style: AppStyle.txtInter(size: 20),),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.arrow_drop_down_rounded),
                                    onChanged: (String? value){
                                      selectedRegion = value!;
                                      viewableDeptList = depsFromReg(selectedRegion);
                                      selectedDepartement=viewableDeptList.length>0?viewableDeptList[0]:emptyList[0];
                                      viewableCommuneList=comsFromDep(selectedDepartement);
                                      selectedCommune=viewableCommuneList.length>0?viewableCommuneList[0]:emptyList[0];
                                      setState(() {

                                      });
                                    }),
                              ),
                            ],
                          ),//region
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Padding(padding: getPadding(left: 32)),
                              Text('Département',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                DropdownButton(
                                    value:selectedDepartement,
                                    isExpanded:true,
                                    items: viewableDeptList.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item,style: AppStyle.txtInter(size: 20),),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.arrow_drop_down_rounded),
                                    onChanged: (String? value){
                                      selectedDepartement = value!;
                                      viewableCommuneList=comsFromDep(selectedDepartement);
                                      selectedCommune=viewableCommuneList.length>0?viewableCommuneList[0]:emptyList[0];
                                      setState(() {

                                      });
                                    }),
                              ),
                            ],
                          ),//dept
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Padding(padding: getPadding(left: 32)),
                              Text('Commune',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                DropdownButton(
                                    value:selectedCommune,
                                    isExpanded:true,
                                    items: viewableCommuneList.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item,style: AppStyle.txtInter(size: 20),),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.arrow_drop_down_rounded),
                                    onChanged: (String? value){
                                      selectedCommune = value!;
                                      setState(() {

                                      });
                                    }),
                              ),
                            ],
                          ),//commune
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Padding(padding: getPadding(left: 32)),
                              Text('Dept origine',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                DropdownButton(
                                    value:selectedDepartementOrg,
                                    isExpanded:true,
                                    items: allDepartements.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item,style: AppStyle.txtInter(size: 20),),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.arrow_drop_down_rounded),
                                    onChanged: (String? value){
                                      selectedDepartementOrg=value!;
                                      setState(() {

                                      });
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: getPadding(top: 30)),
                    Row(
                      children: [
                        TextButton(
                          onPressed: (){
                            pageIndex--;
                            textFieldMessage='';
                            pagecontroller.animateToPage(pageIndex, duration: Duration(seconds: 1), curve: Curves.easeIn);
                            setState(() {

                            });
                          },
                          child:
                          Stack(
                            children: [
                              Container(
                                height: 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: UIColors.successColor,
                                ),
                                child:
                                Center(child:
                                Text('Précédent ', style: AppStyle.txtInter(size: 20,color: Colors.white),),),
                              ),
                            ],
                          ) ,
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: (){
                            if(pageIndex==3)
                              register();
                            else{
                              pageIndex++;
                              textFieldMessage='';
                              pagecontroller.animateToPage(pageIndex, duration: Duration(seconds: 1), curve: Curves.easeIn);
                              _scrollToIndex(pageIndex);
                            }
                            setState(() {

                            });
                          },
                          child:
                          Stack(
                            children: [
                              Container(
                                height: 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: UIColors.primaryAccent,
                                ),
                                child:
                                Center(child:
                                Text(pageIndex>2?'Terminer':'Suivant', style: AppStyle.txtInter(size: 20,color: UIColors.primaryColor),),),
                              ),
                              Visibility(
                                visible: show_loading,
                                child:
                                Padding(
                                    padding: getPadding(top: 20,left: 150),
                                    child:
                                    Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,

                                        )
                                    )
                                ),
                              ),
                            ],
                          ) ,
                        ),
                      ],
                    ),
                    Padding(padding: getPadding(top: 30)),
                  ],
                ),
                ListView(
                  children: [
                    Padding(
                      padding: getPadding(
                        bottom: 4,
                        left: 22,
                      ),
                      child: Text(
                        textFieldMessage,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppStyle.txtError,
                      ),
                    ),
                    Row(
                      mainAxisAlignment:MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: (){
                            pageIndex+=1;
                            textFieldMessage='';
                            pagecontroller.animateToPage(pageIndex, duration: Duration(seconds: 1), curve: Curves.easeIn);
                            _scrollToIndex(pageIndex);
                          },
                          child:
                          Text('Passer',style: AppStyle.txtInter(size: 18,color: UIColors.primaryAccent),),
                        ),
                        Icon(Icons.keyboard_double_arrow_right)
                      ],
                    ),
                    Container(
                      margin: getMargin(left: 20,right: 20,top: 20),
                      padding: getPadding(all: 15),
                      decoration: BoxDecoration(
                          color: UIColors.primaryAccent,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Column(
                        children: [
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Icon(Icons.language),
                              Padding(padding: getPadding(left: 8)),
                              Container(
                                width: 150,
                                child:
                                Text('Connaissez vous l\'organisation muntur ?',
                                  style: AppStyle.txtInter(size: 20),),
                              ),
                              Spacer(),
                              Switch(
                                value: sympathisant,
                                activeColor: UIColors.primaryColor,
                                onChanged: (bool value) {
                                  sympathisant=!sympathisant;
                                  setState(() {
                                  });
                                },
                              ),
                              Text(sympathisant?'OUI':'NON',
                                style: AppStyle.txtInter(color: UIColors.primaryColor,size: 16),
                              ),
                            ],
                          ),
                          Padding(padding: getPadding(top: 30)),
                          Row(
                            children: [
                              Icon(Icons.place),
                              Padding(padding: getPadding(left: 8)),
                              Container(
                                width: 100,
                                child:
                                      Text('Membre d\'un parti politique?',
                                  style: AppStyle.txtInter(size: 20),),

                              ),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: UIColors.primaryColor
                                  ),
                                ),
                                child:
                                DropdownButton(
                                    value:parti,
                                    items: allPartis.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item,style: AppStyle.txtInter(size: 20),),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.arrow_drop_down_rounded),
                                    onChanged: (String? value){
                                      parti=value!;
                                      setState(() {
                                      });
                                    }),
                              ),
                            ],
                          ),//pays
                          Padding(padding: getPadding(top: 10)),
                          parti=='PCRN'?
                          Row(
                            children: [
                              Icon(Icons.credit_card),
                              Padding(padding: getPadding(left: 8)),
                              Text('Matricule',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 110,
                                margin: getMargin(right: 10),
                                child:
                                TextField(
                                  controller: matriculecontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Numéro de matricule',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: matriculeFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ):SizedBox(),
                        ],
                      ),
                    ),
                    Padding(padding: getPadding(top: 30)),
                    Row(
                      children: [
                        TextButton(
                          onPressed: (){
                            pageIndex--;
                            textFieldMessage='';
                            pagecontroller.animateToPage(pageIndex, duration: Duration(seconds: 1), curve: Curves.easeIn);
                            _scrollToIndex(pageIndex);
                            setState(() {

                            });
                          },
                          child:
                          Stack(
                            children: [
                              Container(
                                height: 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: UIColors.successColor,
                                ),
                                child:
                                Center(child:
                                Text('Précédent ', style: AppStyle.txtInter(size: 20,color: Colors.white),),),
                              ),
                            ],
                          ) ,
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: (){
                            if(pageIndex==3)
                              register();
                            else{
                              pageIndex++;
                              textFieldMessage='';
                              pagecontroller.animateToPage(pageIndex, duration: Duration(seconds: 1), curve: Curves.easeIn);
                              _scrollToIndex(pageIndex);
                            }
                            setState(() {

                            });
                          },
                          child:
                          Stack(
                            children: [
                              Container(
                                height: 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: UIColors.primaryAccent,
                                ),
                                child:
                                Center(child:
                                Text(pageIndex>2?'Terminer':'Suivant', style: AppStyle.txtInter(size: 20,color: UIColors.primaryColor),),),
                              ),
                              Visibility(
                                visible: show_loading,
                                child:
                                Padding(
                                    padding: getPadding(top: 20,left: 150),
                                    child:
                                    Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,

                                        )
                                    )
                                ),
                              ),
                            ],
                          ) ,
                        ),
                      ],
                    ),
                    Padding(padding: getPadding(top: 30)),
                  ],
                ),
                ListView(
                  children: [
                    Padding(
                      padding: getPadding(
                        bottom: 4,
                        left: 22,
                      ),
                      child: Text(
                        textFieldMessage,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppStyle.txtError,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                          },
                          child:
                          Text('',style: AppStyle.txtInter(size: 18,color: UIColors.primaryAccent),),
                        ),
                      ],
                    ),
                    Container(
                      margin: getMargin(left: 20,right: 20,top: 20),
                      padding: getPadding(all: 15),
                      decoration: BoxDecoration(
                          color: UIColors.primaryAccent,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person),
                              Padding(padding: getPadding(left: 8)),
                              Text('Code Parrain',
                                style: AppStyle.txtInter(size: 20),),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 150,
                                child:
                                TextField(
                                  controller: parraincontroller,
                                  style: AppStyle.txtInter(size: 16),
                                  cursorColor: UIColors.cursorColor,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Code Parrain',
                                    fillColor: UIColors.edittextFillColor,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      gapPadding: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:parrainFieldColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: getPadding(top: 10)),
                          Row(
                            children: [
                              Checkbox(
                                  activeColor: UIColors.primaryColor,
                                  value: privacyPolicy,
                                  onChanged: (bool? value){
                                    privacyPolicy=value!;
                                    setState(() {
                                    });
                                  }),
                              Flexible(child:
                              Text('J\'ai lu et accepté les conditions générale d\'usage de l\'application muntur',
                                style: AppStyle.txtInter(size: 16),),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: getPadding(top: 30)),
                    Row(
                      children: [
                        TextButton(
                          onPressed: (){
                            pageIndex--;
                            textFieldMessage='';
                            pagecontroller.animateToPage(pageIndex, duration: Duration(seconds: 1), curve: Curves.easeIn);
                            _scrollToIndex(pageIndex);
                            setState(() {

                            });
                          },
                          child:
                          Stack(
                            children: [
                              Container(
                                height: 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: UIColors.successColor,
                                ),
                                child:
                                Center(child:
                                Text('Précédent ', style: AppStyle.txtInter(size: 20,color: Colors.white),),),
                              ),
                            ],
                          ) ,
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: (){
                            if(pageIndex==3){
                              if(privacyPolicy){
                              show_loading=true;
                              register();
                              }
                            }
                            else{
                              pageIndex++;
                              textFieldMessage='';
                              pagecontroller.animateToPage(pageIndex, duration: Duration(seconds: 1), curve: Curves.easeIn);
                            }
                            setState(() {

                            });
                          },
                          child:
                          Stack(
                            children: [
                              Container(
                                height: 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: UIColors.primaryAccent,
                                ),
                                child:
                                Center(child:
                                Text(pageIndex>2?'Terminer':'Suivant', style: AppStyle.txtInter(size: 20,color: (pageIndex>2 && privacyPolicy) ? UIColors.primaryColor:UIColors.blueGray100),),),
                              ),
                              Visibility(
                                visible: show_loading,
                                child:
                                Padding(
                                    padding: getPadding(top: 20,left: 150),
                                    child:
                                    Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: UIColors.primaryColor,

                                        )
                                    )
                                ),
                              ),
                            ],
                          ) ,
                        ),
                      ],
                    ),
                    Padding(padding: getPadding(top: 30)),
                  ],
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  void register() {
    String data = "starting register .... ";
    log('muntur DEBUG: -- Signup--  $data');
    show_loading = true;
    textFieldMessage = "";
    bool emailValid = RegExp(r'\S+@\S+\.\S+').hasMatch(emailcontroller.text.trim());
    if (namecontroller.text.isEmpty) {
      nomFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ nom*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (prenomcontroller.text.isEmpty) {
      prenomFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ prenom*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (pwdcontroller.text.isEmpty) {
      pwdFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ mot de passe*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (pwdcontroller.text != pwdCfcontroller.text) {
      pwdCfFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ confirmation mot de passe*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (!emailValid) {
      emailFieldColor = Colors.redAccent;
      textFieldMessage = "Email incorrect";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (birthdaycontroller.text.isEmpty || int.parse(birthdaycontroller.text) > 31 || int.parse(birthdaycontroller.text) < 0) {
      dayFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ correctement jour de naissance*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (birthmonthcontroller.text.isEmpty || int.parse(birthmonthcontroller.text) > 12 || int.parse(birthmonthcontroller.text) < 0) {
      monthFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ correctement mois de naissance*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (birthyearcontroller.text.isEmpty || int.parse(birthyearcontroller.text) < 1950 || int.parse(birthyearcontroller.text) > 2005) {
      yearFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ correctement année de naissance*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (!validDate(birthdaycontroller.text + "/" + birthmonthcontroller.text + "/" + birthyearcontroller.text)) {
      dayFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ correctement date de naissance* format jj/mm/aaaa ex 12/10/1995";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else {
      User inscription=new User();
      inscription.nom=namecontroller.text;
      inscription.prenom=prenomcontroller.text;
      inscription.email=emailcontroller.text.trim();
      inscription.password=pwdcontroller.text;
      inscription.telephone=phonecontroller.text;
      inscription.photo="none";
      inscription.sexe=sexe?'FEMME':'HOMME';
      inscription.date_naissance=getTime(birthdaycontroller.text + "/" + birthmonthcontroller.text + "/" + birthyearcontroller.text);
      inscription.pays=selectedPays;
      Token? tokenFromAPI;
      var body;
      API.signup(inscription).then((response) => {
        if(response.statusCode==200){
          textFieldMessage='Inscription enregistrée avec succès',
          toast('Inscription enregistrée avec succès'),
          textFieldColor=UIColors.primaryColor,
          //show_loading=false,
          //log(emailText.text.toString().trim() +' , '+ pwdText.text.toString());
          API.login(inscription.email, inscription.password).then((response) => {
            //log(inscription.email.text.toString().trim() +' , '+ inscription.password),
            //log(response.body),
            if (response.statusCode == 200)
              {
                tokenFromAPI = Token.fromJson(jsonDecode(response.body)),
                API.getProfileWithEmail(inscription.email, inscription.password,tokenFromAPI!.access).then((resp1) => {
                  if (resp1.statusCode == 200){
                    log(jsonDecode(resp1.body)['data'].toString()),
                    API.insertUIUser(User.fromJson(jsonDecode(resp1.body)['data']),),
                    tokenFromAPI!.time = DateTime.now().millisecondsSinceEpoch / 1000 + (3600 * 24),
                    tokenFromAPI!.password = inscription.password,
                    tokenFromAPI!.email = inscription.email,
                    API.getTokens().then((value) => {
                      if (value.isNotEmpty)
                        {
                          API.updateToken(tokenFromAPI!).then((value) => {
                            data = "connected successfully",
                            log('Muntur DEBUG: $data'),
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(data),
                            )),
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())),
                          })
                        }
                      else
                        API.insertToken(tokenFromAPI!).then((value) => {
                          data = "connected successfully",
                          log('Muntur DEBUG: $data'),
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(data),
                          )),
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())),
                        })
                    })
                  }
                  else
                    {
                      textFieldColor = Colors.redAccent,
                      show_loading = false,
                      textFieldMessage = "Echec de connexion! Veuilllez reessayez",
                      log('Muntur DEBUG: connexion error'),
                      data = "connexion failed with : " + resp1.body,
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("connexion failed"),
                      )),
                    }
                }),
              }
            else
              {
                textFieldColor = Colors.redAccent,
                show_loading = false,
                textFieldMessage = "Echec de connexion, Veuillez verifier vos informations de connexion!",
                data = "connexion failed with : user=" +
                    inscription.email.toString().trim() +
                    " and pass=" +
                    inscription.password,
                log('Muntur DEBUG: $data'),
                data = "connexion failed with : " + response.body,
                log('Muntur DEBUG: $data'),
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("connexion failed"),
                )),
              }
          })
        }
        else{
          body=json.decode(response.body),
          textFieldMessage='Inscription echouée avec : '+ body['description'],
          toast('Inscription echouée avec : '+ body['description'],color: Colors.grey),
          textFieldColor=UIColors.errorColor,
          show_loading=false,
        },
        setState((){}),
      });
    }
  }

  bool validDate(String date) {
    log('validating date');
    DateFormat format = DateFormat("dd/MM/yyyy");
    log('$date');
    try {
      DateTime dayOfBirthDate = format.parseStrict(date);
      log('birthdate ' + dayOfBirthDate.toString());
      return true;
    } catch (e) {
      log('$e');
      return false;
    }
  }
  int getTime(String date){
    int time=0;
    DateFormat format = DateFormat("dd/MM/yyyy");
    DateTime dayOfBirthDate = format.parseStrict(date);
    time = (dayOfBirthDate.millisecondsSinceEpoch/1000).floor();
    return time;
  }


}

