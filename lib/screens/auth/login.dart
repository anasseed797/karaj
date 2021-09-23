import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/warp_widget.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/authController.dart';
import 'package:karaj/ui_widgets/animations/fade_animation.dart';

class LoginScreen extends GetWidget<AuthController> {
  final TextEditingController _phone = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return WrapTextOptions(
      child: Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: appBar(title: 'login'.tr),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: FadeAnimation(
              delay: 1.6,
              child: Container(
                color: Get.theme.backgroundColor,
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeAnimation(delay: 1.6,child: Center(child: Text('enterNumberTitle'.tr, style: TextStyle(fontWeight: FontWeight.bold),))),
                    FadeAnimation(delay: 1.7,child: Text('enterNumberText'.tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.0, color: Colors.grey),)),
                    SizedBox(height: 25.0),
                    FadeAnimation(
                      delay: 1.8,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _phone,
                          validator: (value) {
                            if (value != null && (value.length > 9 || value.length < 9)) {
                              return "enterCorrectPhone".tr;
                            }
                            return null;
                          },
                          decoration: inputDecorationUi(context, 'numberPhone'.tr, suffixText: " 00966 ", color: Get.theme.scaffoldBackgroundColor),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ),
                    SizedBox(height: 25.0),
                    FadeAnimation(
                      delay: 1.9,
                      child: Container(
                        width: Get.width,
                        child: normalFlatButtonWidget(
                          context: context,
                          text: 'btnSendCode'.tr,
                          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                          radius: 5.0,
                          callFunction: () {
                            if(_formKey.currentState.validate()) {
                              controller.login("+966${_phone.text}");
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
