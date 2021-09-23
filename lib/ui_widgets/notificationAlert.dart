import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/screens/orders/order_details.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as audio;


class NotificationAlert extends StatelessWidget {
  final OrderModel order;

  const NotificationAlert({Key key, this.order}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: Get.width * 0.8,
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
              color: Colors.white
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('${order.id}'),
              SizedBox(height: 15.0),
              CircleAvatar(
                backgroundImage: AssetImage(order.orderType == 1 ? 'assets/images/vehicle1.jpeg' : 'assets/images/vehicle2.jpeg'),
                radius: 50,
              ),
              Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_history, color: Color(0xffff5267)),
                            Container(
                              height: 35,
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Get.theme.primaryColor, style: BorderStyle.solid),

                                  )
                              ),
                            ),
                            Icon(Icons.location_on, color: Color(0xff228cff)),

                          ],
                        ),
                      ),

                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(order.fromFloorString ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(order.fromFullAddress ?? '', style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 15.0),
                              Text(order.toFloorString ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(order.toFullAddress ?? '', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
              ),
              Container(
                margin: EdgeInsets.only(top: 15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        color: Get.theme.primaryColor,
                        textColor: Colors.white,
                        child: Text(' عرض الطلب ', style: TextStyle(fontSize: 13.0)),
                        onPressed: () {
                          Get.back();
                          final audioPlayer = audio.AssetsAudioPlayer();
                          audioPlayer.open(audio.Audio("assets/sounds/sms-alert-1-daniel_simon.mp3"));
                          audioPlayer.play();
                          Get.to(OrderDetails(order: order));
                        },
                      ),
                    ),
                    SizedBox(width: 25.0),
/*
  return TextButton(
    onPressed: callFunction,
    child: Text('$text', style: Get.theme.textTheme.headline6),
    style: TextButton.styleFrom(
        backgroundColor: Get.theme.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 7.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        )
    ),
 */
                    Expanded(
                      child: FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        color: Get.theme.colorScheme.secondaryVariant,
                        textColor: Get.theme.colorScheme.primaryVariant,
                        child: Text(' الغاء ', style: TextStyle(fontSize: 13.0)),
                        onPressed: () {
                          Get.back(result: "cancel");
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
