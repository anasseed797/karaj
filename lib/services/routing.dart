import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/shopOnModifiedOrder.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/screens/pages_errors.dart';
import 'package:karaj/screens/spares/details/spares_order_details.dart';
import 'package:karaj/services/database.dart';

class RoutingSwitch {

  static routeToSpareOrder({String id}) async {
    if(id != null) {
      Get.put(ModifiedOrderController());
      Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
      SparesModel _order = await Database().getSpare(id);
      Get.back();
      if(_order != null && _order.id != null) {
        Get.find<ModifiedOrderController>().setOrder = _order;
        Get.to(SparesOrderDetails());
      } else {
        Get.to(NotFoundPage());
      }
      return;
    }
    Get.back();
  }
}