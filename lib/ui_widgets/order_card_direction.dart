import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/order.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderCardDirection extends StatelessWidget {

  final OrderModel orderModel;
  final bool displayShadow;

  const OrderCardDirection({Key key, this.orderModel, this.displayShadow = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = 5.0;
    if(orderModel.fromFullAddress != null) {
      int le = orderModel.fromFullAddress.length;
      if(le < 43) {
        height = 33;
      } else if (le > 43 && le < 100){
        height = 60;
      } else {
        height = 80;
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(displayShadow ? 0.03 : 0),
              offset: Offset(0, 3),
              blurRadius: 3
            )
          ]
      ),
      padding: EdgeInsets.all(15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                    onTap: () => Helpers.launchMap(lat: orderModel.fromLat, lng: orderModel.fromLng),
                    child: Icon(Icons.location_history, color: Color(0xffff5267))
                ),
                Container(
                  height: height + (displayShadow ? 0 : 15.0),
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Get.theme.primaryColor, style: BorderStyle.solid),

                    )
                  ),
                ),
                InkWell(
                    onTap: () => Helpers.launchMap(lat: orderModel.toLat, lng: orderModel.toLng),
                    child: Icon(Icons.location_on, color: Color(0xff228cff)),
                ),

              ],
            ),
          ),

          Expanded(
            child: Container(
              child: orderModel.orderType == 2 ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(orderModel.fromFloorString ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(orderModel.fromFullAddress ?? '', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 15.0),
                  Text(orderModel.toFloorString ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(orderModel.toFullAddress ?? '', overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.grey)),
                ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(orderModel.isSpareOrder == true ? 'نقل من المتجر' : 'نقل من', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(orderModel.fromFullAddress ?? '', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 15.0),
                  Text('تنزيل في', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(orderModel.toFullAddress ?? '', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
