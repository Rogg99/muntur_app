import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/utils/image_constant.dart';
import 'package:munturai/core/utils/size_utils.dart';
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/model/Discussion.dart';
import 'package:munturai/model/Info.dart';
import 'package:munturai/model/Message.dart';
import 'package:munturai/model/filter.dart';
import 'package:munturai/screen/chat.dart';
import 'package:munturai/screen/login.dart';
import 'package:munturai/screen/profile.dart';
import 'package:munturai/services/api.dart';
import 'package:munturai/widgets/custom_image_view.dart';
import 'package:munturai/model/User.dart';
import 'package:munturai/utils/sized_extension.dart';
import 'package:munturai/core/theming/dimens.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:munturai/widgets/widget_garage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:latlong2/latlong.dart';

import '../model/Garage.dart';
import '../model/Token.dart';
import '../utils/divisionsFilter.dart';
import '../widgets/widget_discussion.dart';
import '../widgets/widget_info.dart';
import 'garage.dart';
import 'infos.dart';
import 'maps.dart';

String SelectedMenu = 'Home';
String appVersion = '1.0.18';
double paddingtitle = 150;

var API = Api();
var user=User();
final ValueNotifier<List<Discussion>> discussions = ValueNotifier([]);
final ValueNotifier<List<Info>> infos = ValueNotifier([]);
final Map<String, dynamic> emptyUnit =  {
  "locality": 'none',
  "locality_type": 'commune',
  "month_preinscriptions": 0,
  "month_inscriptions": 0,
  "day_preinscriptions": 0,
  "day_inscriptions": 0,
  "_18_19s": 0,
  "diaspora": 0,
  "militant": {
    "id": "none",
    "nom": "none",
    "prenom": "none",
    "score": 0
  },
  "commune": {
    "id": "none",
    "name": "none",
    "score": 0
  },
  "departement": {
    "id": "none",
    "name": "none",
    "score": 0
  },
  "region": {
    "id": "none",
    "name": "none",
    "score": 0
  },
  "subdivisions":[]
};
final Map<String, dynamic> emptyCommune = {
  "id": "none",
  "name": "none",
  "score": 0
};

final ValueNotifier<String> langage = ValueNotifier('français');
final ValueNotifier<String> user_day_ins = ValueNotifier('0');
final ValueNotifier<String> user_day_pre = ValueNotifier('0');
final ValueNotifier<String> user_month_ins = ValueNotifier('0');
final ValueNotifier<String> user_month_pre = ValueNotifier('0');
final ValueNotifier<String> user_all_ins = ValueNotifier('0');
final ValueNotifier<String> user_all_pre = ValueNotifier('0');

final ValueNotifier<Map<String, dynamic>> global_day_ins = ValueNotifier(emptyUnit);
final ValueNotifier<Map<String, dynamic>> global_day_pre = ValueNotifier(emptyUnit);
final ValueNotifier<Map<String, dynamic>> global_month_ins = ValueNotifier(emptyUnit);
final ValueNotifier<Map<String, dynamic>> global_month_pre = ValueNotifier(emptyUnit);
final ValueNotifier<String> global_all_couverture = ValueNotifier('0');
final ValueNotifier<String> global_month_couverture = ValueNotifier('0');
final ValueNotifier<Map<String, dynamic>> global_month_commune = ValueNotifier(emptyCommune);
final ValueNotifier<Map<String, dynamic>> global_day_commune = ValueNotifier(emptyCommune);

final ValueNotifier<Map<String, dynamic>> locality_stats = ValueNotifier(emptyUnit);

final ValueNotifier<Map<String, dynamic>> locality_day_ins = ValueNotifier(emptyUnit);
final ValueNotifier<Map<String, dynamic>> locality_day_pre = ValueNotifier(emptyUnit);
final ValueNotifier<Map<String, dynamic>> locality_month_ins = ValueNotifier(emptyUnit);
final ValueNotifier<Map<String, dynamic>> locality_month_pre = ValueNotifier(emptyUnit);
final ValueNotifier<String> locality_all_couverture = ValueNotifier('0');
final ValueNotifier<String> locality_month_couverture = ValueNotifier('0');

bool light=false;
bool lang=false;
TextEditingController buttonmaleController = TextEditingController();
String radioGroup = "";
enum languages { Francais, English }
class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key})
      : super(
          key: key,
        );
  @override
  State<HomeScreen> createState() => StateHomeScreen();
}

class StateHomeScreen extends State<HomeScreen> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  List<String> results=[];
  String getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 600 ? 'phone' : 'tablet';
  }
  Filter filter = Filter();
  bool showfilter = false,
      show_inscription = false,
      show_preinscription = false,
      searchbarvisibilty = false;
  int selected_eventfilter = 0;
  final searchcontroller = TextEditingController();
  final dobstartcontroller = TextEditingController();
  final dobendcontroller = TextEditingController();
  final dorstartcontroller = TextEditingController();
  final dorendcontroller = TextEditingController();
  String deviceType = '', keywordEvent = '';
  String userBodyStats='';
  String globalBodyStats='';
  bool isLoading = true,searchdone=true,loadGarages = true ,showGarages = true;
  List<String> categories=[];
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  List<String> allPays = countries_fr;
  List<Garage> garages = [];
  String selectedPays = 'Cameroun';

  int statChoice = 0;
  PageController statsPageController = PageController();

  void _onItemTapped(int index) {
    if(index==1 && !isLoading){
      //statsPageController.animateToPage(0, duration: Duration(milliseconds: 1000), curve: Curves.linear);
      fetchgarages("");
    }
    setState(() {
      _selectedIndex = index;
    });
  }
  bool userinsState=true;
  bool userpreState=true;

  Point position1 = Point(latitude:3.861536,longitude: 11.486072);
  MapController _mapctl = MapController();


  List<Marker> markers = [];


  final emailText = TextEditingController();
  static List<String> _titlesView = ['Home ','Search', 'Settings'];

  @override
  void initState() {
    deviceType = getDeviceType();
    //selectedPays=allPays[0];
    getKey('language').then((value) => {langage.value = value});
    syncViews();
    SelectedMenu = 'Home';
    var height = BodyHeight();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animation = Tween<double>(begin: 0, end: 300).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Scaffold(
        body: SizedBox.expand(
          child:  isLoading ?
          Center(
              child: CircularProgressIndicator(
                color: UIColors.primaryColor,
              )):
              (isLoading==false && discussions.value.length==0)?
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('You haven\'t started no chat yet, start a new one to enjoy MUNTUR AI !!!',
                        style: AppStyle.txtPoppins(size: 20,color: UIColors.primaryColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ):
          Container(
              padding: getPadding(left: 16,right: 16),
              child:
              ListView.separated(
                separatorBuilder: (context,i){
                  return Container(
                    height: getHorizontalSize(15),
                    width: double.infinity,
                  );
                },
                itemBuilder: (context,index){
                  return
                    widgetDiscussion(
                        disc: discussions.value[index],
                        user: user,
                    );
                }, itemCount: discussions.value.length,
              )
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatView()));
          },
          backgroundColor: UIColors.primaryColor,
          label: const Text('New Chat'),
          icon: const Icon(Icons.add),
        ),
      ),
      SizedBox.expand(
        child:
        Stack(
          children: [
            Container(
              width: BodyWidth(),
              height: BodyHeight() - 110.0,
              // decoration: BoxDecoration(
              //   image: DecorationImage(image: AssetImage(ImageConstant.map),fit: BoxFit.cover),
              // ),
              child: FlutterMap(
                mapController: _mapctl,
                options: MapOptions(
                  center: position1.getLatLng(),
                  zoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key='+API.API_KEY,
                    userAgentPackageName: 'com.steps.davinci.muntuai',
                  ),
                  MarkerLayer(
                    markers: markers,
                  ),
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
              child: Align(
                alignment: Alignment.topCenter,
                child:
                Stack(
                  children: [
                    TextField(
                      controller: emailText,
                      style: AppStyle.txtInter(size: 16),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: UIColors.cursorColor,
                      decoration: InputDecoration(
                        hintText: 'What are you looking for? (garages, service station, technical visit center, etc...)',
                        fillColor: UIColors.primaryAccent,
                        filled: true,
                        border: OutlineInputBorder(
                          gapPadding: 1,
                          borderSide: BorderSide(color: UIColors.primaryAccent),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: UIColors.primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),

                      ),
                    ),
                    Align(alignment: Alignment.topRight,
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: GestureDetector(
                              onTap: (){
                                fetchgarages(emailText.value.text);
                              },
                                child: Icon(Icons.search,color: UIColors.primaryColor,size: 32,)
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child:
              AnimatedContainer(
                width:double.maxFinite,
                height:(showGarages || loadGarages)? height*0.7 : 60 ,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    boxShadow: [BoxShadow()],
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.linear,
                child:
                Stack(
                  children: [
                    Container(
                      margin: getPadding(all: 10),
                      height: 30,
                      child: Row(
                        children: [
                          Spacer(),
                          GestureDetector(
                              onTap: (){
                                setState(() {
                                  showGarages=true;
                                });
                              },
                              child: Text('Results',style: AppStyle.txtInter(size: 20,weight: 'bold'),)
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                showGarages=false;
                                loadGarages=false;
                              });
                            },
                            child:
                            Padding(
                              padding: getPadding(right: 8.0),
                              child: Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    ),
                    loadGarages?
                    Center(
                        child: CircularProgressIndicator(
                          color: UIColors.primaryColor,
                        )):
                    Padding(
                      padding: getPadding(top: 50,left: 10,right: 10),
                      child:
                      ListView(
                        children: [
                          Padding(padding: getPadding(top: 30)),
                          for(var i=0;i<garages.length;i++)
                            widgetGarage(garage: garages[i]),

                        ],
                      ),
                    )
                  ],
                ),

              ),
            ),
          ],
        ),
      ),
      SizedBox.expand(
        child:
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
                  padding: getPadding(
                    top: 17,
                  ),
                  child:
                  FutureBuilder(
                    builder: (ctx, snapshot) {
                      // Checking if future is resolved or not
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If we got an error
                        if (snapshot.hasError) {
                          return Text(
                            "...",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtPoppins(size: 24,weight: 'bold'),
                          );

                          // if we got our data
                        } else if (snapshot.hasData) {
                          // Extracting data from snapshot object
                          final  data = snapshot.data as List<User>;
                          var name=data.isNotEmpty? data[0].nom + ' ' + data[0].prenom : '...';
                          return
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment : MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$name",
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtPoppins(size: 24,weight: 'bold'),
                                ),
                              ],
                            );
                        }
                      }

                      // Displaying LoadingSpinner to indicate waiting state
                      return
                        Text(
                          "...",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtArimoHebrewSubset(size: 24,weight: 'bold'),
                        );
                    },

                    // Future that needs to be resolved
                    // inorder to display something on the Canvas
                    future: API.getUI_user(),
                  )
              ),
              Padding(padding: getPadding(top: 50)),
              Row(
                children: [
                  Icon(Icons.language),
                  Padding(padding: getPadding(left: 8)),
                  Text('Language',
                    style: AppStyle.txtPoppins(size: 20),),
                  Spacer(),
                  ValueListenableBuilder(
                      valueListenable: langage,
                      builder: (context,value,widget){
                        return
                          Text('Français',
                            style: AppStyle.txtPoppins(color: (langage.value=='Français') || (langage.value=='français') ?UIColors.primaryColor:UIColors.blueGray100,size: 16),
                          );
                      }
                  ),
                  Switch(
                    value: lang,
                    activeColor: UIColors.primaryColor,
                    onChanged: (bool value) async {
                      lang=!lang;
                      if (value==false)
                        await saveKey('language', 'Français');
                      else
                        await saveKey('language', 'English');
                      langage.value = await getKey('language');
                      setState(() {
                      });
                    },
                  ),
                  ValueListenableBuilder(
                      valueListenable: langage,
                      builder: (context,value,widget){
                        return
                          Text('English',
                            style: AppStyle.txtPoppins(color: (langage.value=='English')?UIColors.primaryColor:UIColors.blueGray100,size: 16),
                          );
                      }
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.dark_mode),
                  Padding(padding: getPadding(left: 8)),
                  Text('Dark Mode',
                    style: AppStyle.txtPoppins(size: 20),),
                  Spacer(),
                  Switch(
                    value: light,
                    activeColor: UIColors.primaryColor,
                    onChanged: (bool value) {
                      light=!light;
                      setState(() {
                        if (value)
                          UIColors().setDarkMode();
                        else
                          UIColors().setLightMode();
                      });
                    },
                  )
                ],
              ),
              Padding(padding: getPadding(top: 10)),
              Row(
                children: [
                  Icon(Icons.logout),
                  Padding(padding: getPadding(left: 8)),
                  GestureDetector(
                    onTap: (){
                      // _showLogoutDialog(context);
                    },
                    child:
                    Text('Log out',
                      style: AppStyle.txtPoppins(size: 20),),
                  ),
                ],
              ),
              Padding(padding: getPadding(top: 30)),
              Row(
                children: [
                  Icon(Icons.help_rounded),
                  Padding(padding: getPadding(left: 8)),
                  Text('Help',
                    style: AppStyle.txtPoppins(size: 20),),
                  Spacer(),
                ],
              ),
              Padding(padding: getPadding(top: 30)),
              Row(
                children: [
                  Icon(Icons.file_open_sharp),
                  Padding(padding: getPadding(left: 8)),
                  Text('Policy',
                    style: AppStyle.txtPoppins(size: 20),),
                  Spacer(),
                ],
              ),
              Padding(padding: getPadding(top: 30)),
              Row(
                children: [
                  Icon(Icons.group),
                  Padding(padding: getPadding(left: 8)),
                  Text('About us',
                    style: AppStyle.txtPoppins(size: 20),),
                  Spacer(),
                ],
              ),
              Padding(padding: getPadding(top: 30)),
              Row(
                children: [
                  Icon(Icons.grain),
                  Padding(padding: getPadding(left: 8)),
                  Text('Version',
                    style: AppStyle.txtPoppins(size: 20),),
                  Spacer(),
                  Text(appVersion,
                    style: AppStyle.txtPoppins(size: 16,color: UIColors.primaryColor),),
                ],
              ),

            ],
          ),
        ),
      ),
    ];

    return WillPopScope(
        child: Scaffold(
          backgroundColor: UIColors.primaryAccent,
          appBar: AppBar(
            leadingWidth: 90,
            leading: Builder(
                builder: (BuildContext context) {
                  return
                    Stack(
                      children: [
                        // Row(
                        //     children: [
                        //       IconButton(
                        //         icon: Icon(Icons.arrow_back_ios,color: Theme.of(context).primaryColorDark,),
                        //         onPressed: () {
                        //           // Navigator.pop(context);
                        //         },
                        //       ),
                        //     ]
                        // ),

                      ],
                    );

                }) ,
            title:
                Center(
                  child:
                  Text(
                    _titlesView.elementAt(_selectedIndex),
                    style: AppStyle.txtInter(color: Colors.black, weight: 'regular', size: 24),
                  ),
                ),
            backgroundColor: Colors.grey[100],
            elevation: 0,
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: Dimens.padding.w),
                  child: GestureDetector(
                    onTap: ()async{
                      // var selfUser=await API.getUI_user().then((value) => value[0]);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(user:User())));
                      },
                    child:
                    Container(
                      margin: getMargin(all:8),
                      height: getVerticalSize(60,),
                      width: getVerticalSize(60,),
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
                  ),
              )
            ],
          ),
          body: Stack(
            children: [
              _widgetOptions.elementAt(_selectedIndex),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: UIColors.primaryColor,
            unselectedItemColor: UIColors.blueGray100,
            onTap: _onItemTapped,
            selectedLabelStyle: AppStyle.txtInter(size:16),

          ),
        ),
        onWillPop: _onBackPressed);
  }

  bool firstclick = false;

  Future<bool> _onBackPressed() async {
    setState(() {
      _selectedIndex=0;
    });
    if (firstclick == false) {
      firstclick = true;
      toast('clic again to leave',color: UIColors.primaryColor);
      return false;
    } else
      return true;
  }

  void syncViews() async{

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;

    user = await API.getUI_user().then((value) => value[0]);
    await fetchDiscussions();
    isLoading=false;
    setState(() {

    });

    Timer.periodic(Duration(seconds: 10), (timer) async{
      await fetchDiscussions();
    });

  }

  Future<List<Discussion>> fetchDiscussions() async {
    // await API.syncDiscussions();
    // var different=false;
    await API.local_getDiscussion().then((list) => {
        log("discussions count : "+ list.length.toString()),
        discussions.value = list,
    });
    setState(() {

    });
    return discussions.value;
  }

  Future<List<Garage>> fetchgarages(String key) async {
    List<Garage> garages_ = [];
    loadGarages = true;
    var datas=[];
    var results;
    await API.getGaragesAround(key).then((response) => {
      if (response.statusCode == 200)
        {
          results = json.decode(response.body),
          datas = results['data'],
          log(datas.toString()),
          for (var i = 0; i < datas.length; i++)
            {
              garages_.add(Garage(
                id: datas[i]["id"],
                nom: datas[i]['nom'],
                email: datas[i]['email'],
                ville: datas[i]['ville'],
                pays: datas[i]['pays'],
                telephone1: datas[i]['telephone1'],
                telephone2: datas[i]['telephone2'],
                description: datas[i]['description'],
                distance: datas[i]['distance'],
                photo: datas[i]['photo']!='none' ?'http://'+API.Api_+'/api/omc'+datas[i]['photo']:'none',
                longitude: datas[i]['longitude'],
                latitude: datas[i]['latitude'],
              )),
            },

          loadGarages = false,
          showGarages = false,
        }
      else{
        toast("Oups! An error occured during the search , Please try again !",color: Colors.redAccent),
        print(response.body)
      }

    });

    var userPos = await API.getCurrentPosition();
    markers=[];
    setState(() {
      position1 = Point.fromPosition(userPos);
      garages = garages_;
      markers.add(Marker(
        point: Point.fromPosition(userPos).getLatLng(),
        width: 80,
        height: 80,
        builder: (context) => Container(
          child:
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: Center(child: Icon(Icons.man,color: Colors.blue,size: 36,))),
                  ),
                  Text('You',
                    style: AppStyle.txtInter(size: 20,weight: 'b',color: Colors.blue),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,),
                ],
              ),
            ),
        ),
      ));
      garages.forEach((element) {
        markers.add(Marker(
          point: LatLng(element.latitude, element.longitude),
          width: 60,
          height: 100,
          builder: (context) =>
              GestureDetector(
              onTap: () async {
                // var usr = await API.getUI_user().then((value) => value[0]);
                Navigator.push(context, MaterialPageRoute(builder: (context) => GarageDetails(garage: element)));
              },
            child: Container(
              child:
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          color: UIColors.primaryColor,
                          child:Center(child: Icon(Icons.car_repair,size: 36,color: Colors.white,)),)
                    ),
                    Text(element.nom,
                      style: AppStyle.txtInter(size: 20,weight: 'b',color: UIColors.primaryColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),),
          )
        ));
      });
      _mapctl.move(LatLng(position1.latitude,position1.longitude), 12);
    });
    return garages_;
  }
}

class Point{
  double latitude;
  double longitude;
  Point({required this.latitude,required this.longitude});
  getLatLng(){
    return LatLng(this.latitude, this.longitude);
  }
  static final fromPosition = (Position position){
    return Point(latitude:position.latitude, longitude:position.longitude);
  } ;

  static final current = () async {
    var _cur = await API.getCurrentPosition();
    return Point(latitude:_cur.latitude, longitude:_cur.longitude).getLatLng();
  };
}






