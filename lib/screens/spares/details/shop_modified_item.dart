import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/shopOnModifiedOrder.dart';
import 'package:karaj/models/spares.dart';

class ShopModifiedItem extends GetWidget<ModifiedOrderController> {
  final Item item;

  ShopModifiedItem({Key key, this.item}) : super(key: key);


  final Map<int, Widget> availableWidget = <int, Widget> {
    1: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('متوفر')),
    0: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('غير متوفر')),
  };

  final Map<int, Widget> spareTypeWidget = <int, Widget> {
    0: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('اصلي')),
    1: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('غير اصلي')),
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    int index = controller.orderData.items.indexOf(item);
    return GetBuilder<ModifiedOrderController>(
      builder: (ctrl) => Container(
        height: Get.height * 0.6,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 35.0, top: 15.0),
                    child: CupertinoSegmentedControl(
                      children: availableWidget,
                      borderColor: Theme.of(context).primaryColor,
                      pressedColor: Theme.of(context).primaryColor,
                      selectedColor: Theme.of(context).primaryColor,

                      onValueChanged: (int val) {
                        if(val == 0) {
                          item.price = 0;
                          item.discount = 0;
                          item.available = false;
                        } else {
                          item.available = true;
                        }
                        ctrl.updateItems(index: index, item: item);
                      },
                      groupValue: (ctrl.orderData.items[index].available ?? true) ? 1 : 0,
                    ),
                  ),

                  (ctrl.orderData.items[index].available ?? true) ? Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 35.0),
                        child: CupertinoSegmentedControl(
                          children: spareTypeWidget,
                          borderColor: Theme.of(context).primaryColor,
                          pressedColor: Theme.of(context).primaryColor,
                          selectedColor: Theme.of(context).primaryColor,

                          onValueChanged: (int val) {
                            item.type = val;
                            ctrl.updateItems(index: index, item: item);
                          },
                          groupValue: ctrl.orderData.items[index].type,
                        ),
                      ),

                      item.quantity != null && item.quantity > 1 ? Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Center(
                          child: Text('يرجى ادخال مجموع سعر ال ${item.quantity} قطع.', style: TextStyle(color: Get.theme.errorColor)),
                        ),
                      ) : SizedBox.shrink(),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                          initialValue: item.price <= 0 ? '' : item.price.toString(),
                          onSaved: (value) {
                            item.price = double.tryParse(value ?? '0.0');
                            ctrl.updateItems(index: index, item: item);

                          },
                          validator: (value) {
                            if(value.isEmpty) {
                              return 'يرجى ادخال السعر';
                            }
                            return null;
                          },
                          decoration: inputDecorationUi(context, 'price'.tr, suffixText: "sar".tr,color: Colors.grey[200]),
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: TextFormField(
                          initialValue: item.discount == null || item.discount <= 0 ? '' : item.discount.toString(),
                          onSaved: (value) {
                            item.discount = double.tryParse(value ?? '0.0');
                            ctrl.updateItems(index: index, item: item);

                          },
                          decoration: inputDecorationUi(context, 'discount'.tr, suffixText: "sar".tr,color: Colors.grey[200]),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ) : SizedBox.shrink(),

                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    width: Get.width * 0.5,
                    child: flatButtonWidget(
                      context: context,
                      text: 'حفظ',
                      callFunction: () => saveModified(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void saveModified() async {
    final isValid = _formKey.currentState?.validate();
    if(!isValid) {
      return;
    }
    _formKey.currentState?.save();
    controller.updateStatus(1);

    Get.back();
  }
}
