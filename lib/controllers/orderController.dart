import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/userController.dart';

class OrderController extends GetxController {

  static Stream<Position> getLocation = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation);
  static RxBool enabled = RxBool(true);

  static Future<void> updateDriverLocation({String orderID}) async {
    getLocation.listen((Position p) {
      if(Get.find<UserController>().user != null && enabled.value == true) {
        if(Get.find<UserController>().user.isDriver && Get.find<UserController>().user.isOnRide && Get.find<UserController>().user.onOrderID == orderID) {
          FirebaseFirestore.instance.collection('orders').doc(orderID).update({'driverLat': p.latitude, 'driverLng': p.longitude});
        }
      }
    });
  }

  static void killUpdatingDriverLocation({String orderID}) async {
    enabled.value = false;
  }

  static void startAgain({String orderID}) async {
    enabled.value = true;
  }
}