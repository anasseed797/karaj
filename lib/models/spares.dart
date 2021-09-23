/*
status :
0 : drift
1 : waiting
2 : answerd
3 : confirmed
4 : select location
5 : waiting for pay
6 : payed
7 : driver get packges
8 : driver on his way
9 : deliverd
 */
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;


SparesModel sparesModelFromMap(String str) => SparesModel.fromMap(json.decode(str));

String sparesModelToMap(SparesModel data) => json.encode(data.toMap());

class SparesModel {
  SparesModel({
    this.id,
    this.userId,
    this.userName,
    this.userPhone,
    this.brand,
    this.model,
    this.category,
    this.chassisNumber,
    this.shopId,
    this.shopName,
    this.shopPhone,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.orderId,
    this.items,
    this.price,
    this.tax,
    this.discount,
    this.totalPrice,
    this.offerPrice,
    this.deliveryPrice,
    this.pickupType,
    this.pickupTypeString,
    this.status,
    this.shopVoted,
    this.shopStar,
    this.clientRated,
    this.clientStars,
    this.date,
    this.payed,
    this.paymentID,
    this.paymentUDC,
    this.paymentUrl,
    this.dropOffAddress,
    this.dropOffData,
    this.shopAddress,
    this.shopAddressData,
  });

  String id;
  String userId;
  String userName;
  String userPhone;
  String brand;
  String model;
  String category;
  String chassisNumber;
  String shopId;
  String shopName;
  String shopPhone;
  String driverId;
  String driverName;
  String driverPhone;
  String orderId;
  List<Item> items;
  double price;
  double tax;
  double discount;
  double totalPrice;
  double offerPrice;
  double deliveryPrice;
  int pickupType;
  String pickupTypeString;
  int status;
  bool shopVoted;
  int shopStar;
  bool clientRated;
  int clientStars;
  String date;
  bool payed;
  String paymentID;
  String paymentUDC;
  String paymentUrl;
  String dropOffAddress;
  Map<String, dynamic> dropOffData;
  String shopAddress;
  Map<String, dynamic> shopAddressData;

  factory SparesModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data();
    return SparesModel(
      id: doc.id,
      userId: json["userId"],
      userName: json["userName"],
      userPhone: json["userPhone"],
      brand: json["brand"],
      model: json["model"],
      category: json["category"],
      chassisNumber: json["chassisNumber"],
      shopId: json["shopId"],
      shopName: json["shopName"],
      shopPhone: json["shopPhone"],
      driverId: json["driverId"],
      driverName: json["driverName"],
      driverPhone: json["driverPhone"],
      orderId: json["orderId"],
      items: List<Item>.from(json["items"].map((x) => Item.fromMap(x))),
      price: json["price"]?.toDouble(),
      tax: json["tax"]?.toDouble(),
      discount: json["discount"]?.toDouble(),
      totalPrice: json["totalPrice"]?.toDouble(),
      offerPrice: json["offerPrice"]?.toDouble(),
      deliveryPrice: double.tryParse(json["deliveryPrice"].toString() ?? "0"),
      pickupType: json["pickupType"],
      pickupTypeString: json["pickupTypeString"],
      status: json["status"],
      shopVoted: json["shopVoted"],
      shopStar: json["shopStar"],
      clientRated: json["clientRated"] ?? false,
      clientStars: json["clientStars"] ?? 0,
      date: getOrderDate(doc.id),
      payed: json["payed"] ?? false,
      paymentID: json["paymentID"] ?? null,
      paymentUDC: json["paymentUDC"] ?? null,
      paymentUrl: json["paymentUrl"] ?? null,
      dropOffAddress: json["dropOffAddress"] ?? "",
      dropOffData: json["dropOffData"] ?? {},
      shopAddress: json["shopAddress"] ?? "",
      shopAddressData: json["shopAddressData"] ?? {},
    );
  }

  factory SparesModel.fromMap(Map<String, dynamic> json) => SparesModel(
    userId: json["userId"],
    userName: json["userName"],
    userPhone: json["userPhone"],
    brand: json["brand"],
    model: json["model"],
    category: json["category"],
    chassisNumber: json["chassisNumber"],
    shopId: json["shopId"],
    shopName: json["shopName"],
    shopPhone: json["shopPhone"],
    driverId: json["driverId"],
    driverName: json["driverName"],
    driverPhone: json["driverPhone"],
    orderId: json["orderId"],
    items: List<Item>.from(json["items"].map((x) => Item.fromMap(x))),
    price: json["price"]?.toDouble(),
    tax: json["tax"]?.toDouble(),
    discount: json["discount"]?.toDouble(),
    totalPrice: json["totalPrice"]?.toDouble(),
    offerPrice: json["offerPrice"]?.toDouble(),
    deliveryPrice: json["deliveryPrice"]?.toDouble(),
    pickupType: json["pickupType"],
    pickupTypeString: json["pickupTypeString"],
    status: json["status"],
    shopVoted: json["shopVoted"],
    shopStar: json["shopStar"],
    clientRated: json["clientRated"] ?? false,
    clientStars: json["clientStars"] ?? 0,
    date: getOrderDate(json["id"]),
    payed: json["payed"] ?? false,
    paymentID: json["paymentID"],
    paymentUDC: json["paymentUDC"],
    paymentUrl: json["paymentUrl"],
    dropOffAddress: json["dropOffAddress"] ?? "",
    dropOffData: json["dropOffData"] ?? {},
    shopAddress: json["shopAddress"] ?? "",
    shopAddressData: json["shopAddressData"] ?? {},
  );

  Map<String, dynamic> toMap() => {
    "userId": userId,
    "userName": userName,
    "userPhone": userPhone,
    "brand": brand,
    "model": model,
    "category": category,
    "chassisNumber": chassisNumber,
    "shopId": shopId,
    "shopName": shopName,
    "shopPhone": shopPhone,
    "driverId": driverId,
    "driverName": driverName,
    "driverPhone": driverPhone,
    "orderId": orderId,
    "items": List<dynamic>.from(items.map((x) => x.toMap())),
    "price": price,
    "tax": tax,
    "discount": discount,
    "totalPrice": totalPrice,
    "offerPrice": offerPrice,
    "deliveryPrice": deliveryPrice,
    "pickupType": pickupType,
    "pickupTypeString": pickupTypeString,
    "status": status,
    "shopVoted": shopVoted,
    "shopStar": shopStar,
    "clientRated": clientRated ?? false,
    "clientStars": clientStars ?? 0,
    "payed": payed ?? false,
    "paymentID": paymentID,
    "paymentUDC": paymentUDC,
    "paymentUrl": paymentUrl,
    "dropOffAddress": dropOffAddress,
    "dropOffData": dropOffData,
    "shopAddress": shopAddress,
    "shopAddressData": shopAddressData,
  };
}


class Item {
  Item({
    this.quantity,
    this.name,
    this.number,
    this.image,
    this.type,
    this.typeString,
    this.price,
    this.discount,
    this.available,
    this.status,
  });

  int quantity;
  String name;
  String number;
  String image;
  int type;
  String typeString;
  double price;
  double discount;
  bool available;
  int status;

  factory Item.fromMap(Map<String, dynamic> json) => Item(
    quantity: json["quantity"],
    name: json["name"],
    number: json["number"],
    image: json["image"],
    type: json["type"],
    typeString: json["typeString"],
    price: double.tryParse(json["price"].toString() ?? "0.0"),
    discount: double.tryParse(json["discount"].toString() ?? "0.0"),
    available: json["available"] ?? true,
    status: json["status"] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    "quantity": quantity,
    "name": name,
    "number": number,
    "image": image,
    "type": type,
    "typeString": typeString,
    "price": price ?? 0,
    "discount": discount ?? 0,
    "available": available ?? true,
    "status": status ?? 0,
  };
}

// TODO: move it helper class
String getOrderDate(String timestamp) {
  if(timestamp != null) {
    int t = int.tryParse(timestamp ?? "");
    if(t != null && t > 0) {
      DateTime x = DateTime.fromMicrosecondsSinceEpoch(t);
      return intl.DateFormat.yMMMEd('ar_SA').format(x);
    }
  }
  return "";
}