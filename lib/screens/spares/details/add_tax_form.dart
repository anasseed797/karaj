import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/shopOnModifiedOrder.dart';

class AddTaxForm extends GetWidget<ModifiedOrderController> {


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ModifiedOrderController>(
      builder: (ctrl) => Container(
        height: Get.height * 0.35,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: TextFormField(
                      initialValue: ctrl.orderData.tax == null ? '' : ctrl.orderData.tax.toString(),
                      onSaved: (value) {
                        ctrl.orderData.tax = double.tryParse(value ?? '0.0');
                        ctrl.setOrder = ctrl.orderData;

                      },
                      decoration: inputDecorationUi(context, 'tax'.tr, suffixText: "sar".tr,color: Colors.grey[200]),
                      keyboardType: TextInputType.number,
                    ),
                  ),

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
