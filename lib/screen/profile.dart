import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/services/api.dart';
import 'package:path_provider/path_provider.dart';

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
class Profile extends StatefulWidget{
  User user;
  Profile({Key? key,required this.user})
      : super(
    key: key,
  );
  @override
  State<Profile> createState() => Profile_(user: user);
}
class Profile_ extends State<Profile>  with TickerProviderStateMixin{
  User user;
  String setTitle='';
  bool showfilter=false;
  bool showimagesource=false;
  bool load_photo=false;
  bool show_login=true;
  bool show_militant=true;
  bool show_locality=true;
  bool sexe=false;
  late bool progressbarVisibility = false;
  late String textFieldMessage = "";
  late Animation<double> animation;
  double height=200;
  late AnimationController controller;
  ScrollController scrollcontroller=ScrollController();
  String photo='';
  String selectedRegion = '';
  String selectedDepartement = '';
  String selectedDepartementOrg = '';
  String selectedCommune = '';
  int pageIndex=0;

  List<String> allPartis=['Non       ','RDPC','MRC','UPC','PCRN','SDF','UDC','CPP','MANIDEM','BRIEC','UMS','RDMC','FSNC','ANDP',
    'CN','MR','AFP','MDIR','ADD','UNDP','PURS','PDC','BDC'];
  List<String> allPays = countries_fr;
  List<String> allDepartements = alldeps();
  String selectedPays = 'Cameroun';

  List<String> emptyList=['Aucun'];
  List<String> viewableCommuneList=[];
  List<String> viewableRegionList = regions;
  List<String> viewableDeptList=[];
  String parrain = "none";
  String parti = "none";

  final namecontroller = TextEditingController();
  final prenmunturontroller = TextEditingController();
  final parraincontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final pwdcontroller = TextEditingController();
  final oldpwdcontroller = TextEditingController();
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
  late Color oldpwdFieldColor = UIColors.primaryColor;
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

  Profile_({Key? key,required this.user});

  @override
  void initState() {
    parti=allPartis[0];
    scrollcontroller.addListener(() {
      if(showfilter=true){
        showfilter=false;
      }
    });
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    animation = Tween<double>(begin: 0, end: 360).animate(controller)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
    sexe=user.sexe=='Homme'?true:false;
    controller.repeat();
    //getDatas();
    selectedDepartementOrg = allDepartements[0];
    selectedRegion = viewableRegionList[0];
    viewableDeptList = depsFromReg(selectedRegion);
    selectedDepartement = viewableDeptList.length>0?viewableDeptList[0]:emptyList[0];
    viewableCommuneList = comsFromDep(selectedDepartement);
    selectedCommune = viewableCommuneList.length>0?viewableCommuneList[0]:emptyList[0];
    super.initState();
  }

  @override
  void dispose() {
    viewableCommuneList=[];
    viewableDeptList=[];
    viewableRegionList=[];
    controller.dispose();
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
                    API.updateUIUser(user);
                    Navigator.of(context).pop();
                  },
              );
        }) ,
        title:
          Padding(
            padding: getPadding(left: 100),
            child:
              Text("Profil",
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Container(
              margin: getMargin(all:8),
              height: getVerticalSize(200,),
              width: getVerticalSize(200,),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: UIColors.boxFillColor,
                  image: (user.photo!='none' && user.photo!='None' && user.photo.isNotEmpty)?
                  DecorationImage(
                    image: FileImage(File('/data/user/0/com.steps.davinci.muntuai/app_flutter/'+user.photo.split('/').last)),
                    fit: BoxFit.cover,
                  ):DecorationImage(
                      image: AssetImage('assets/images/avatar.jpg'),
                      fit: BoxFit.cover
                  )
              ),
            ),
            Padding(
              padding: getPadding(top: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Nom : ",style: AppStyle.txtInter(size: 16),),
                  Spacer(),
                  Text("Nlomeka",style: AppStyle.txtInter(size: 18,weight: 'bold'),),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),
            ),
            Padding(
              padding: getPadding(top: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Prénom : ",style: AppStyle.txtInter(size: 16),),
                  Spacer(),
                  Text("Christian",style: AppStyle.txtInter(size: 18,weight: 'bold'),),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),
            ),
            Padding(
              padding: getPadding(top: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("email : ",style: AppStyle.txtInter(size: 16),),
                  Spacer(),
                  Text("usermail@muntur.com",style: AppStyle.txtInter(size: 18,weight: 'bold'),),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),
            ),
            Padding(
              padding: getPadding(top: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Localisation : ",style: AppStyle.txtInter(size: 16),),
                  Spacer(),
                  Text("Douala, Cameroun",style: AppStyle.txtInter(size: 18,weight: 'bold'),),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
  void register() async{
    progressbarVisibility=true;
    if(setTitle=='nom'){
      if(namecontroller.value.text!=''){
        user.nom=namecontroller.value.text;
      }
    }
    if(setTitle=='prenom'){
      if(namecontroller.value.text!=''){
        user.prenom=namecontroller.value.text;
      }
    }
    if(setTitle=='sexe'){
      user.sexe=sexe?'FEMME':'HOMME';
    }

    if(setTitle=='age'){
      if(birthdaycontroller.text.isNotEmpty && birthmonthcontroller.text.isNotEmpty && birthyearcontroller.text.isNotEmpty ){
      if (int.parse(birthdaycontroller.text) > 31 || int.parse(birthdaycontroller.text) < 0) {
        dayFieldColor = Colors.redAccent;
        textFieldMessage = "Veuillez remplir le champ requis correctement ";
        textFieldColor = Colors.redAccent;
      }
      else if (int.parse(birthmonthcontroller.text) > 12 || int.parse(birthmonthcontroller.text) < 0) {
        monthFieldColor = Colors.redAccent;
        textFieldMessage = "Veuillez remplir le champ requis correctement ";
        textFieldColor = Colors.redAccent;
      }
      else if (int.parse(birthyearcontroller.text) < 1950 || int.parse(birthyearcontroller.text) > 2005) {
        yearFieldColor = Colors.redAccent;
        textFieldMessage = "Veuillez remplir le champ requis correctement ";
        textFieldColor = Colors.redAccent;
      }
      else if (!validDate(birthdaycontroller.text + "/" + birthmonthcontroller.text + "/" + birthyearcontroller.text)) {
        dayFieldColor = Colors.redAccent;
        textFieldMessage = "Veuillez remplir le champ requis correctement ";
        textFieldColor = Colors.redAccent;
      }
      user.date_naissance=getTime(birthdaycontroller.text + "/" + birthmonthcontroller.text + "/" + birthyearcontroller.text);
      }
    }

    if(setTitle=='ville'){
      user.ville=selectedRegion;
      user.pays=selectedPays;
    }
    if(setTitle=='password'){
      Token token = await API.getTokens().then((value) => value[0]);
      if(oldpwdcontroller.text!=token.password){
        oldpwdFieldColor = Colors.redAccent;
        textFieldMessage = "Mot de passe incorrecte";
        textFieldColor = Colors.redAccent;
      }
      else if( pwdcontroller.text == ''){
        pwdFieldColor = Colors.redAccent;
        textFieldMessage = "Veuillez remplir le champ requis correctement ";
        textFieldColor = Colors.redAccent;
      }
      else if(oldpwdcontroller.text == token.password && pwdcontroller.text == pwdCfcontroller.text){
        await API.setPassword(token.password, pwdcontroller.text).then((value) =>
        {
          if(value.statusCode==200){
            token.password= pwdcontroller.text,
            API.updateToken(token)
          }
          else{
            pwdFieldColor = Colors.redAccent,
            textFieldMessage = "Echec de l'operation, veuillez verifier votre connexion",
            textFieldColor = Colors.redAccent,
          }
        });
      }
      else{
        pwdFieldColor = Colors.redAccent;
        pwdCfFieldColor = Colors.redAccent;
        textFieldMessage = "Veuillez remplir les champs requis correctement";
        textFieldColor = Colors.redAccent;
      }
    }
    await API.updateUser(user).then((response) async => {
      if(response.statusCode==200){
        await API.updateUIUser(user),
      }
      else{
        print('failed with ' + response.body),
        }
    });
    setState(() {
      progressbarVisibility = false;
      showfilter = false;
      namecontroller.text = '';
    });
  }

  takeImage(ImageSource imagesource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source:imagesource);
    if (file != null) {
      load_photo=true;
      setState(() {});
      await API.updateUserPhoto(file.path).then((response) async =>
      {
        if(response.statusCode==200){
          await API.syncProfile().then((value) async => {
            user=await API.getUI_user().then((value) => value[0])
          }),
        },
        load_photo=false,
        setState(() {}),
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


