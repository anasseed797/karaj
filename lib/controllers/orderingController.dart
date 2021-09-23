import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/services/database.dart';
import 'package:intl/intl.dart' as intl;

class OrderingController extends GetxController {

  Rx<bool> _onLoading = false.obs;
  bool onCreatingOrder = false;
  set setLoading(bool x) => this._onLoading.value = x;
  bool get onLoading => _onLoading.value;

  Rx<int> _orderStep = 0.obs;
  set setStep(int x) => this._orderStep.value = x;
  int get step => _orderStep.value;

  Rx<OrderModel> _order = OrderModel(
    fromFullAddress: '',
    toFullAddress: '',
    status: 0,
  ).obs;

  OrderModel get order => _order.value;

  set setOrder(OrderModel _o) {
    this._order.value = _o;
    print(_o.vehicleType);

    update();
  }


  clear() {
    _orderStep.value = 0;
    _order.value = OrderModel(
      fromFullAddress: '',
      toFullAddress: '',
      status: 0,
    );
  }


  void orderSetUpInformation() {
    double distanceX = 0;
    double priceForKm = 0;
    double distanceStartPriceX = 0;
    double distancePriceX = 0;
    if(order.fromLat != null && order.fromLng != null && order.toLat != null && order.toLng != null) {
      distanceX = Helpers.calculateDistance(order.fromLat, order.fromLng, order.toLat, order.toLng);
      if(distanceX != null && distanceX > 0) {
        distanceX = double.parse(distanceX.toStringAsFixed(2));
      }
      if(distanceX > 0 && distanceX <= 5) {
        distanceStartPriceX = 10;
        priceForKm = 1;
      } else if (distanceX > 5 && distanceX <= 10) {
        distanceStartPriceX = 50;
        priceForKm = 1.5;
      } else if (distanceX > 10 && distanceX <= 15) {
        distanceStartPriceX = 70;
        priceForKm = 2;
      } else {
        distanceStartPriceX = 100;
        priceForKm = 2.5;
      }

      distancePriceX = priceForKm * distanceX;


      _order.value.distance = distanceX;
      _order.value.distanceStartPrice =  double.parse(distanceStartPriceX.toStringAsFixed(2));
      _order.value.distancePrice =  double.parse(distancePriceX.toStringAsFixed(2));
      _order.value.distanceTotalPrice =  double.parse(distancePriceX.toStringAsFixed(2));


      _order.value.totalPrice = double.parse((distanceStartPriceX + distancePriceX + order.vehiclePrice).toStringAsFixed(2));

    }
  }

  Future<OrderModel> submitOrder({String id}) async {
    if(!onCreatingOrder && FirebaseAuth.instance.currentUser != null && _order.value?.totalPrice != null) {
      try {
        onCreatingOrder = true;
        Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
        OrderModel o = _order.value;
        o.userId = FirebaseAuth.instance.currentUser.uid;
        o.userName = FirebaseAuth.instance.currentUser.displayName;
        o.userPhone = FirebaseAuth.instance.currentUser.phoneNumber;
        DateTime now = DateTime.now();
        String day = intl.DateFormat('d').format(now);
        String month = intl.DateFormat('M').format(now);
        String year = intl.DateFormat('y').format(now);
        String monthName = intl.DateFormat('MMM').format(now);
        String md = intl.DateFormat('Md').format(now);
        if(id != null && id.isNotEmpty) {
          o.id = id;
        } else {
          o.id = now.microsecondsSinceEpoch.toString();
        }
        o.status = 1;
        Map<String, dynamic> data = o.toMap();
        data['day'] = day;
        data['month'] = month;
        data['year'] = year;
        data['monthName'] = monthName;
        data['md'] = md;
        await Database().createOrder(o.id, data);
        UserController().submitOrder(o);
        onCreatingOrder = false;
        Get.back();
        return o;
      } catch (e) {
        print("================== submitOrder catch error says : $e");
        return null;
      }
    } else {
      return null;
    }
  }


}