import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/orderingController.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/screens/ordering/confirm_order.dart';
import 'package:karaj/screens/ordering/pick_up_information.dart';
import 'package:karaj/ui_widgets/draw_order_map.dart';

class SelectVehicleType extends GetWidget<OrderingController> {
  final OrderingController _orderCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    OrderModel _o = _orderCtrl.order;
    return Scaffold(
      appBar: appBar(title: "selectVan".tr),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DrawOrderLocation(
              fromLat: _orderCtrl.order.fromLat,
              fromLng: _orderCtrl.order.fromLng,
              toLat: _orderCtrl.order.toLat,
              toLng: _orderCtrl.order.toLng,
            ),
            SizedBox(height: Get.height * 0.03),
            InkWell(
              onTap: () {
                _orderCtrl.setStep = 3;
                _o.vehicleType = 1;
                _o.vehicleName = 'فان';
                _o.vehicleImage = '';
                _o.vehiclePrice = 55;
                _orderCtrl.setOrder = _o;

                nextStep();

              },
              child: VehicleCard(
                image: 'assets/images/vehicle1.jpeg',
                name: 'van'.tr,
                description: 'vanDescription'.tr,
                price: '55',

              ),
            ),
            InkWell(
              onTap: () {
                _orderCtrl.setStep = 3;
                _o.vehicleType = 2;
                _o.vehicleName = 'بيك اب';
                _o.vehicleImage = '';
                _o.vehiclePrice = 70;
                _orderCtrl.setOrder = _o;
                nextStep();
              },
              child: VehicleCard(
                image: 'assets/images/vehicle2.jpeg',
                name: 'pickup'.tr,
                description: 'pickupDescription'.tr,
                price: '70',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void nextStep() {
    if(_orderCtrl.order.orderType == 1) {
      Get.to(ConfirmOrder());
    } else {
      Get.to(PickUpDetails());
    }
  }
}



class VehicleCard extends StatelessWidget {
  final String image, name, description, price;

  const VehicleCard({Key key, this.image, this.name, this.description, this.price}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: Container(
          decoration: BoxDecoration(color: Get.theme.colorScheme.background),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(left: 12.0),
              decoration: BoxDecoration(
                border: Border(
                  left:  BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: Image(
                image: AssetImage('$image'),
              ),
            ),
            title: Text(
              "$name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Text("$description"),
            trailing: Text('$price رس'),
          )
      ),
    );
  }
}
