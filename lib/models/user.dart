import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

UserModel userModelFromMap(String str) => UserModel.fromMap(json.decode(str));

String userModelToMap(UserModel data) => json.encode(data.toMap());

class UserModel {
  UserModel({
    this.id,
    this.firstName = '',
    this.lastName = '',
    this.isDriver = false,
    this.isShop = false,
    this.fullAddress,
    this.phone,
    this.active,
    this.isOnline = false,
    this.isOnRide = false,
    this.onOrderID,
    this.token,
    this.personalData,
    this.balance,
    this.totalBalance,
    this.avatar,
    this.stars,
    this.allStars,
    this.voters,
  });

  String id;
  String firstName;
  String lastName;
  bool isDriver;
  bool isShop;
  String fullAddress;
  String phone;
  int active;
  bool isOnline;
  String token;
  bool isOnRide;
  String onOrderID;
  double balance;
  double totalBalance;
  Map<String, dynamic> personalData;
  String avatar;
  double stars;
  double allStars;
  int voters;

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot docX) {
    Map<String, dynamic> doc = docX.data();
    return UserModel(
      id: docX.id,
      firstName: doc["firstName"],
      lastName: doc["lastName"],
      isDriver: doc["isDriver"] ?? false,
      isShop: doc["isShop"] ?? false,
      fullAddress: doc["fullAddress"],
      phone: doc["phone"],
      active: doc["active"],
      isOnline: doc["isOnline"] ?? false,
      token: doc["token"],
      isOnRide: doc["isOnRide"] ?? false,
      onOrderID: doc["onOrderID"] ?? doc["onOrderId"],
      balance: fixDouble(doc["balance"]),
      totalBalance: fixDouble(doc["totalBalance"]) ?? 0.0,
      personalData: doc["personalData"] ?? {},
      avatar: doc["avatar"],
      allStars: fixDouble(doc["allStars"]),
      stars: fixDouble(doc["stars"]),
      voters: doc["voters"] ?? 0,
    );
  }


  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    isDriver: json["isDriver"],
    isShop: json["isShop"],
    fullAddress: json["fullAddress"],
    phone: json["phone"],
    active: json["active"],
    isOnline: json["isOnline"] ?? false,
    token: json["token"],
    isOnRide: json["isOnRide"] ?? false,
    onOrderID: json["onOrderID"],
    balance: fixDouble(json["balance"]),
    totalBalance: json["totalBalance"] ?? 0.0,
    personalData: json["personalData"] ?? {},
    avatar: json["avatar"],
    allStars: fixDouble(json["allStars"]),
    stars: fixDouble(json["stars"]),
    voters: json["voters"] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "isDriver": isDriver,
    "isShop": isShop,
    "fullAddress": fullAddress,
    "phone": phone,
    "active": active,
    "isOnline": isOnline ?? false,
    "isOnRide": isOnRide ?? false,
    "onOrderID": onOrderID,
    "balance": balance ?? 0.0,
    "totalBalance": totalBalance ?? 0.0,
    "personalData": personalData ?? {},
    "avatar": avatar,
    "allStars": allStars,
    "stars": stars,
    "voters": voters,
  };

}


double fixDouble(var number) {
  if(number != null) {
    String n = number.toString();
    if(n.isEmpty || n == null) {
      return 0;
    } else {
      double re = double.tryParse(n);
      if(re == null) {
        return 0;
      } else {
        return re;
      }
    }
  } else {
    return 0;
  }
}