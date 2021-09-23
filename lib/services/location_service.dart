import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

class MTLocationService {


  static Future<void> updateOrderDriverLocation({String orderID}) async {
    if(Get.find<UserController>().user != null) {
      if(Get.find<UserController>().user.isDriver && Get.find<UserController>().user.isOnRide && Get.find<UserController>().user.onOrderID == orderID) {
        Map<String, dynamic> data = {
          "orderID": orderID,
          "driverID": Get.find<UserController>().user.id,
        };
        await FlutterIsolate.spawn(updateOrderDriverLocationBackground, data);
      }
    }
  }

}


void updateOrderDriverLocationBackground(Map<String, dynamic> data) {
  String orderID = data["orderID"];
  //String driverID = data["driverID"];
  Stream<Position> getLocation = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation);
  Get.put(UserController());
  getLocation.listen((Position p) {
    if(Get.find<UserController>().user != null) {
      if(Get.find<UserController>().user.isDriver && Get.find<UserController>().user.isOnRide && Get.find<UserController>().user.onOrderID == orderID) {
        FirebaseFirestore.instance.collection('orders').doc(orderID).update({'driverLat': p.latitude, 'driverLng': p.longitude});
      }
    }

  });
}