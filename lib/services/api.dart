import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/core/theming/app_style.dart';
import 'package:munturai/model/Discussion.dart';
import 'package:munturai/model/Message.dart';
import 'package:munturai/model/Info.dart';
import 'package:munturai/model/Token.dart';
import 'package:munturai/model/User.dart';
import 'package:munturai/screen/home.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../model/filter.dart';

class Api {
  String Api_ =  "192.168.43.31:8000"; //"munturai.steps4u.net";//"192.168.1.137:4000";//"http://muntur.steps4u.net/m/muntur";
  String userApi_ = "http://munturai.steps4u.net/auth";//"http://192.168.1.137:2000";//"http://muntur.steps4u.net/auth";
  late String authorization = "Bearer ";
  late Future<Database> database = CreateLocalDB();

  String API_KEY = "AIzaSyAj4X5IVwHuf9bFG_3ICyIgdUMgUwik3CM";

  void Notifify(String title, String message, { bool foreground=true,String payload='payload'}) {
    // this will be used as notification channel id
    const notificationChannelId = 'my_foreground';
    // this will be used for notification id, So you can update your custom notification with this id.
    const notificationId = 888;
    DartPluginRegistrant.ensureInitialized();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          'muntur Notification Channel',
          icon: '@mipmap/launcher_icon',
          ongoing: false,
          importance: Importance.defaultImportance,
          actions: [
            AndroidNotificationAction('1', 'Fermer'),
            AndroidNotificationAction('2', 'Voir',titleColor: Colors.green,showsUserInterface: true),
          ]
        ),
      ),
      payload: 'payload'
    );
  }

  Future<http.Response> signup(User user) async {
    var url = Uri.parse('http://$Api_/m/muntur/user/add');
    var body = user.toJson2();
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> updateUser(User user) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.parse('http://$Api_/m/muntur/user/set');
    var body = user.toJson2();
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> setPassword(String old,String newp) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.parse('$userApi_/user/setpassword');
    var body = json.encode({
      'oldpassword':old,
      'newpassword':newp
    });
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> login(String email, String password) async {
    //var url = Uri.parse('http://www.google.com');
    var url = Uri.parse('http://$Api_/m/muntur/token');
    log(url.toString());
    var body = json.encode({"email": email, "password": password});
    var headers = {
      "Content-Type": "application/json",
    };
    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getProfile(String id) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url=Uri.parse('http://$Api_/m/muntur/user/get?id=$id');
    log(url.toString());
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(
      url,
      headers: headers,
    ).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getUserRegistration(String id) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url=Uri.parse('http://$Api_/m/muntur/user/verifyregistration?id=$id');
    log(url.toString());
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(
      url,
      headers: headers,
    ).then((http.Response response){
      return response;
    });
  }

  Future<http.Response> getProfileWithEmail(String email,String password,String token) async {
    authorization = 'Bearer ' + token;
    var url=Uri.parse('http://$Api_/m/muntur/user/getwithemail?email=$email&password=$password');
    log(url.toString());
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http
        .get(
      url,
      headers: headers,
    )
        .then((http.Response response) {
      return response;
    });
  }


  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return (await Geolocator.getCurrentPosition());//?? await Geolocator.getLastKnownPosition();
  }

  Future<http.Response> getGaragesAround(String key) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var currentPosition = await getCurrentPosition();

    var body = json.encode({
      "longitude": currentPosition.longitude,
      "latitude": currentPosition.latitude,
      "key":key,
    });

    var url = Uri.http('$Api_', 'm/muntur/garages/around/get');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> askAI(UIMessage message) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var body = message.toJson2();
    log(body.toString());
    var url = Uri.http('$Api_', 'm/muntur/request');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }


  Future<http.Response> getMessage(String id) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var body = {"id": id,'user_id': 'none'};
    var url = Uri.http('$Api_', 'm/muntur/message/get',body);
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getMessagesFromDisc({String disc_id='none',int time=0}) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    user = await getUI_user().then((value) =>value[0]);
    var body = {"id": disc_id,"user_id": user.id,'time':time.toString()};
    var url = Uri.http('$Api_', 'm/muntur/messages/discussion/get',body);
    //log(url.toString());
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> markMessagesAsRead(String disc_id) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var body = json.encode({"disc_id": disc_id});
    var url = Uri.http('$Api_', 'm/muntur/messages/discussion/markasread');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> createMessage(UIMessage message) async {
    message.state = 'sent';
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.http('$Api_', 'm/muntur/message/add');
    print(url.toString());
    var body = message.toJson();
    var fileUploaded = false;
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    if (message.media != 'none' && message.media != ''){
      var urlUp = Uri.http('$Api_', 'm/muntur/uploadfile');
      print('uploading file to ' + urlUp.toString());
      var requestUpload = new http.MultipartRequest("PUT", urlUp);
      requestUpload.headers["Authorization"] = authorization;
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath('document', message.media);
      Directory directory = await getApplicationDocumentsDirectory();
      File newImage = await File(message.media).copy(directory.path+
          '/muntur_'+DateTime.now().millisecondsSinceEpoch.toInt().toString()+message.media.split('.').last);
      requestUpload.files.add(multipartFile);
      File media = File(message.media);
      await requestUpload.send().then((response) async =>{
        if (response.statusCode==200){
          message.mediaSize = convertSize(await media.length()),
          message.mediaName = message.media.split('/').last,
          body = message.toJson(),
          fileUploaded=true,
        }
        else{
          print(response.stream.bytesToString()),
        }
      });
    }
    if (message.media != 'none' && fileUploaded)
      return http.put(url, headers: headers, body: body).then((http.Response response) {
        return response;
      });
    else if (message.media == 'none')
      return http.put(url, headers: headers, body: body).then((http.Response response) {
        return response;
      });
    else {
      http.Response resp = http.Response('Upload Failed',500);
      return resp;
    }
  }

  String convertSize(int size){
    if(size/1024<1024)
      return (size/1024).toStringAsFixed(2) + 'Kb';
    else
      return (size/(1024*1024)).toStringAsFixed(2) + 'Mb';
  }

  Future<http.Response> createDiscussion(String disc) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.http('$Api_', 'm/muntur/discussion/add');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};

    return http.put(url, headers: headers, body: disc).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> updateDiscussion(String body) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.http('$Api_', 'm/muntur/discussion/add');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};

    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getDiscussions(String id_user) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var body = {"id": id_user};
    var url = Uri.http('$Api_', 'm/muntur/discussions/user/get',body);
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> updateInfo(String body) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.http('$Api_', 'm/muntur/info/set');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getInfos() async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var body = {'id':await getUI_user().then((value) => value[0].id),'time':'0'};
    var url = Uri.http('$Api_', 'm/muntur/infos/get',body);
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getInfo(String id) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var body = {"id": id,'user':await getUI_user().then((value) => value[0].id)};
    var url = Uri.http('$Api_', 'm/muntur/bv/info/get',body);
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }

  Future<http.StreamedResponse> updateUserPhoto(String path) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.http('$Api_', 'm/muntur/user/setphoto');
    var request = new http.MultipartRequest("POST", url);
    request.fields['id'] = await getUI_user().then((value) => value[0].id);
    var splits = path.split('/');
    request.fields['photo'] = path.split('/')[splits.length-1];

    http.MultipartFile multipartFile = await http.MultipartFile.fromPath('image', path);
    request.files.add(multipartFile);
    request.headers["Authorization"] = authorization;
    return request.send().then((response) {
      return response;
    });
  }

  Future<File> downloadUserPhoto() async {
    print('downloading file');
    var photo = await getUI_user().then((value) => value[0].photo);
    print(photo);
    var httpClient = new HttpClient();
    var url = Uri.http('$Api_', 'm/muntur/'+photo);
    var request = await httpClient.getUrl(url);
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/'+photo.split('/').last);
    await file.writeAsBytes(bytes);
    print(file.path);
    return file;
  }

  Future<File> downloadMedia(String photo) async {
    print('downloading file');
    var httpClient = new HttpClient();
    var url = Uri.http('$Api_', 'm/muntur/'+photo);
    var request = await httpClient.getUrl(url);
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/'+photo.split('/').last);
    try{
    await file.writeAsBytes(bytes);
    return file;
    }
    on Exception catch (e){
      return File('');
    }
  }

  Future<http.Response> createComment(String body) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.http('$Api_', 'm/muntur/info/comment/add');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};

    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> updateComment(String body) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.http('$Api_', 'm/muntur/info/comment/update');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};

    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> removeComment(String id) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var body={
      'id':id
    };
    var url = Uri.http('$Api_','m/muntur/info/comment/remove',body);
    log(url.toString());
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }


  Future<http.Response> like(String body) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var url = Uri.http('$Api_', 'm/muntur/info/reaction/add');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};

    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> unLike(String id) async {
    authorization = await getTokens().then((value) => 'Bearer ' + value[0].access);
    var body={
      'id':id
    };
    var url = Uri.http('$Api_','m/muntur/info/reaction/remove',body);
    log(url.toString());
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url, headers: headers).then((http.Response response) {
      return response;
    });
  }


  Future<http.Response> getTokenAgora(String channelName, String uid, {int expirationTime = 3600*24}) async {
    var url = Uri.parse('https://agora-token-service-production-0cf9.up.railway.app/getToken');
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    var body = json.encode({
      "tokenType": "rtc",
      "channel": channelName,
      "role": "publisher", // "publisher" or "subscriber"
      "uid": uid,
      "expire": expirationTime // optional: expiration time in seconds (default: 3600)
    });
    return http.put(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  
  Future<Database> CreateLocalDB() async {

    if (kIsWeb) {
      var databaseFactory = databaseFactoryFfiWeb;
      WidgetsFlutterBinding.ensureInitialized();
      try {
        log('muntur DEBUG: local database already existing');
        return databaseFactory.openDatabase(join(await databaseFactory.getDatabasesPath(), 'userData.db'));
      } on Exception catch (e) {
        final database = databaseFactory.openDatabase(
          join(await databaseFactory.getDatabasesPath(), 'userData.db'),
        );
        return database;
      }
    }

    WidgetsFlutterBinding.ensureInitialized();
    try {
      log('muntur DEBUG: local database already existing');
      return openDatabase(join(await getDatabasesPath(), 'userData.db'));
    } on Exception catch (e) {
      final database = openDatabase(
        join(await getDatabasesPath(), 'userData.db'),
      );
      return database;
    }
  }

  Future<bool> createTables() async {
    if(kIsWeb)
      {
        var databaseFactory = databaseFactoryFfiWeb;
        databaseFactory. openDatabase(join(await databaseFactory.getDatabasesPath(), 'userData.db')).then((db) => {
          log('muntur DEBUG:  creating local database tables'),
          db.execute(
              'CREATE TABLE User(id TEXT PRIMARY KEY, email TEXT,nom TEXT,prenom TEXT,sexe TEXT,date_naissance INTEGER'
                  ',telephone TEXT,photo TEXT,type TEXT,ville TEXT,pays TEXT)')
              .then((value) => log('muntur DEBUG: User table created')),

          db.execute(
              'CREATE TABLE Token(id INTEGER PRIMARY KEY, access TEXT,refresh TEXT,email TEXT,password TEXT,time INTEGER)')
              .then((value) => log('muntur DEBUG: Token table created')),
          db.execute(
              'CREATE TABLE Discussion(id TEXT PRIMARY KEY, initiateur TEXT,interlocuteur TEXT,last_message TEXT,last_date INTEGER,last_check INTEGER,last_writer TEXT, title TEXT, photo TEXT, type TEXT)')
              .then((value) => log('muntur DEBUG: Discussion table created')),
          db.execute(
              'CREATE TABLE Message(id TEXT PRIMARY KEY, temp_id TEXT, disc_id TEXT,emetteur TEXT,recepteur TEXT,contenu TEXT,state TEXT,media TEXT,mediaName TEXT,mediaSize TEXT,answerTo TEXT,date_envoi INTEGER,announced TEXT)')
              .then((value) => log('muntur DEBUG: Message table created')),
        });
      }
    else
    openDatabase(join(await getDatabasesPath(), 'userData.db')).then((db) => {
          log('muntur DEBUG:  creating local database tables'),

          db.execute(
                  'CREATE TABLE User(id TEXT PRIMARY KEY, email TEXT,nom TEXT,prenom TEXT,sexe TEXT,date_naissance INTEGER'
                      ',telephone TEXT,photo TEXT,type TEXT,ville TEXT,pays TEXT)')
              .then((value) => log('muntur DEBUG: User table created')),
          db.execute(
                  'CREATE TABLE Token(id INTEGER PRIMARY KEY, access TEXT,refresh TEXT,email TEXT,password TEXT,time INTEGER)')
              .then((value) => log('muntur DEBUG: Token table created')),
          db.execute(
              'CREATE TABLE Discussion(id TEXT PRIMARY KEY, initiateur TEXT,interlocuteur TEXT,last_message TEXT,last_check INTEGER,last_date INTEGER,last_writer TEXT, title TEXT, photo TEXT, type TEXT)')
              .then((value) => log('muntur DEBUG: Discussion table created')),
          db.execute(
              'CREATE TABLE Message(id TEXT PRIMARY KEY, temp_id TEXT, disc_id TEXT,emetteur TEXT,recepteur TEXT,contenu TEXT,state TEXT,media TEXT,mediaName TEXT,mediaSize TEXT,answerTo TEXT,date_envoi INTEGER,announced TEXT)')
              .then((value) => log('muntur DEBUG: Message table created')),
        });
    return true;
  }

  Future<bool> createTableUser() async {
    if(kIsWeb)
    {
      var databaseFactory = databaseFactoryFfiWeb;
      databaseFactory. openDatabase(join(await databaseFactory.getDatabasesPath(), 'userData.db')).then((db) => {
        log('muntur DEBUG:  creating local database table User'),
        db.execute(
            'CREATE TABLE User(id TEXT PRIMARY KEY, email TEXT,nom TEXT,prenom TEXT,sexe TEXT,date_naissance INTEGER'
                ',telephone TEXT,photo TEXT,type TEXT,ville TEXT,pays TEXT)')
            .then((value) => log('muntur DEBUG: User table created')),
      });
    }
    else
      openDatabase(join(await getDatabasesPath(), 'userData.db')).then((db) => {
        log('muntur DEBUG:  creating local database table User'),
        db.execute(
            'CREATE TABLE User(id TEXT PRIMARY KEY, email TEXT,nom TEXT,prenom TEXT,sexe TEXT,date_naissance INTEGER'
                ',telephone TEXT,photo TEXT,type TEXT,ville TEXT,pays TEXT)')
            .then((value) => log('muntur DEBUG: User table created')),
      });
    return true;
  }

  Future<bool> verifyConnexionStatus() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> syncProfile() async {
    log('DEBUG muntur: syncing datas');
    if (await verifyConnexionStatus()) {
      log('DEBUG muntur: Network Status OK');
      var results;
      bool is_in = false;
      List<User> updatedListUser;
      User user;
      await getProfile(await getUI_user().then((value) => value[0].id)).then((response) async => {
            if (response.statusCode == 200)
              {
                results = json.decode(response.body)['data'] as Map,
                //log(results.toString()),
                user = User(
                    id : results["id"],
                    nom : results["nom"],
                    prenom : results["prenom"],
                    sexe : results["sexe"],
                    date_naissance : results["date_naissance"],
                    telephone : results["telephone"],
                    email : results["email"],
                    photo : results["photo"],
                    type : results["type"],
                    ville : results["ville"],
                    pays : results["pays"],
                ),
                updatedListUser = await getUI_user().then((value) => value),
                if (updatedListUser.isEmpty)
                  {log("DEBUG muntur : inserting new local user "), await insertUIUser(user)}
                else
                  {
                    is_in = false,
                    for (var ie = 0; ie < updatedListUser.length; ie++)
                      {
                        if (updatedListUser[ie].id == user.id)
                          {
                            is_in = true,
                          }
                      },
                    if (is_in)
                      {
                        await updateUIUser(user).then((value) => {
                              log("DEBUG muntur : updating user succeed"),
                            }),
                        if(user.photo != updatedListUser[0].id && user.photo!="none" && user.photo!="None" && user.photo.isNotEmpty)
                          await downloadUserPhoto(),
                      }
                    else
                      {
                        log("DEBUG muntur : inserting new local user "),
                        await insertUIUser(user),
                        if(user.photo!="none" && user.photo!="None" && user.photo.isNotEmpty)
                        await downloadUserPhoto(),
                      }
                  },
              }
          });
    }
  }

  Future<void> syncDiscussions() async {
    //log('DEBUG muntur: syncing discussions');
    if (await verifyConnexionStatus()) {
      //log('DEBUG muntur: Network Status OK');
      var results;
      var done;
      List<Discussion> discs = [];
      bool is_in = false;
      List<Discussion> updatedListDiscussions;
      await getDiscussions(await getUI_user().then((value) => value[0].id)).then((response) async => {
        //log("DEBUG muntur : "+response.body),
        if (response.statusCode == 200)
          {
            results = json.decode(response.body),
            done = results['data'],
            for (var i = 0; i < done.length; i++)
              {
                discs.add(Discussion(
                  id: done[i]["id"],
                  initiateur : done[i]["initiateur"],
                  interlocuteur : done[i]["interlocuteur"],
                  last_message : done[i]["last_message"],
                  last_date : done[i]["last_date"],
                  last_writer : done[i]["last_writer"],
                  title : done[i]["title"],
                  photo : done[i]["photo"]??'none',
                  type : done[i]["type"]
                )),
              },
            for (var i = 0; i < discs.length; i++)
              {
                updatedListDiscussions = await local_getDiscussion().then((value) => value),
                if (updatedListDiscussions.isEmpty)
                  {//log("DEBUG muntur : inserting new local event "),
                    await local_insertDiscussion(discs[i])}
                else
                  {
                    is_in = false,
                    for (var ie = 0; ie < updatedListDiscussions.length; ie++)
                      {
                        if (updatedListDiscussions[ie].id == discs[i].id)
                          {
                            is_in = true,
                          }
                      },
                    if (is_in)
                      {
                        await local_updateDiscussion(discs[i]).then((value) => {
                          //log("DEBUG muntur : updating discussion succeed"),
                        }),
                      }
                    else
                      {
                        //log("DEBUG muntur : inserting new local discussion "),
                        await local_insertDiscussion(discs[i]),
                      }
                  }
              },
            updatedListDiscussions = await local_getDiscussion().then((value) => value),
            for (var ie = 0; ie < updatedListDiscussions.length; ie++)
              {
                is_in = false,
                for (var ia = 0; ia < discs.length; ia++)
                  {
                    if (updatedListDiscussions[ie].id == discs[ia].id)
                      {
                        is_in = true,
                      }
                  },
                if (is_in == false)
                  {
                    await local_deleteDiscussion(updatedListDiscussions[ie]).then((value) => {
                      log("DEBUG muntur : deleting discussion succeed"),
                    }),
                  }
              }
          }
      });
    }
  }

  Future<void> syncMessages() async {
    //log('DEBUG muntur: syncing Messages');
    if (await verifyConnexionStatus()) {
     // log('DEBUG muntur: Network Status OK');
      var results;
      var done;

      List<UIMessage> messages = [];
      List<User> users = [];
      bool is_in = false;
      var idx=0;
      var selfUser=await getUI_user().then((value) => value[0]);

      List<UIMessage> updatedListMessages;
      await local_getDiscussion().then((discs)  async => {
        for (var i = 0; i < discs.length; i++){
          await getMessagesFromDisc(disc_id:discs[i].id,time: (await getLastTimeDisc(discs[i].id)+12)).then((response) async => {
            //log(response.body.toString()),
            if (response.statusCode == 200)
              {
                results = json.decode(response.body),
                done = results['data'],
                for (var i = 0; i < done.length; i++)
                  {
                    messages.add(UIMessage(
                      id : done[i]["id"],
                      disc_id : done[i]["disc_id"],
                      temp_id : done[i]["temp_id"],
                      emetteur : done[i]["emetteur"],
                      emetteurName : done[i]["emetteurName"],
                      recepteur : done[i]["recepteur"],
                      contenu : done[i]["contenu"],
                      media : done[i]["media"],
                      answerTo : done[i]["answerTo"],
                      mediaName : done[i]["mediaName"],
                      state : done[i]["is_read"]==true?'read':'sent',
                      date_envoi : done[i]["creation_date"]??0,
                    )),
                  },
                updatedListMessages = await local_getMessage().then((value) => value),
                for (var i = 0; i < messages.length; i++)
                  {
                    if (updatedListMessages.isEmpty)
                      {log("DEBUG muntur : inserting new local message "),
                        await local_insertMessage(messages[i])
                      }
                    else
                      {
                        is_in = false,
                        idx=-1,
                        for (var ie = 0; ie < updatedListMessages.length; ie++)
                          {
                            if (updatedListMessages[ie].id == messages[i].id || updatedListMessages[ie].id == messages[i].temp_id )
                              {
                                is_in = true,
                                idx=ie,
                              }
                          },
                        if (is_in)
                          {
                            if(updatedListMessages[idx].id == messages[i].temp_id)
                              await local_updateMessage(messages[i],id: updatedListMessages[idx].id).then((value) => {
                                log("DEBUG muntur : updating message succeed"),
                              }),
                            if( messages[i].emetteur != selfUser.id && updatedListMessages[idx].announced =='no'){
                              Notifify(messages[i].emetteurName, messages[i].contenu),
                              messages[i].announced='yes',
                              log("DEBUG muntur : announcing message"),
                              await local_updateMessage(messages[i]).then((value) => {
                                log("DEBUG muntur : updating message succeed"),
                              })
                            },
                            if(updatedListMessages[idx].state !='delete' && updatedListMessages[idx].state != messages[i].state)
                              await local_updateMessage(messages[i]).then((value) => {
                                log("DEBUG muntur : updating message succeed"),
                              }),
                          }
                        else
                          {
                            log("DEBUG muntur : inserting new local message "),
                            await local_insertMessage(messages[i]),
                          }
                      }
                  },
              }
          }),
        },
        //print(((DateTime.now().millisecondsSinceEpoch)~/1000).toString()),
        await saveKey('last_update', ((DateTime.now().millisecondsSinceEpoch)~/1000).toString()),
      });
    }
  }

  Future<void> syncData() async {
    log('DEBUG muntur: syncing datas');
    if (await verifyConnexionStatus()) {
      log('DEBUG muntur: Network Status OK');
      // await syncDiscussions();
      // await syncMessages();
      await syncProfile();
    }
    else{
      log('DEBUG muntur: Network Status : No network');
      toast('No network, please check your internet');
    }
  }

  Future<Timer> keepTokenAlive({bool force = false}) async {
    Token token;
    log('DEBUG muntur: keeping Token Alive');
    try {
      token = await getTokens().then((list) => list[0]);
      int duration = 0;
      if (!force) duration = (token.time - DateTime.now().millisecondsSinceEpoch / 1000).floor() - 10;
      Timer timer = Timer(Duration(seconds: duration), () {
        login(token.email, token.password).then((resp) => {
              if (resp.statusCode == 200)
                {
                  duration = 3600,
                  token.access = Token.fromJson(jsonDecode(resp.body)).access,
                  token.refresh = Token.fromJson(jsonDecode(resp.body)).refresh,
                  token.time = 24 * 3600 + DateTime.now().millisecondsSinceEpoch / 1000,
                  updateToken(token),
                  Timer.periodic(Duration(seconds: duration), (Timer timer) {
                    log('DEBUG muntur: keeping Token Alive for 1 day');
                    login(token.email, token.password).then((resp) => {
                          if (resp.statusCode == 200)
                            {
                              duration = 3600,
                              token.access = Token.fromJson(jsonDecode(resp.body)).access,
                              token.refresh = Token.fromJson(jsonDecode(resp.body)).refresh,
                              token.time = 24 * 3600 + DateTime.now().millisecondsSinceEpoch / 1000,
                              updateToken(token),
                              log('DEBUG muntur: token refreshed successfully for 24 hours next refresh time on : ' +
                                  token.time.toString()),
                            }
                        });
                  }),
                }
            });
      });
      return timer;
    } on Exception catch (error) {
      return Timer(Duration.zero, () {
        log('DEBUG muntur : No token stored in local database');
      });
    }
  }

  //UI_user operations
  Future<void> insertUIUser(User user) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'User',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('muntur DEBUG: inserting user in local database');
  }

  Future<int> getLastTimeDisc(String id) async {
    int time = 0;
    var list = await local_getMessagesFromDisc(id);
    list.forEach((element) {
      if(element.date_envoi.toInt()>time)
        time = element.date_envoi.toInt();
    });
    return time;
  }

  Future<bool> updateUIUser(User user) async {
    final db = await database;
    try {
      // Update the given Dog.
      await db.update(
        'User',
        user.toMap(),
        // Ensure that the Dog has a matching id.
        where: 'id = ?',
        // Pass the Dog's id as a whereArg to prevent SQL injection.
        whereArgs: [user.id],
      );
      return true;
    } on DatabaseException catch (e) {
      return false;
    }
  }

  Future<List<User>> getUI_user() async {
    // Get a reference to the database.
    final db = await database;
    //log('muntur DEBUG: getting users in local database');
    // Query the table for all The Dogs.
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'User',
        limit: 1,
      );
      return List.generate(maps.length, (i) {
        //print(maps[i].toString());
        return User(
            id : maps[i]["id"],
            nom : maps[i]["nom"],
            prenom : maps[i]["prenom"],
            sexe : maps[i]["sexe"],
            date_naissance :maps[i]["date_naissance"],
            telephone : maps[i]["telephone"],
            email : maps[i]["email"],
            photo : maps[i]["photo"],
            type : maps[i]["type"],
            ville : maps[i]["ville"],
            pays : maps[i]["pays"],
        );
      });
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<void> clearUserDatas() async {
    final db = await database;
    log('deleting user datas...');
    int countU = await db.rawDelete("DELETE FROM User");
    int countT = await db.rawDelete("DELETE FROM Token");
    int countD = await db.rawDelete("DELETE FROM Discussion");
    int countM = await db.rawDelete("DELETE FROM Message");
    log('deleting user datas finished with $countU - $countT - $countD - $countM');
  }
  //Tokens operations
  Future<void> insertToken(Token token) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'Token',
      token.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('muntur DEBUG: inserting token in local database');
  }

  Future<void> updateToken(Token token) async {
    final db = await database;
    // Update the given Dog.
    await db.update('Token', token.toMap(),
        // Ensure that the Dog has a matching id.
        where: 'id = 1');

    log('muntur DEBUG: updating token in local database');
  }

  Future<List<Token>> getTokens() async {
    final db = await database;
    //log('muntur DEBUG: getting tokens in local database');
    final List<Map<String, dynamic>> maps = await db.query('Token');
    return List.generate(maps.length, (i) {
      return Token(
        access: maps[i]['access'],
        refresh: maps[i]['refresh'],
        email: maps[i]['email'],
        password: maps[i]['password'],
        time: maps[i]['time'].toDouble(),
      );
    });
  }

  //Discussion operations
  Future<void> local_insertDiscussion(Discussion disc) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'Discussion',
      disc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('muntur DEBUG: inserting event in local database');
  }

  Future<bool> local_updateDiscussion(Discussion disc) async {
    final db = await database;
    //log('muntur DEBUG: updating disc in local database');
    try {
      await db.update(
        'Discussion',
        disc.toMap(),
        // Ensure that the Dog has a matching id.
        where: 'id = ?',
        // Pass the Dog's id as a whereArg to prdisc SQL injection.
        whereArgs: [disc.id],
      ).whenComplete(() async => {
            //log('muntur DEBUG: discussion members count :' + await local_getDiscussion().then((value) => value.length.toString())),
          });
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<List<Discussion>> local_getDiscussion() async {
    // Get a reference to the database.
    final db = await database;
    //log('muntur DEBUG: getting events in local database');
    try {
      final List<Map<String, dynamic>> maps = await db.query('Discussion');
      return List.generate(maps.length, (i) {
        return Discussion(
            id : maps[i]["id"],
            initiateur : maps[i]["initiateur"],
            interlocuteur : maps[i]["interlocuteur"],
            last_message : maps[i]["last_message"],
            photo : maps[i]["photo"],
            last_date : maps[i]["last_date"],
            last_writer : maps[i]["last_writer"],
            title : maps[i]["title"],
            last_check : maps[i]["last_check"],
            type : maps[i]["type"]
        );
      });
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<List<Discussion>> local_getDiscussionId(String id) async {
    // Get a reference to the database.
    final db = await database;
    //log('muntur DEBUG: getting events in local database');
    try {
      final List<Map<String, dynamic>> maps = await db.query('Discussion');
      var l= List.generate(maps.length, (i) {
          return Discussion(
              id : maps[i]["id"],
              initiateur : maps[i]["initiateur"],
              interlocuteur : maps[i]["interlocuteur"],
              last_message : maps[i]["last_message"],
              last_date : maps[i]["last_date"],
              photo : maps[i]["photo"],
              last_writer : maps[i]["last_writer"],
              title : maps[i]["title"],
              last_check : maps[i]["last_check"],
              type : maps[i]["type"]
          );
      });
      List<Discussion> found=[];
      l.forEach((element) {
        if(element.id==id)
          found.add(element);
      });
      return found;
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<bool> local_deleteDiscussion(Discussion disc) async {
    final db = await database;
    log('muntur DEBUG: updating disc in local database');
    try {
      await db.delete(
        'Discussion',
        where: 'id = ?',
        whereArgs: [disc.id],
      );
    } on DatabaseException catch (e) {
      return false;
    }
    return true;
  }

  //Message operations
  Future<void> local_insertMessage(UIMessage mes) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'Message',
      mes.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    ).whenComplete(() async => {
      log('message added successfully'),
      //log('muntur DEBUG: message members count :' + await local_getMessage().then((value) => value.length.toString())),
    });
    log('muntur DEBUG: inserting message in local database');
  }

  Future<bool> local_updateMessage(UIMessage mes,{String id='none'}) async {
    final db = await database;
    log('muntur DEBUG: updating message in local database');
    try {
        await db.update(
          'Message',
          mes.toMap(),
          // Ensure that the Dog has a matching id.
          where: 'id = ?',
          // Pass the Dog's id as a whereArg to prmes SQL injection.
          whereArgs: [mes.id],
        ).whenComplete(() async => {
          log('message updated successfully'),
        });
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<List<UIMessage>> local_getMessageDetail(String id) async {
    // Get a reference to the database.
    final db = await database;
    //log('muntur DEBUG: getting events in local database');
    try {
      final List<Map<String, dynamic>> maps = await db.query('Message');
      var L = List.generate(maps.length, (i) {
        return UIMessage(
            id : maps[i]["id"],
            temp_id :  maps[i]["temp_id"],
            disc_id :  maps[i]["disc_id"],
            emetteur :  maps[i]["emetteur"],
            recepteur :  maps[i]["recepteur"],
            contenu :  maps[i]["contenu"],
            state :  maps[i]["state"],
            date_envoi :  maps[i]["date_envoi"],
        );
      });
      List<UIMessage> res = [];
      for(var i=0;i<L.length;i++)
        if(L[i].id==id){
          res.add(L[i]);
          break;
        }
      return res;
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<List<UIMessage>> local_getMessage() async {
    // Get a reference to the database.
    final db = await database;
    //log('muntur DEBUG: getting events in local database');
    try {
      final List<Map<String, dynamic>> maps = await db.query('Message');
      return List.generate(maps.length, (i) {
        return UIMessage(
          id : maps[i]["id"],
          disc_id :  maps[i]["disc_id"],
          emetteur :  maps[i]["emetteur"],
          emetteurName :  maps[i]["emetteurName"]??"none",
          recepteur :  maps[i]["recepteur"],
          media :  maps[i]["media"],
          mediaName :  maps[i]["mediaName"],
          mediaSize :  maps[i]["mediaSize"],
          contenu :  maps[i]["contenu"],
          state :  maps[i]["state"],
          date_envoi :  maps[i]["date_envoi"],
        );
      });
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<List<UIMessage>> local_getMessagesFromDisc(String disc_id) async {
    // Get a reference to the database.
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('Message');
      //log('muntur DEBUG: message members count :' + await local_getMessage().then((value) => value.length.toString()));
      var L= List.generate(maps.length, (i) {
        return UIMessage(
          id : maps[i]["id"],
          disc_id :  maps[i]["disc_id"],
          emetteur :  maps[i]["emetteur"],
          emetteurName :  maps[i]["emetteurName"]??'none',
          recepteur :  maps[i]["recepteur"],
          media :  maps[i]["media"],
          mediaName :  maps[i]["mediaName"],
          mediaSize :  maps[i]["mediaSize"],
          contenu :  maps[i]["contenu"],
          state :  maps[i]["state"],
          date_envoi :  maps[i]["date_envoi"],
        );
      });
      List<UIMessage> result=[];
      for (var i=0;i<L.length;i++){
        if (L[i].disc_id==disc_id)
          result.add(L[i]);
      }
      return result;
    } on Exception catch (e) {
      //createTables();
      return [];
    }
  }

  Future<bool> local_deleteMessage(UIMessage mes) async {
    final db = await database;
    log('muntur DEBUG: updating mes in local database');
    try {
      await db.delete(
        'Message',
        where: 'id = ?',
        whereArgs: [mes.id],
      );
    } on DatabaseException catch (e) {
      return false;
    }
    return true;
  }

}
