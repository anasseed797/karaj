import 'dart:convert';
import 'package:assets_audio_player/assets_audio_player.dart' as audio;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/screens/orders/order_details.dart';
import 'package:karaj/screens/spares/details/spares_order_details.dart';
import 'package:karaj/screens/user/user_my_orders.dart';
import 'package:karaj/services/database.dart';
import 'package:http/http.dart' as http;

import 'package:karaj/ui_widgets/notificationAlert.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;


  static void handleFrontNotification(RemoteMessage message) {
    final audioPlayer = audio.AssetsAudioPlayer();

    Get.snackbar(message.notification.title, message.notification.body, duration: Duration(seconds: 5), onTap: (v)  {
      if(message.data.containsKey("order_id")) {
        audioPlayer.open(audio.Audio("assets/sounds/sms-alert-3-daniel_simon.mp3"));
        audioPlayer.play();
        if(message.data['type'].toString().toUpperCase().contains("ORDER")) {
          Get.to(OrderDetails(orderIDX: message.data["order_id"].toString()));
        } else if(message.data['type'].toString().toUpperCase().contains("SPARE")) {
          Get.to(UserMyOrders());
        }
      }

    }, backgroundColor: Get.theme.backgroundColor.withOpacity(0.7));
  }


  static Future backgroundMessage(RemoteMessage message) async {
    print("================================== PushNotificationService backgroundMessage()");
    Firebase.initializeApp();
  /*  if(message.data['type'].toString() == "newOrder") {
      displayOrderDialog(message.data["order_id"].toString());
    } else {
      handleFrontNotification(message);
    }*/
  }



  Future init() async {
    print("================================== PushNotificationService init()");
    await Firebase.initializeApp();
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(PushNotificationService.backgroundMessage);
    FirebaseMessaging.onMessage.listen((message) async {
        if(message.data['type'].toString() == "newOrder") {
          displayOrderDialog(message.data["order_id"].toString());
        } else  { // if (message.data['driverAcceptOrder'])
          handleFrontNotification(message);
        }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("=================================== onMessageOpenedApp $message");
      if(message.data['type'].toString().toUpperCase().contains("ORDER")) {
        Get.to(OrderDetails(orderIDX: message.data["order_id"].toString()));
      } else if(message.data['type'].toString().toUpperCase().contains("SPARE")) {
        Get.to(UserMyOrders());
      }
    });

    getToken();
  }




  Future getToken() async {
    print("================================== PushNotificationService getToken()");

    if(FirebaseAuth.instance.currentUser != null) {
      String token = await _fcm.getToken();
      await Database().saveToken(token);
    }

  }



  static Future<void> displayOrderDialog(String orderID) async {
    if(orderID != null) {
      final audioPlayer = audio.AssetsAudioPlayer();
      audioPlayer.open(audio.Audio("assets/sounds/sms-alert-3-daniel_simon.mp3"));
      audioPlayer.play();
      OrderModel order = await Database().getOrder(orderID);
      Get.dialog(NotificationAlert(order: order));
    }
  }

  Future sendNotification({String title, String body, String type, String orderID, String token}) async {
    Map<String, dynamic> notificationDATA = {
      "notification": {
        "title": title,
        "body": body,
        "sound": "default"
      },
      "priority": "high",
      "apns": {
        "payload": {
          "aps": {
            "sound": "default"
          }
        }
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "type": type,
        "status": "done",
        "order_id": orderID
      },
      "to": token
    };

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAWwkAHRo:APA91bGrdNCWLtC3mwbgf92svclPbvctnC0_L269Ul5ox99SCSEKPC0qg8ieYmynFRXpqGzhxU13ip8uu5PGTYLeyCAYyjgLsYqUrzGrgzoTHQZUHEc09kSG3nUGczDt2xO6EtDF5T9a',
      },
      body: jsonEncode(notificationDATA),
    );
  }
}