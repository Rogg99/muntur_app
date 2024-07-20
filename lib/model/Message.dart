import 'dart:convert';

class UIMessage {
  String id;
  String disc_id;
  String temp_id;
  String emetteur;
  String emetteurName;
  String recepteur;
  String contenu;
  String state;
  String announced;
  String answerTo;
  String media;
  String mediaName;
  String mediaSize;
  num date_envoi;

  UIMessage({
    this.id = "auto",
    this.disc_id = "none",
    this.temp_id = "none",
    this.emetteur = "none",
    this.emetteurName = "none",
    this.recepteur = "none",
    this.contenu = "none",
    this.answerTo = "none",
    this.mediaName = "none",
    this.mediaSize = "none",
    this.announced = "no",
    this.media = "none",
    this.state = 'pending', //pending,sent,received,read,failed
    this.date_envoi = 0,
  });

  factory UIMessage.fromJson(Map<String, dynamic> json) {
    return UIMessage(
        id : json["id"],
        disc_id : json["disc_id"]??json["discussion"],
        emetteur : json["emetteur"],
        recepteur : json["recepteur"]??'none',
        contenu : json["contenu"],
        media : json["media"]??'none',
        answerTo : json["answerTo"]??'none',
        mediaName : json["mediaName"]??'none',
        mediaSize : json["mediaSize"]??'none',
        announced : json["announced"]?? 'no',
        state : json["state"].toString().toLowerCase(),
        date_envoi : json["date_envoi"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'disc_id' : disc_id,
      'temp_id' : temp_id,
      'emetteur' : emetteur,
      'recepteur' : recepteur,
      'contenu' : contenu,
      'state' : state,
      'media' : media,
      'mediaName' : mediaName,
      'mediaSize' : mediaSize,
      'answerTo' : answerTo,
      'date_envoi' : date_envoi,
      'announced' : announced,
    };
  }

  Map<String, dynamic> toMap2() {
    return {
      'id' : id,
      'discussion' : disc_id,
      'temp_id' : temp_id,
      'emetteur' : emetteur,
      'recepteur' : recepteur,
      'contenu' : contenu,
      'state' : state,
      'media' : media,
      'mediaName' : mediaName,
      'mediaSize' : mediaSize,
      'answerTo' : answerTo,
      'date_envoi' : date_envoi,
      'announced' : announced,
    };
  }

  String toJson() {
    return json.encode(this.toMap());
  }
  String toJson2() {
    return json.encode(this.toMap2());
  }

  }
