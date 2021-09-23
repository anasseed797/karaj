import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/services/PushNotificationService.dart';
import 'package:karaj/services/database.dart';

class ModifiedOrderController extends GetxController {
  Rx<SparesModel> order = SparesModel().obs;
  SparesModel get orderData => order.value;
  set setOrder(SparesModel value) => order.value = value;

  bool onCreatingOrder = false;

  void updateItems({int index,Item item}) {
    order.value.items[index] = item;
    this.setPrices();
    update();
  }

  void removeItem({int index}) async {
    Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
    order.value.items.removeAt(index);
    if(order.value.items.isEmpty) {
      await Database().deleteDocument(docName: 'spares', docID: order.value.id);
      Get.back();
      Get.back();

      Get.snackbar('تم حذف الطلب', "يما انك قمت بازالة جميع القطع المطلوبة فذلك ادى الى ازالة الطلب بشكل كامل");
    } else {
      Map<String, dynamic> data = {};
      data = order.value.toMap();
      await Database().updateDocument(data: data,docName: 'spares', docID: order.value.id);
      this.setPrices();
      Get.back();

    }
    update();
  }

  void updateStatus(int status) {
    order.value.status = status;
    setPrices();
    update();
  }

  void setPrices() async {
    List<Item> itemsAvailable = orderData?.items ?? [];
    if(itemsAvailable != null) {
      itemsAvailable.where((element) => element.available == true);
      double itemsPrice = itemsAvailable?.fold(0, (previousValue, element) => previousValue + (element.price ?? 0));
      double itemsDiscounts = itemsAvailable?.fold(0, (previousValue, element) => previousValue + (element.discount ?? 0));
      order.value.price = itemsPrice;
      order.value.discount = itemsDiscounts;
      var offerPrice = itemsPrice - itemsDiscounts;
      double tax = (offerPrice / 100) * 15;
      offerPrice = offerPrice + tax;
      var totalPrice = offerPrice + (order.value.deliveryPrice ?? 0);
      order.value.tax = double.tryParse(tax.toStringAsFixed(2) ?? '0.0');
      order.value.totalPrice = totalPrice;
      order.value.offerPrice = offerPrice;
      Map<String, dynamic> data = {};
      data = order.value.toMap();
      await Database().updateDocument(data: data,docName: 'spares', docID: order.value.id);
    }

  }

  void submitOffer() async {
    Map<String, dynamic> data = {};
    order.value.status = 2;
    data = order.value.toMap();
    await Database().updateDocument(data: data,docName: 'spares', docID: order.value.id);
    UserModel _clientUser = await Database().getUser(order.value.userId);
    PushNotificationService().sendNotification(
        type: 'spare',
        orderID: order.value.id,
        title: 'عرض سعر جديد.',
        body: 'لذيك عرض سعر جديد بخصوص طلبك لقطع غيار.',
        token: _clientUser.token ?? ''
    );
    Get.back();
    Get.snackbar('تم ارسال العرض', 'تم ارسال عرضك للعميل.');

  }


  void giveItToDriver() async {
    Map<String, dynamic> data = {};
    order.value.status = 7;
    data = order.value.toMap();
    await Database().updateDocument(data: data,docName: 'spares', docID: order.value.id);
    UserModel _clientUser = await Database().getUser(order.value.userId);
    PushNotificationService().sendNotification(
        type: 'spare',
        orderID: order.value.id,
        title: 'تم تسليم الطلب.',
        body: 'تم تسليم الطلب لسائق.',
        token: _clientUser.token ?? ''
    );
    Get.back();
    Get.snackbar('تم ارسال العرض', 'تم ارسال عرضك للعميل.');

  }

  void giveItToUser() async {
    Map<String, dynamic> data = {};
    order.value.status = 9;
    data = order.value.toMap();
    await Database().updateDocument(data: data,docName: 'spares', docID: order.value.id);
    UserModel _clientUser = await Database().getUser(order.value.userId);
    PushNotificationService().sendNotification(
        type: 'spare',
        orderID: order.value.id,
        title: 'تم تسليم الطلب.',
        body: 'قام صاحب المحل بتعليم الطلب على انه منتهي وقد استلمت قطع غيار خاصة بك.',
        token: _clientUser.token ?? ''
    );
    Get.back();
    Get.snackbar('تم ارسال العرض', 'تم ارسال عرضك للعميل.');

  }

  Future<SparesModel> submitOrder() async {
    if(!onCreatingOrder && FirebaseAuth.instance.currentUser != null && order.value?.totalPrice != null) {
      try {
        onCreatingOrder = true;
        Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
        SparesModel o = order.value;
        o.status = 6;
        Map<String, dynamic> data = o.toMap();
        await Database().updateDocument(docName: "spares", docID: o.id, data: data);
        UserModel _shop = await Database().getUser(o.shopId);
        String body = 'قام صاحب الطلب بدفع مبلغ القطع يرجر تجهزها لتسليم.';
        if(o.deliveryPrice != null || o.deliveryPrice > 0) {
          body = 'قام صاحب الطلب بدفع مبلغ القطع يرجر تجهزها لكي يتم تسلمها لسائق النقل.';
        }
        PushNotificationService().sendNotification(
            type: 'spare',
            orderID: o.id,
            title: 'تم دفع مبلغ القطع.',
            body: body,
            token: _shop.token ?? ''
        );
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