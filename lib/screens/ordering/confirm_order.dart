import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/orderingController.dart';
import 'package:karaj/controllers/shopOnModifiedOrder.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/screens/ordering/pay_screen.dart';
import 'package:karaj/screens/spares/details/spares_order_details.dart';
import 'package:karaj/ui_widgets/draw_order_map.dart';
import 'package:karaj/ui_widgets/order_card_direction.dart';

class ConfirmOrder extends GetWidget<OrderingController> {
  @override
  Widget build(BuildContext context) {
    controller.orderSetUpInformation();
    return Scaffold(
      appBar: appBar(title: 'btnVerifiedOrder'.tr),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            DrawOrderLocation(
              fromLat: controller.order.fromLat,
              fromLng: controller.order.fromLng,
              toLat: controller.order.toLat,
              toLng: controller.order.toLng,
              endpoint: controller.order.polylineEndpoint,
            ),
            OrderCardDirection(orderModel: controller.order),

            SizedBox(height: Get.height * 0.07),

            paymentListDetails('openCounter'.tr, "${controller.order.distanceStartPrice} ${"sar".tr}" ?? ''),
            paymentListDetails('distance'.tr, "${controller.order.distance.toString()} ${"km".tr}" ?? ''),
            paymentListDetails('distancePrice'.tr, "${controller.order.distancePrice}  ${"sar".tr}" ?? ''),
            paymentListDetails('vehiclePrice'.tr, "${controller.order.vehiclePrice}  ${"sar".tr}" ?? ''),


            Divider(),
            paymentListDetails('totalPrice'.tr, "${controller.order.totalPrice ?? ''}SAR", size: 21.0),
            SizedBox(height: Get.height * 0.03),
            controller.order.isSpareOrder == true ? Container(
              width: Get.width * 0.9,
              child: flatButtonWidget(
                  context: context,
                  text: 'btnContinue'.tr,
                  callFunction: () {
                       // TODO :
                      // update spare order setting price and totalPrice and ...
                      double deliveryPrice = controller.order.totalPrice ?? 0.0;
                      double sparesTotalPrice = Get.find<ModifiedOrderController>().orderData?.offerPrice;
                      Get.find<ModifiedOrderController>().orderData?.deliveryPrice = deliveryPrice;
                      Get.find<ModifiedOrderController>().orderData?.totalPrice = (sparesTotalPrice ?? 0) + (deliveryPrice ?? 0);
                      Get.find<ModifiedOrderController>().orderData?.status = 5;
                      // go to spare order details
                    Get.to(SparesOrderDetails());
                  }
              ),
            ) : Column(
              children: [
                GetBuilder<OrderingController>(
                  builder: (controller) => Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("طريقة الدفع".tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.5)),
                        SizedBox(height: Get.height * 0.025),
                        paymentMethodCard(icon: Icons.credit_card, name: "بطاقة ماستر او فيزا", key: "CARD" ),
                        paymentMethodCard(icon: Icons.money_sharp, name: "بطاقة مدى", key: "MADA"),
                        paymentMethodCard(icon: Icons.clean_hands, name: "الدفع كاش", key: "CASH"),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: Get.width * 0.9,
                  child: flatButtonWidget(
                      context: context,
                      text: 'btnContinue'.tr,
                      callFunction: () {
                        if(controller.order.payVia == null) {
                          GetxWidgetHelpers.mSnackBar("طريقة الدفع", "يرجى اختيار طريقة الدفع المناسبة لك!");
                          return;
                        }
                        Get.to(PayOrderScreen(paymentMethod: controller.order.payVia));
                      }
                  ),
                ),
              ],
            ),

            SizedBox(height: Get.height * 0.03),

          ],
        ),
      ),
    );
  }

  Widget paymentMethodCard({IconData icon, String name, bool selected = false, String key}) {
    selected = controller.order.payVia == key;
    return Transform.scale(
      scale: selected ? 1.03 : 1.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 170),
        margin: EdgeInsets.only(bottom: 15.0),
        decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 7,
                  offset: Offset(0,0)
              )
            ]
        ),
        child: ListTile(
          onTap: () {
            controller.order.payVia = key;
            controller.setOrder = controller.order;
          },
          leading: Icon(icon, color: selected ? Colors.white : Get.theme.primaryColor),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: selected ? Colors.white : Get.theme.primaryColor)),
          selected: selected,
        ),
      ),
    );
  }
}
