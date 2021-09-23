import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/orderController.dart';
import 'package:karaj/controllers/paymentController.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:karaj/services/PushNotificationService.dart';
import 'package:intl/intl.dart' as intl;

const userColl = "users";

class Database {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> createUser(UserModel user) async {
    try {
      if(user.isDriver || user.isShop) {
        user = await updateUserImages(user);
      }
      await _db.collection(userColl).doc(user.id).set({
        "firstName": user.firstName,
        "lastName": user.lastName,
        "isDriver": user.isDriver,
        "isShop": user.isShop,
        "fullAddress": user.fullAddress,
        "phone": user.phone,
        "active": user.active,
        "personalData": user.personalData,
        "token": user.token
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }



  Future<UserModel> updateUserImages(UserModel user) async {
    String child = 'drivers';
    if(user.isShop) {
      child = 'shops';
    }
    Map<String, dynamic> pData = {};
    for (var data in user.personalData.entries) {
      if(data.key.startsWith('image')) {
        String gKey = data.key.replaceAll('image', '');
        File gFile = File(data.value);
        firebase_storage.UploadTask uploadTask;
        uploadTask = firebase_storage.FirebaseStorage.instance.ref().child(child).child(user.id).child('${data.key}.jpg').putFile(gFile);
        var downloadUrl = await (await uploadTask).ref.getDownloadURL();
        pData[gKey] = downloadUrl.toString();
      }
    }

    for (var x in pData.entries) {
      user.personalData[x.key] = x.value;
      user.personalData.remove("image${x.key}");
    }

    return user;
  }

  Future<UserModel> getUser(String uid) async {
    try {
      print("================================== Getting user from database");
      DocumentSnapshot doc = await _db.collection("users").doc(uid).get();
      if(doc.exists) {
        return UserModel.fromDocumentSnapshot(doc);
      }
      return UserModel();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<UserModel> streamGetUser() {
    print("================================== StreamGetUser()");

    return _db.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).snapshots().map((event) => UserModel.fromDocumentSnapshot(event));
  }


  Future<void> createOrder(String id, Map<String, dynamic> data) async {
    try {
      DocumentReference ref = _db.collection("orders").doc(id);
      await _db.runTransaction((transaction) async {
        await transaction.set(ref, data);
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }


  Future<OrderModel> getOrder(String orderID) async {
    try {
      DocumentSnapshot doc = await _db.collection("orders").doc(orderID).get();
      if(doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return OrderModel();
    } catch (e) {
      print(e);
      rethrow;
    }
  }


  Future<List<OrderModel>> getUserOrders({String userId}) async {
    var ref = await _db.collection('orders').where('userId', isEqualTo: userId).get();
    return ref.docs.map((d) => OrderModel.fromFirestore(d)).toList();
  }


  Future<List<DocumentSnapshot>> getSavedVehicles({String userId}) async {
    if(userId == null) {
      userId = FirebaseAuth.instance.currentUser.uid;
    }
    var ref = await _db.collection('users').doc(userId).collection("vehiclesSpares").get();
    return ref.docs;
  }

  Future<void> createSpareOrder(Map<String, dynamic> data) async {
    try {
      String id = DateTime.now().microsecondsSinceEpoch.toString();
      await _db.collection('spares').doc(id).set(data);
      UserModel _shopU = await this.getUser(data["shopId"]);
      PushNotificationService().sendNotification(
          type: 'spare',
          orderID: id,
          title: 'لذيك طلب جديد',
          body: 'لذيك طلب جديد بخصوص قطع الغيار',
          token: _shopU.token ?? ''
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<SparesModel>> getSparesOrders({String userId, String whereF = 'userId'}) async {
    var ref = await _db.collection('spares').where(whereF, isEqualTo: userId).get();
    return ref.docs.map((d) => SparesModel.fromFirestore(d)).toList();
  }

  Stream<List<SparesModel>> getSparesOrdersStream({String userId, String whereF = 'userId'}) {
    var ref = _db.collection('spares').where(whereF, isEqualTo: userId);
    return ref.snapshots().map((list) => list.docs.map((d) => SparesModel.fromFirestore(d)).toList());
  }

  Future<SparesModel> getSpare(String orderID) async {
    try {
      DocumentSnapshot doc = await _db.collection("spares").doc(orderID).get();
      if(doc.exists) {
        return SparesModel.fromFirestore(doc);
      }
      return SparesModel();
    } catch (e) {
      print(e);
      rethrow;
    }
  }


  Stream<List<OrderModel>> getWaitingOrders({String userId})  {
    var ref = _db.collection('orders').where('status', isEqualTo: 1);
    return ref.snapshots().map((list) => list.docs.map((d) => OrderModel.fromFirestore(d)).toList());
  }

  Stream<List<OrderModel>> getDriverOrders({String driverId})  {
    var ref = _db.collection('orders').where('driverId', isEqualTo: driverId);
    return ref.snapshots().map((list) => list.docs.map((d) => OrderModel.fromFirestore(d)).toList());
  }

  Future<List<OrderModel>> getDriverOrdersDocs({String userId}) async {
    var ref = await _db.collection('orders').where('driverId', isEqualTo: userId).get();
    return ref.docs.map((d) => OrderModel.fromFirestore(d)).toList();
  }

  Stream<List<OrderModel>> getDriverOrdersStream({String userId})  {
    var ref = _db.collection('orders').where('driverId', isEqualTo: userId);
    return ref.snapshots().map((list) => list.docs.map((d) => OrderModel.fromFirestore(d)).toList());
  }

  Stream<List<OrderModel>> getUserOrdersStream({String userId}) {
    var ref = _db.collection('orders').where('userId', isEqualTo: userId);
    return ref.snapshots().map((list) => list.docs.map((d) => OrderModel.fromFirestore(d)).toList());
  }

  Future<bool> setDriver({String orderID, String clientID, UserModel user, int status, OrderModel order}) async {
    try{
      Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
      Map<String, dynamic> data = {
        'driverId': FirebaseAuth.instance.currentUser.uid,
        'driverName': "${user.firstName} ${user.lastName}",
        'driverFirstName': user.firstName ?? "",
        'driverLastName': user.lastName ?? "",
        'driverPhone': FirebaseAuth.instance.currentUser.phoneNumber,
        'plateNumber': user.personalData["plateNumber"] ?? "",
        'driverAvatar': user.personalData["AvatarPath"] ?? "",
        'carFront': user.personalData["CarFront"] ?? "",
        'carSide': user.personalData["SideViewCar"] ?? "",
        'status': status,
      };
      DateTime now = DateTime.now();
      String jm = intl.DateFormat.yMd().add_jm().format(now);
      Map<String, dynamic> dates = order.dates;
      if(status == 3) {
        dates['orderAccepted'] = jm;
      } else if(status == 5) {
        dates['orderPicked'] = jm;
      } else if(status == 9) {
        dates['done'] = jm;
      }
      data['dates'] = dates;
      await _db.collection('orders').doc(orderID).update(data);
      Get.back();
      if(status == 3) {
        //  Get.snackbar('تم قبول الطلب', 'لقد قمت لتو بقبول هذا الطلب وانت المسؤل الان عن نقل الاغراض', snackPosition: SnackPosition.TOP);
        UserModel _clientUser = await this.getUser(clientID);
        await this.updateDocument(docName: "users", docID: _clientUser.id, data: {
          "onOrderID": orderID,
          "isOnRide": true
        }, donTShowLoading: true);
        PushNotificationService().sendNotification(
            type: 'driverAcceptOrder',
            orderID: orderID,
            title: 'تم قبول طلبك.',
            body: 'تم قبول طلبك من طرف سائق ${user.firstName ?? ''} سيارة رقم ${user?.personalData["plateNumber"] ?? '-'}',
            token: _clientUser.token ?? ''
        );

        if(order != null && order.isSpareOrder == true && order.spareID != null) {
          await this.updateDocument(create: false, docName: "spares", docID: order.spareID, data: {
            "status": 9,
            'driverId': FirebaseAuth.instance.currentUser.uid,
            'driverName': "${user.firstName} ${user.lastName}",
            'driverFirstName': user.firstName ?? "",
            'driverLastName': user.lastName ?? "",
            'driverPhone': FirebaseAuth.instance.currentUser.phoneNumber,
            'plateNumber': user.personalData["plateNumber"] ?? "",
            'driverAvatar': user.personalData["AvatarPath"] ?? "",
          }, donTShowLoading: true);
        }
      } else if(status == 5) {
        UserModel _clientUser = await this.getUser(clientID);
        PushNotificationService().sendNotification(
            type: 'orderPicked',
            orderID: orderID,
            title: 'تم شحن البضاعة.',
            body: 'تم شحن البضاعة من طرف ${user.firstName ?? ''} سيارة رقم ${user?.personalData["plateNumber"] ?? '-'}',
            token: _clientUser.token ?? ''
        );

        if(order != null && order.isSpareOrder == true && order.spareID != null) {
          await this.updateDocument(create: false, docName: "spares", docID: order.spareID, data: {
            "status": 7,
          }, donTShowLoading: true);
        }
      } else if(status == 9) {
        UserModel _clientUser = await this.getUser(clientID);
        OrderModel orderModelX = await this.getOrder(orderID);
        PushNotificationService().sendNotification(
            type: 'orderDone',
            orderID: orderID,
            title: 'تم الانتهاء من نقل طلبك.',
            body: 'تم الانتهاء من نقل طلبك من طرف ${user.firstName ?? ''} سيارة رقم ${user?.personalData["plateNumber"] ?? '-'}',
            token: _clientUser.token ?? ''
        );
        if(orderModelX.isSpareOrder == true && orderModelX.spareID != null) {
          await this.updateDocument(create: false, docName: "spares", docID: orderModelX.spareID, data: {
            "status": 9,
          }, donTShowLoading: true);
        }
        await this.updateDocument(docName: "users", docID: orderModelX.userId, data: {
          "onOrderID": null,
          "isOnRide": false
        }, donTShowLoading: true);
        await this.updateDocument(docName: "users", docID: orderModelX.driverId, data: {
          "onOrderID": null,
          "isOnRide": false
        }, donTShowLoading: true);
        if(orderModelX.payCash) {
          await PaymentController.createCommissionPayment(userId: orderModelX.driverId, order: orderModelX);
        } else {
          if(orderModelX.isSpareOrder != true) {
            await PaymentController.createOrderPayment(order: orderModelX, typeX: "discount", payVia: "app");
          }
          await PaymentController.createOrderPayment(forId: orderModelX.driverId, order: orderModelX, typeX: "added", payVia: "app", cutCommission: true);
        }
      }
      UserController uCtrl = Get.find();
      UserModel uModel = uCtrl.user;
      if(status != 9) {
        uModel.isOnline = false;
        uModel.isOnRide = true;
        uModel.onOrderID = orderID;
        uCtrl.setDriverOnline(false);
      } else {
        uModel.isOnline = false;
        uModel.isOnRide = false;
        uModel.onOrderID = null;
      }
      uCtrl.setUser = uModel;

      if(status < 9) {
        OrderController.startAgain(orderID: orderID);
        OrderController.updateDriverLocation(orderID: orderID);
      } else {
        OrderController.killUpdatingDriverLocation(orderID: orderID);
      }

      return true;
    } catch(e) {
      Get.snackbar('حدث مشكلة', e.toString(), snackPosition: SnackPosition.TOP);
      return false;

    }
  }

  Future<bool> setOrderStatus({String orderID, int status, bool isDriver = false, String reason, OrderModel order}) async {
    try{
      Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
      Map<String, dynamic> data = {
        'status': status,
        'reasonCanceled': reason
      };
      DateTime now = DateTime.now();
      String jm = intl.DateFormat.yMd().add_jm().format(now);
      Map<String, dynamic> dates = order.dates;
      if(status == 4) {
        dates['orderDriverAtOrderLocation'] = jm;
      } else if(status == 6) {
        dates['orderAtDropOff'] = jm;
      } else if(status == 97) {
        dates['canceledAt'] = jm;
      }
      data['dates'] = dates;
      await _db.collection('orders').doc(orderID).update(data);
      Get.back();
      if(status == 97) {
        await this.updateDocument(docName: "users", docID: order?.userId, data: {
          "onOrderID": null,
          "isOnRide": false
        }, donTShowLoading: true);
        UserController().streamingUserData();
        Get.back();
        Get.snackbar('تم الغاء الطلب', '', snackPosition: SnackPosition.TOP);
        if(isDriver) {
          UserModel _clientUser = await this.getUser(order.userId);
          PushNotificationService().sendNotification(
              type: 'driverCancelOrder',
              orderID: orderID,
              title: 'تم الغاء طلبك.',
              body: 'قام لتو السائق ${order.driverName} بالغاء طلبك لسبب $reason}',
              token: _clientUser.token ?? ''
          );

        }
        if(order?.driverId != null) {
          await this.updateDocument(docName: "users", docID: order?.driverId,data: {
            "onOrderID": null,
            "isOnRide": false
          }, donTShowLoading: true);
          if(!isDriver) {
            UserModel _driver = await this.getUser(order?.driverId);
            PushNotificationService().sendNotification(
                type: 'driverCancelOrder',
                orderID: orderID,
                title: 'تم الغاء طلب.',
                body: 'تم الفاء الطلب من طرف صاحبه.',
                token: _driver.token ?? ''
            );
          }
        }
      } else {
        if(order?.userId == FirebaseAuth.instance.currentUser?.uid) {
          if(status > 1 && order?.driverId != null) {
            UserModel _driverU = await this.getUser(order.driverId);
            PushNotificationService().sendNotification(
                type: 'orderStatusUpdated',
                orderID: orderID,
                title: 'تم تحديث الطلب.',
                body: 'تم تحديث في حالة الطلب الخاص بك رقم ${order?.id}',
                token: _driverU.token ?? ''
            );
          }
        } else {
          UserModel _clientUser = await this.getUser(order.userId);
          PushNotificationService().sendNotification(
              type: 'orderStatusUpdated',
              orderID: orderID,
              title: 'تم تحديث الطلب.',
              body: 'تم تحديث في حالة الطلب الخاص بك رقم ${order?.id}',
              token: _clientUser.token ?? ''
          );
        }

      }
      return true;
    } catch(e) {
      print("==================== ${e.toString()} ============================");

      Get.snackbar('حدث مشكلة', e.toString(), snackPosition: SnackPosition.TOP);
      return false;

    }
  }

  Stream<List<UserModel>> getShops({String userId, String brand})  {
    var ref = _db.collection('users').where('isShop', isEqualTo: true);
    return ref.snapshots().map((list) => list.docs.map((d) => UserModel.fromDocumentSnapshot(d)).toList());
  }


  Future<void> saveToken(String token) async {
    print("================================== database() saveToken()");
    await this.updateDocument(docID: FirebaseAuth.instance.currentUser.uid,docName: "users", data: {"token": token}, donTShowLoading: true);
  }

  Future<void> updateDocument({String docName, String docID, Map<String, dynamic> data, bool donTShowLoading = false, bool create = true}) async {
    print("================================== updating $docName document and donTShowLoading : $donTShowLoading");

    if(!donTShowLoading) {
      Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
    }
    DocumentSnapshot doc = await _db.collection(docName).doc(docID).get();
    if(doc.exists) {
      await _db.collection(docName).doc(docID).update(data);
    } else {
      if(create == true) {
        await _db.collection(docName).doc(docID).set(data);
      }
    }
    if(!donTShowLoading) {
      Get.back();
    }
  }


  Future<void> deleteDocument({String docName, String docID, bool displayLoading = true}) async {
    print("================================== deleting $docName document with displayLoading : $displayLoading");

    if(displayLoading) {
      Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
    }
    DocumentSnapshot doc = await _db.collection(docName).doc(docID).get();
    if(doc.exists) {
      await _db.collection(docName).doc(docID).delete();
    }
    if(displayLoading) {
      Get.back();
    }
  }

  Future<void> deleteInsideDocument({String colName, String colID, String docName, String docID, bool displayLoading = true}) async {
    print("================================== deleting $docName document with displayLoading : $displayLoading");

    if(displayLoading) {
      Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
    }
    DocumentSnapshot doc = await _db.collection(colName).doc(colID).collection(docName).doc(docID).get();
    if(doc.exists) {
      await _db.collection(colName).doc(colID).collection(docName).doc(docID).delete();
    }
    if(displayLoading) {
      Get.back();
    }
  }


  Future<void> updateAppInformation({String name, var theValue = 1}) async {
    DocumentSnapshot data = await _db.collection("appInformation").doc("overview").get();
    String fName = name;
    var value;
    if(name == "drivers") {
      fName = "drivers";
      value = Helpers.toIntFix(data['drivers']) + theValue;
    } else if(name == "shops") {
      fName = "shops";
      value = Helpers.toIntFix(data['shops']) + theValue;
    } else if(name == "users") {
      fName = "users";
      value = Helpers.toIntFix(data['users']) + theValue;
    } else if(name == "orders") {
      fName = "orders";
      value = Helpers.toIntFix(data['orders']) + theValue;
    } else if(name == "spares") {
      fName = "spares";
      value = Helpers.toIntFix(data['spares']) + theValue;
    } else if(name == "fees") {
      fName = "fees";
      value = Helpers.toIntFix(data['fees']) + theValue;
    } else if(name == "appFees") {
      fName = "appFees";
      value = Helpers.toIntFix(data['appFees']) + theValue;
    }
    this.updateDocument(docName: "appInformation", docID: "overview", donTShowLoading: true, data: {fName: value});
  }

}