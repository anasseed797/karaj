import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/addSparesFormController.dart';
import 'package:karaj/controllers/sparesOrderingController.dart';

class AddSpares extends GetWidget<SparesOrderingController> {

  final AddSparesFormController _ctrl = Get.put(AddSparesFormController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'addSpares'.tr),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child:  Form(
          key: _ctrl.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 35.0),
              ContainerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _ctrl.nameCtrl,
                      onSaved: (value) {
                        _ctrl.name = value;
                      },
                      validator: (value) {
                        return _ctrl.validateName(value);
                      },
                      decoration: inputDecorationUi(context, 'spareName'.tr, color: Get.theme.scaffoldBackgroundColor),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 15.0),
                    TextFormField(
                      controller: _ctrl.numberCtrl,
                      onSaved: (value) {
                        _ctrl.number = value;
                      },
                      decoration: inputDecorationUi(context, 'spareNumber'.tr, color: Get.theme.scaffoldBackgroundColor),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 15.0),
                    TextFormField(
                      controller: _ctrl.imageCtrl,
                      onSaved: (value) {
                        _ctrl.image = value;
                      },

                      decoration: inputDecorationUi(context, 'spareImage'.tr, color: Get.theme.scaffoldBackgroundColor),
                      keyboardType: TextInputType.text,
                    ),

                    SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('type'.tr),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Obx(
                            () => Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 15.0),
                          child: CupertinoSegmentedControl(
                            children: _ctrl.typeWidget,
                            borderColor: Theme.of(context).primaryColor,
                            pressedColor: Theme.of(context).primaryColor,
                            selectedColor: Theme.of(context).primaryColor,

                            onValueChanged: (int val) {
                              _ctrl.switchType = val;
                            },
                            groupValue: _ctrl.type,
                          ),
                        )
                    ),
                    SizedBox(height: 15.0),


                    Container(
                      width: Get.width,
                      child: normalFlatButtonWidget(
                        context: context,
                        text: 'addSpare'.tr,
                        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                        radius: 5.0,
                        callFunction: () async{
                          bool isValid = await _ctrl.saveData();
                          if(isValid) {
                            Get.back();
                          }
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
