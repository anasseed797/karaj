import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:karaj/controllers/orderingController.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/services/database.dart';

class PaymentController extends GetxController {


  static Future sendAnInitialPayment({Map<String, dynamic> data}) async {
    if(data != null) {
      try {
        String url = "https://test.oppwa.com/v1/payments";
        data["entityId"] = "8a8294174b7ecb28014b9699220015ca";
        http.Response res = await http.post(
            Uri.tryParse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer OGFjN2E0Yzg3NTU1ZDM2ODAxNzU1ZWQ2YzkyZDBiZGF8OTZNNGFUV1BQQQ=='
            },
          body: jsonEncode(data),
        );

        Map<String, dynamic> body = jsonDecode(res.body);
        print(body);
        if(res.statusCode == 200) {

          if(body != null && res.body.contains("result")) {
            Map<String, dynamic> result = body["result"];
            if(result != null && result.containsKey("code")) {
              if(result["code"].toString() == "000.100.110") {
                Get.find<OrderingController>().order.paymentId = body["ndc"];
                return "payed";
              }
            }
          }
          return data;
        } else {
          if(body != null && res.body.contains("result")) {
          //  Map<String, dynamic> result = body["result"];
            Get.snackbar(body["result"]["description"], "${body["result"]["parameterErrors"][0]["name"]} : ${body["result"]["parameterErrors"][0]["message"]}");
          }
          return 'error';
        }
      } catch (e) {
        Get.snackbar('حدث خطاء!', e.toString());
        return 'error';
      }
    }
  }



  static Future createOrderPayment({OrderModel order, String paymentID, String payVia, String type = "order", String typeX, String forId, bool cutCommission = false}) async {

    double commissionAmount = (order.totalPrice / 100) * 5;
    DateTime now = DateTime.now();
    String id = now.microsecondsSinceEpoch.toString();
    double totalPrice = order.totalPrice;
    if(typeX == "discount") {
      totalPrice = order.totalPrice * -1;
    } else if(typeX == "added" && cutCommission == true) {
      totalPrice = totalPrice - commissionAmount;
    }
    Map<String, dynamic> data = {
      "amount": order.totalPrice,
      "commission": 5,
      "commissionAmount": commissionAmount,
      "date": intl.DateFormat.yMd().add_Hm().format(now),
      "hour": intl.DateFormat.Hm().format(now),
      "userId": forId == null ? order.userId : forId,
      "forId": order.id,
      "id": id,
      "paymentId": paymentID,
      "payVia": payVia ?? "",
      "timestamp": id,
      "totalAmount": totalPrice,
      "paymentType": type, // order or recive ...
      "typeX": typeX
    };
    UserModel user = await Database().getUser(forId == null ? order.userId : forId);
    double balance = user.balance;
    double totalBalance = user.totalBalance;
    if(balance == null) {
      balance = 0;
    }

    if(totalBalance == null) {
      totalBalance = 0;
    }

    if(typeX == "discount") {
      balance = balance - order.totalPrice;
    } else if(typeX == "added") {
      balance = balance + totalPrice;
      totalBalance = totalBalance + totalPrice;
    }
    await Database().updateDocument(docName: "users", docID: user.id, data: {"balance": balance, "totalBalance": totalBalance}, donTShowLoading: true);
    await Database().updateDocument(docName: 'payments', docID: id, data: data, donTShowLoading: true);

  }

  static Future createCommissionPayment({OrderModel order, String userId}) async {

    double commissionAmount = (order.totalPrice / 100) * 5;
    DateTime now = DateTime.now();
    String id = now.microsecondsSinceEpoch.toString();
    Map<String, dynamic> data = {
      "amount": order.totalPrice,
      "commission": 0,
      "commissionAmount": commissionAmount,
      "date": intl.DateFormat.yMd().add_Hm().format(now),
      "hour": intl.DateFormat.Hm().format(now),
      "userId": userId,
      "forId": order.id,
      "id": id,
      "paymentId": null,
      "payVia": "app",
      "timestamp": id,
      "totalAmount": commissionAmount * -1,
      "paymentType": "order", // order or recive ...
      "typeX": "discount"
    };
    UserModel user = await Database().getUser(userId);
    double balance = user.balance;
    balance = balance - commissionAmount;
    await Database().updateDocument(docName: "users", docID: user.id, data: {"balance": balance});
    await Database().updateDocument(docName: 'payments', docID: id, data: data, donTShowLoading: true);

  }


  static Future createSparePayment({SparesModel order, String paymentID, String payVia, String type = "spares", String typeX, String forId, bool cut = false}) async {

    double commissionAmount = (order.totalPrice / 100) * 5;
    DateTime now = DateTime.now();
    String id = now.microsecondsSinceEpoch.toString();
    double totalPrice = order.totalPrice;
    if(typeX == "discount") {
      totalPrice = order.totalPrice * -1;
    } else if(typeX == "added" && cut == true) {
      totalPrice = totalPrice - commissionAmount;
    }
    Map<String, dynamic> data = {
      "amount": order.totalPrice,
      "commission": 5,
      "commissionAmount": commissionAmount,
      "date": intl.DateFormat.yMd().add_Hm().format(now),
      "hour": intl.DateFormat.Hm().format(now),
      "userId": forId == null ? order.userId : forId,
      "forId": order.id,
      "id": id,
      "paymentId": paymentID,
      "payVia": payVia ?? "",
      "timestamp": id,
      "totalAmount": totalPrice,
      "paymentType": type, // order or recive ...
      "typeX": typeX
    };
    UserModel user = await Database().getUser(forId == null ? order.userId : forId);
    double balance = user.balance;
    if(balance == null) {
      balance = 0;
    }
    if(typeX == "discount") {
      balance = balance - order.totalPrice;
    } else if(typeX == "added") {
      balance = balance + totalPrice;
    }
    await Database().updateDocument(docName: "users", docID: user.id, data: {"balance": balance}, donTShowLoading: true);
    await Database().updateDocument(docName: 'payments', docID: id, data: data, donTShowLoading: true);

  }
/*
    String id = now.microsecondsSinceEpoch.toString();
    double totalPrice = order.totalPrice;
    double commissionAmount;
    if(type == "discount") {
      totalPrice = order.totalPrice * -1;
    } else if(type == "added") {
      commissionAmount = (totalPrice / 100) * 5;
      totalPrice = totalPrice - commissionAmount;
    }
    Map<String, dynamic> data = {
      "commission": 5,
      "commissionAmount": commissionAmount,
      "amount": type == "discount" ? order.totalPrice * -1 : order.totalPrice,
      "date": intl.DateFormat.yMd().add_jm().format(now),
      "hour": intl.DateFormat.Hm().format(now),
 */

}