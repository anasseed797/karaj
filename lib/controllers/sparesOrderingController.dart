import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/services/database.dart';

class SparesOrderingController extends GetxController {

  Rx<bool> _onLoading = false.obs;
  set setLoading(bool x) => this._onLoading.value = x;
  bool get onLoading => _onLoading.value;

  Rx<int> _orderStep = 0.obs;
  set setStep(int x) => this._orderStep.value = x;
  int get step => _orderStep.value;

  Rx<SparesModel> _order = SparesModel(
    status: 0,
    items: [],
  ).obs;

  SparesModel get order => _order.value;

  set setOrder(SparesModel _o) => this._order.value = _o;


  clear() {
    _orderStep.value = 0;
    _order.value = SparesModel(
      status: 0,
      items: [],
    );
  }

  void addQty(index, adding) {
    if(adding) {
      _order.value.items[index].quantity++;
    } else {
      _order.value.items[index].quantity--;
    }
    update();
  }

  void setItems(List<Item> items) {
    _order.value.items = items;
    update();
  }


  Future<SparesModel> submitOrder({UserModel shop}) async {
    if(FirebaseAuth.instance.currentUser != null) {
      try {
        SparesModel o = _order.value;
        o.status = 1;
        o.userId = FirebaseAuth.instance.currentUser.uid;
        o.userName = FirebaseAuth.instance.currentUser.displayName;
        o.userPhone = FirebaseAuth.instance.currentUser.phoneNumber;
        o.shopId = shop.id;
        o.shopName = "${shop.lastName} ${shop.lastName}";
        o.shopPhone = shop.phone;
        o.shopAddress = shop.personalData["addressData"]["address"];
        o.shopAddressData = shop.personalData["addressData"];
        if(shop.personalData["commercialName"] != null) {
          o.shopName = shop.personalData["commercialName"];
        }

        Map<String, dynamic> data = o.toMap();
        await Database().createSpareOrder(data);

        return o;
      } catch (e) {
        print("================== submitSpareOrder catch error says : $e");
        return null;
      }
    } else {
      return null;
    }
  }


}