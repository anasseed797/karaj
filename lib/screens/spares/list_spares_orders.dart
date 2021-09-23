import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/shopOnModifiedOrder.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/screens/spares/details/spares_order_details.dart';

class ListSparesOrdersWidget extends StatelessWidget {
  final List<SparesModel> orders;
  final bool displayScroll;

  const ListSparesOrdersWidget({Key key, this.orders, this.displayScroll = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<SparesModel> ordersList = orders ?? [];
    Get.put(ModifiedOrderController());
    return ListView.builder(
        physics: displayScroll ? null : NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: true,
        itemCount: ordersList.length,
        itemBuilder: (BuildContext context, index) {
          SparesModel order = ordersList[index];
          String spares = "";
          if(order.items != null && order.items.length > 0) {
            order.items.forEach((element) {
              spares = "$spares - (${element.quantity}) ${element.name}";
            });
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 7,
                      offset: Offset(0,1)
                  )
                ]
            ),
            child: InkWell(
              onTap: () {
                Get.find<ModifiedOrderController>().setOrder = order;
                Get.to(SparesOrderDetails());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FirebaseAuth.instance.currentUser?.uid == order.shopId ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('clientName'.tr, style: TextStyle(fontSize: 11.0, color: Color(0xFF949597))),
                            Text(order.userName),
                          ],
                        ) : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('shopName'.tr, style: TextStyle(fontSize: 11.0, color: Color(0xFF949597))),
                            Text(order.shopName),
                          ],
                        ),
                        Text('spares'.tr, style: TextStyle(fontSize: 11.0, color: Color(0xFF949597))),
                        Text(spares),
                      ],
                    ),
                  ),

                  Flexible(
                    child: Column(
                      children: [
                        Text('رقم الشحنة', style: TextStyle(fontSize: 11.0, color: Color(0xFF949597))),
                        GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(text: order.id));
                            GetxWidgetHelpers.mSnackBar('تم نسخ', 'تم نسخ ${order.id}');
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(color: Theme.of(context).primaryColor)
                            ),
                            child: Text(order.id ?? '', style: TextStyle(fontSize: 13.0)),
                          ),
                        ),
                        SizedBox(height: 25.0),
                        Text(orderSpareStatus(order.status), style: TextStyle(fontSize: 15.0))
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }
}
