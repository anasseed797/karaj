/*
    int orderType; // orderType : (1 : pick up only | 2 : pick up and ... )

    int vehicleType; // (1 : van | 2 : pick up)


    int status; // (
    0 : opening |
    1 : searching for driver |
    2 : get driver |
    3 : confirmed |
    4 : driver at home |
    5 : pickedup `|
    9 : delivered |
    97 : canceled
    99 : closed)
  double totalPrice; // distanceTotalPrice + vehiclePrice + pickUpFrom + pickUpTo + numberOfWorkers


  TOTAL PRICE :

  startCounting : depend on the distance

  price per km : distance.inKM * pricePerOneKm

  vehiclePrice :

  number of workers:

  fromFloor :

  toFloor



   */
// To parse this JSON data, do
//
//     final orderModel = orderModelFromMap(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;

OrderModel orderModelFromMap(String str) => OrderModel.fromMap(json.decode(str));

String orderModelToMap(OrderModel data) => json.encode(data.toMap());

class OrderModel {
  OrderModel({
    this.id,
    this.orderType,
    this.orderTypeString,
    this.userId,
    this.userName,
    this.userPhone,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverAvatar,
    this.driverLat,
    this.driverLng,
    this.fromFullAddress,
    this.fromLat,
    this.fromLng,
    this.toFullAddress,
    this.toLat,
    this.toLng,
    this.vehicleType,
    this.vehicleName,
    this.vehicleImage,
    this.vehiclePrice,
    this.distance,
    this.distanceStartPrice,
    this.distancePrice,
    this.distanceTotalPrice,
    this.numberOfPieces,
    this.numberOfWorkers,
    this.fromFloorString,
    this.toFloorString,
    this.fromFloor,
    this.toFloor,
    this.payCash,
    this.payed,
    this.payVia,
    this.paymentId,
    this.status,
    this.totalPrice,
    this.polylineEndpoint,
    this.totalDuration,
    this.plateNumber,
    this.reasonCanceled,
    this.date,
    this.carFrontImage,
    this.carSideImage,
    this.rated,
    this.stars,
    this.clientRated,
    this.clientStars,
    this.dates,
    this.isSpareOrder,
    this.spareID,
    this.active,
    this.shopName,
    this.shopPhone,
  });

  String id;
  int orderType;
  String orderTypeString;
  String userId;
  String userName;
  String userPhone;
  String driverId;
  String driverName;
  String driverPhone;
  String driverAvatar;
  double driverLat;
  double driverLng;
  String fromFullAddress;
  double fromLat;
  double fromLng;
  String toFullAddress;
  double toLat;
  double toLng;
  int vehicleType;
  String vehicleName;
  String vehicleImage;
  double vehiclePrice;
  double distance;
  double distanceStartPrice;
  double distancePrice;
  double distanceTotalPrice;
  int numberOfPieces;
  int numberOfWorkers;
  String fromFloorString;
  String toFloorString;
  int fromFloor;
  int toFloor;
  bool payCash;
  int payed;
  int paymentId;
  String payVia;
  int status;
  double totalPrice;
  String polylineEndpoint;
  String totalDuration;
  String plateNumber;
  String reasonCanceled;
  String date;
  String carFrontImage;
  String carSideImage;
  bool rated;
  int stars;
  bool clientRated;
  int clientStars;
  Map<String, dynamic> dates;
  bool isSpareOrder;
  String spareID;
  bool active;
  String shopName;
  String shopPhone;

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map json = doc.data();
    return OrderModel(
      id: doc.id,
      orderType: json["orderType"],
      orderTypeString: json["orderTypeString"],
      userId: json["userId"],
      userName: json["userFirstName"] ?? json["userName"],
      userPhone: json["userPhone"],
      driverId: json["driverId"],
      driverName: json["driverFirstName"] ?? json["driverName"],
      driverPhone: json["driverPhone"],
      driverAvatar: json["driverAvatar"],
      driverLat: json["driverLat"]?.toDouble(),
      driverLng: json["driverLng"]?.toDouble(),
      fromFullAddress: json["fromFullAddress"],
      fromLat: json["fromLat"]?.toDouble(),
      fromLng: json["fromLng"]?.toDouble(),
      toFullAddress: json["toFullAddress"],
      toLat: json["toLat"]?.toDouble(),
      toLng: json["toLng"]?.toDouble(),
      vehicleType: json["vehicleType"],
      vehicleName: json["vehicleName"],
      vehicleImage: json["vehicleImage"],
      vehiclePrice: json["vehiclePrice"]?.toDouble(),
      distance: json["distance"]?.toDouble(),
      distanceStartPrice: json["distanceStartPrice"]?.toDouble(),
      distancePrice: json["distancePrice"]?.toDouble(),
      distanceTotalPrice: json["distanceTotalPrice"]?.toDouble(),
      numberOfPieces: json["numberOfPieces"],
      numberOfWorkers: json["numberOfWorkers"],
      fromFloorString: json["fromFloorString"],
      toFloorString: json["toFloorString"],
      fromFloor: json["fromFloor"],
      toFloor: json["toFloor"],
      payCash: json["payCash"],
      payed: json["payed"],
      paymentId: json["paymentId"],
      status: json["status"],
      totalPrice: json["totalPrice"]?.toDouble(),
      polylineEndpoint: json["polylineEndpoint"],
      totalDuration: json["totalDuration"],
      plateNumber: json["plateNumber"] ?? '',
      reasonCanceled: json["reasonCanceled"] ?? '',
      carFrontImage: json["carFront"] ?? null,
      carSideImage: json["carSide"] ?? null,
      date: getOrderDate(doc.id.replaceAll("-spare", "")),
      dates: json["dates"] ?? {},
      rated: json["rated"] ?? false,
      stars: json["stars"] ?? 0,
      clientRated: json["clientRated"] ?? false,
      clientStars: json["clientStars"] ?? 0,
      isSpareOrder: json["isSpareOrder"] ?? false,
      active: json["active"] ?? true,
      spareID: json["spareID"],
      shopName: json["shopName"] ?? '',
      shopPhone: json["shopPhone"] ?? '',
    );
  }

  factory OrderModel.fromMap(Map<String, dynamic> json) => OrderModel(
    orderType: json["orderType"],
    orderTypeString: json["orderTypeString"],
    userId: json["userId"],
    userName: json["userName"],
    userPhone: json["userPhone"],
    driverId: json["driverId"],
    driverName: json["driverName"],
    driverPhone: json["driverPhone"],
    driverAvatar: json["driverAvatar"],
    driverLat: json["driverLat"]?.toDouble(),
    driverLng: json["driverLng"]?.toDouble(),
    fromFullAddress: json["fromFullAddress"],
    fromLat: json["fromLat"]?.toDouble(),
    fromLng: json["fromLng"]?.toDouble(),
    toFullAddress: json["toFullAddress"],
    toLat: json["toLat"]?.toDouble(),
    toLng: json["toLng"]?.toDouble(),
    vehicleType: json["vehicleType"],
    vehicleName: json["vehicleName"],
    vehicleImage: json["vehicleImage"],
    vehiclePrice: json["vehiclePrice"]?.toDouble(),
    distance: json["distance"]?.toDouble(),
    distanceStartPrice: json["distanceStartPrice"]?.toDouble(),
    distancePrice: json["distancePrice"]?.toDouble(),
    distanceTotalPrice: json["distanceTotalPrice"]?.toDouble(),
    numberOfPieces: json["numberOfPieces"],
    numberOfWorkers: json["numberOfWorkers"],
    fromFloorString: json["fromFloorString"],
    toFloorString: json["toFloorString"],
    fromFloor: json["fromFloor"],
    toFloor: json["toFloor"],
    payCash: json["payCash"],
    payed: json["payed"],
    paymentId: json["paymentId"],
    status: json["status"],
    totalPrice: json["totalPrice"]?.toDouble(),
    polylineEndpoint: json["polylineEndpoint"],
    totalDuration: json["totalDuration"],
    plateNumber: json["plateNumber"] ?? '',
    reasonCanceled: json["reasonCanceled"] ?? '',
    carFrontImage: json["carFront"] ?? null,
    carSideImage: json["carSide"] ?? null,
    dates: json["dates"] ?? {},
    rated: json["rated"] ?? false,
    stars: json["stars"] ?? 0,
    clientRated: json["clientRated"] ?? false,
    clientStars: json["clientStars"] ?? 0,
    isSpareOrder: json["isSpareOrder"] ?? false,
    active: json["active"] ?? true,
    spareID: json["spareID"],
    shopName: json["shopName"] ?? '',
    shopPhone: json["shopPhone"] ?? '',
  );

  Map<String, dynamic> toMap() => {
    "orderType": orderType,
    "orderTypeString": orderTypeString,
    "userId": userId,
    "userName": userName,
    "userPhone": userPhone,
    "driverId": driverId,
    "driverName": driverName,
    "driverPhone": driverPhone,
    "driverAvatar": driverAvatar,
    "driverLat": driverLat,
    "driverLng": driverLng,
    "fromFullAddress": fromFullAddress,
    "fromLat": fromLat,
    "fromLng": fromLng,
    "toFullAddress": toFullAddress,
    "toLat": toLat,
    "toLng": toLng,
    "vehicleType": vehicleType,
    "vehicleName": vehicleName,
    "vehicleImage": vehicleImage,
    "vehiclePrice": vehiclePrice,
    "distance": distance,
    "distanceStartPrice": distanceStartPrice,
    "distancePrice": distancePrice,
    "distanceTotalPrice": distanceTotalPrice,
    "numberOfPieces": numberOfPieces,
    "numberOfWorkers": numberOfWorkers,
    "fromFloorString": fromFloorString,
    "toFloorString": toFloorString,
    "fromFloor": fromFloor,
    "toFloor": toFloor,
    "payCash": payCash,
    "payed": payed,
    "paymentId": paymentId,
    "status": status,
    "totalPrice": totalPrice,
    "polylineEndpoint": polylineEndpoint,
    "totalDuration": totalDuration,
    "plateNumber": plateNumber,
    "reasonCanceled": reasonCanceled,
    "carFront": carFrontImage,
    "carSide": carSideImage,
    "rated": rated ?? false,
    "stars": stars ?? 0,
    "clientRated": clientRated ?? false,
    "clientStars": clientStars ?? 0,
    "dates": dates,
    "isSpareOrder": isSpareOrder ?? false,
    "active": active ?? true,
    "spareID": spareID,
    "shopName": shopName,
    "shopPhone": shopPhone,
  };
}


String getOrderDate(String timestamp) {
  if(timestamp != null) {
    DateTime x = DateTime.fromMicrosecondsSinceEpoch(int.tryParse(timestamp));
    return intl.DateFormat.yMMMEd('ar_SA').format(x);
  }
  return "";
}