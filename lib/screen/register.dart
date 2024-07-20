import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/theming/app_style.dart';
import 'package:munturai/core/utils/image_constant.dart';
import 'package:munturai/core/utils/size_utils.dart';
import 'package:munturai/model/Token.dart';
import 'package:munturai/screen/home.dart';
import 'package:munturai/screen/signup.dart';
import 'package:munturai/services/api.dart';

import '../core/fonctions.dart';
import '../model/User.dart';
import '../utils/divisionsFilter.dart';

class Signup2 extends StatefulWidget{
  Signup2({Key? key})
      : super(
    key: key,
  );

  @override
  State<Signup2> createState() => _signupState();
}

class _signupState extends State<Signup2> with TickerProviderStateMixin {
  late bool progressbarVisibility = false;
  late Color textFieldColor = UIColors.blueGray100;
  late String textFieldMessage = "";
  late Animation<double> animation;
  late AnimationController controller;
  final emailText = TextEditingController();
  final pwdText = TextEditingController();
  final API = Api();

  bool sexe=false,privacyPolicy=false,
      show_loading=false;
  bool loading_datas=true;
  String photo='';
  int pageIndex=0;
  String selectedRegion = '';

  List<String> allPays = countries_fr;
  String selectedPays = 'Cameroun';

  String parrain = "none";
  String parti = "none";

  final namecontroller = TextEditingController();
  final prenomcontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final pwdcontroller = TextEditingController();
  final pwdCfcontroller = TextEditingController();
  final birthdaycontroller = TextEditingController();
  final birthmonthcontroller = TextEditingController();
  final birthyearcontroller = TextEditingController();
  final villecontroller = TextEditingController();
  final payscontroller = TextEditingController();


  late Color emailFieldColor = UIColors.primaryColor;
  late Color pwdFieldColor = UIColors.primaryColor;
  late Color pwdCfFieldColor = UIColors.primaryColor;
  late Color nomFieldColor = UIColors.primaryColor;
  late Color prenomFieldColor = UIColors.primaryColor;
  late Color dayFieldColor = UIColors.primaryColor;
  late Color monthFieldColor = UIColors.primaryColor;
  late Color yearFieldColor = UIColors.primaryColor;
  late Color phoneFieldColor = UIColors.primaryColor;

  @override
  void initState() {
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
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    emailText.dispose();
    pwdText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ListView(
        children:[
          Container(
            padding: getPadding(all:10),
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 170,
            decoration: BoxDecoration(
                color: UIColors.primaryAccent,
                borderRadius: BorderRadius.circular(20)
            ),
            child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                  Image.asset(
                    ImageConstant.logo_dark,
                    width: BodyWidth()-60,
                    fit:BoxFit.fitWidth,
                    height: 150,
                  ),]
                ),
          ),
          Padding(padding: getPadding(top:10)),
          Container(
            margin: getMargin(left: 20,right: 20),
            padding: getPadding(all: 15),
            decoration: BoxDecoration(
              color: UIColors.primaryAccent,
              borderRadius: BorderRadius.circular(20)
            ),
            child:
            Column(
              children: [
                Text('Créer mon compte',
                  style: AppStyle.txtInter(size: 28),
                ),
                Padding(padding: getPadding(top:25)),
                TextField(
                  controller: namecontroller,
                  style: AppStyle.txtInter(size: 20),
                  keyboardType: TextInputType.text,
                  cursorColor: UIColors.cursorColor,
                  decoration: InputDecoration(
                    hintText: 'Nom',
                    fillColor: UIColors.edittextFillColor,
                    border: OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),

                  ),
                ),
                Padding(padding: getPadding(top:15)),
                TextField(
                  controller: prenomcontroller,
                  style: AppStyle.txtInter(size: 20),
                  keyboardType: TextInputType.text,
                  cursorColor: UIColors.cursorColor,
                  decoration: InputDecoration(
                    hintText: 'Prénom',
                    fillColor: UIColors.edittextFillColor,
                    border: OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),

                  ),
                ),
                Padding(padding: getPadding(top:15)),
                TextField(
                  controller: emailcontroller,
                  style: AppStyle.txtInter(size: 20),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: UIColors.cursorColor,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    fillColor: UIColors.edittextFillColor,
                    border: OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),

                  ),
                ),
                Padding(padding: getPadding(top:15)),
                TextField(
                  controller: pwdcontroller,
                  style: AppStyle.txtInter(size: 20),
                  obscureText: true,
                  cursorColor: UIColors.cursorColor,
                  decoration: InputDecoration(
                    hintText: 'Mot de passe',
                    fillColor: UIColors.edittextFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(padding: getPadding(top:15)),
                TextField(
                  controller: pwdCfcontroller,
                  style: AppStyle.txtInter(size: 20),
                  obscureText: true,
                  cursorColor: UIColors.cursorColor,
                  decoration: InputDecoration(
                    hintText: 'Confirmer le mot de passe',
                    fillColor: UIColors.edittextFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(padding: getPadding(top:15)),
                TextField(
                  controller: phonecontroller,
                  style: AppStyle.txtInter(size: 20),
                  keyboardType: TextInputType.phone,
                  cursorColor: UIColors.cursorColor,
                  decoration: InputDecoration(
                    hintText: 'Téléphone (67XXXXXXXX)',
                    fillColor: UIColors.edittextFillColor,
                    border: OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),

                  ),
                ),
                Padding(padding: getPadding(top:15)),
                TextField(
                  controller: villecontroller,
                  style: AppStyle.txtInter(size: 20),
                  keyboardType: TextInputType.text,
                  cursorColor: UIColors.cursorColor,
                  decoration: InputDecoration(
                    hintText: 'Ville',
                    fillColor: UIColors.edittextFillColor,
                    border: OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),

                  ),
                ),
                Padding(padding: getPadding(top:15)),
                Container(
                  padding: getPadding(all: 5),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey),borderRadius: BorderRadius.circular(10)),
                  child: Row(
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
                              setState(() {
                              });
                            }),
                      ),
                    ],
                  ),
                ),//pays
                Padding(padding: getPadding(top: 15)),
                Row(
                  children: [
                    Icon(Icons.man),
                    Padding(padding: getPadding(left: 8)),
                    Text('Sexe',
                      style: AppStyle.txtInter(size: 20),),
                    Spacer(),
                    Text('Homme',
                      style: AppStyle.txtInter(color: sexe==false?UIColors.primaryColor:UIColors.blueGray100,size: 20),
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
                      style: AppStyle.txtInter(color: sexe?UIColors.primaryColor:UIColors.blueGray100,size: 20),
                    ),
                  ],
                ),
                Padding(padding: getPadding(top: 15)),
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
                        style: AppStyle.txtInter(size: 20),
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
                        style: AppStyle.txtInter(size: 20),
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
                        style: AppStyle.txtInter(size: 20),
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
                Padding(padding: getPadding(top: 15)),
                Text('$textFieldMessage',
                  style: AppStyle.txtArimoHebrewSubset(size: 16).copyWith(
                    fontStyle: FontStyle.italic,
                    color: textFieldColor
                  ),
                ),
                Padding(padding: getPadding(top:15)),
                GestureDetector(
                  onTap: () {
                    register();
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  child: Container(
                  padding: getPadding(
                    top: 12,
                    bottom: 12,
                  ),
                  width: BodyWidth(),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: UIColors.primaryColor,
                        borderRadius: BorderRadius.circular(35),
                  ),
                  child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: getPadding(
                            left: 38,
                            right: 38,
                            top: 3,
                            bottom: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Enregistrer",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtInter(size: 20,color: UIColors.primaryAccent),
                              ),
                              Visibility(
                                visible: show_loading,
                                child: Padding(
                                  padding: getPadding(
                                    left: 20,
                                  ),
                                  child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                  Center(
                                      child: CircularProgressIndicator(
                                        color: UIColors.primaryAccent,
                                        strokeWidth: 2,
                                      )),
                                ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(padding: getPadding(top:20)),
              ],
            ),

          ),
        ]

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
      textFieldMessage = "Veuillez remplir le champ correctement le jour de naissance*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (birthmonthcontroller.text.isEmpty || int.parse(birthmonthcontroller.text) > 12 || int.parse(birthmonthcontroller.text) < 0) {
      monthFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ correctement le mois de naissance*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (birthyearcontroller.text.isEmpty || int.parse(birthyearcontroller.text) < 1950 || int.parse(birthyearcontroller.text) > DateTime.now().year-14) {
      yearFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ correctement l'année de naissance*";
      textFieldColor = Colors.redAccent;
      show_loading = false;
    }
    else if (!validDate(birthdaycontroller.text + "/" + birthmonthcontroller.text + "/" + birthyearcontroller.text)) {
      dayFieldColor = Colors.redAccent;
      textFieldMessage = "Veuillez remplir le champ correctement la date de naissance* format jj/mm/aaaa ex 12/10/1995";
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
      inscription.ville=villecontroller.text;
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
          // log(response.body),
          log('Muntur DEBUG: '+response.body),
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
