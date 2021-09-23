import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/sparesOrderingController.dart';
import 'package:karaj/models/spares.dart';

class AddSparesFormController extends GetxController {
  GlobalKey<FormState> formKey;
  TextEditingController nameCtrl,numberCtrl,imageCtrl;
  String name, number, image;
  Rx<int> _type = 0.obs;
  set switchType(value) => _type.value = value;
  int get type => _type.value;


  final Map<int, Widget> typeWidget = <int, Widget> {
    0: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('original'.tr)),
    1: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('firstClass'.tr)),
  };
  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController();
    numberCtrl = TextEditingController();
    imageCtrl = TextEditingController();
    formKey = GlobalKey<FormState>();
  }

  @override
  void onClose() {
    super.onClose();
    nameCtrl.dispose();
    numberCtrl.dispose();
    imageCtrl.dispose();
  }


  String validateName(String value) {
    if(value == null || value.isEmpty) {
      return "EnterACorrectName".tr;
    } else if (value.length <= 3) {
      return "EnterACorrectName".tr;
    }
    return null;
  }



  Future<bool> saveData() async {
    final isValid = formKey.currentState?.validate();
    if(!isValid) {
      return false;
    }
    formKey.currentState?.save();
    Item _item = Item(
      name: name,
      number: number,
      image: image,
      type: type,
      typeString: type == 0 ? 'اصلي' : 'درجة اولى',
      available: null,
      price: null,
      quantity: 1,
    );
    SparesModel _sp = Get.find<SparesOrderingController>().order;
    if(_item == null) {
      _sp.items = [_item];
    } else {
      _sp.items.add(_item);
    }

    nameCtrl.text = '';
    numberCtrl.text = '';
    imageCtrl.text = '';
    Get.find<SparesOrderingController>().setItems(_sp.items);
    return true;
  }
}