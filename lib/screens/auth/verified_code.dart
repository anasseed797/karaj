import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/warp_widget.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/authController.dart';
import 'package:karaj/ui_widgets/animations/fade_animation.dart';

class VerifiedCode extends GetWidget<AuthController> {

  final String numberPhone;
  VerifiedCode(this.numberPhone);


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _code = TextEditingController();
  final bool onLoading = false;


  @override
  Widget build(BuildContext context) {
    controller.onLoading.value = false;

    return WrapTextOptions(
      child: Scaffold(
        appBar: appBar(title: 'verifiedCode'.tr),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: onLoading ? Center(
            child: Container(
              width: Get.width / 2,
              height: Get.height / 4,
              child: LoadingScreen(true),
            ),
          ): Obx(
              () => AnimatedSwitcher(
                duration: Duration(milliseconds: 1),
                child: controller.logged.value ? Container(
                  child: FlareActor(
                      "assets/flr/SuccessCheck.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: controller.logged.value ? "Untitled" : "nothing",
                  ),
                ) : Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeAnimation(
                        delay: 1.6,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Get.theme.backgroundColor
                          ),
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            children: [
                              Text("enterCode".tr, style: TextStyle(fontWeight: FontWeight.bold),),
                              Text('${"enterCode".tr} \n $numberPhone', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.0, color: Colors.grey),),
                              SizedBox(height: 25.0),
                              Form(
                                key: _formKey,
                                child: Container(
                                  width: Get.width * 0.5,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: _code,
                                    validator: (value) {
                                      if(value == null || value.trim().isEmpty) {
                                        return 'enterCodeValid'.tr;
                                      } else if(value.length != 6){
                                        return 'wrongCode'.tr;
                                      }
                                      return null;
                                    },
                                    decoration: inputDecorationUi(context, '', color: Get.theme.scaffoldBackgroundColor),
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    textDirection: TextDirection.ltr,
                                    maxLength: 6,
                                  ),
                                ),
                              ),
                              SizedBox(height: 25.0),
                              Container(
                                width: Get.width,
                                child: normalFlatButtonWidget(
                                  onLoading: controller.onLoading.value,
                                  context: context,
                                  text: 'submitCode'.tr,
                                  padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
                                  radius: 5.0,
                                  callFunction: () async {
                                    if(_formKey.currentState.validate()) {
                                      controller.onLoading.value = true;
                                      await controller.verifiedCodeFunction(_code.text);
                                      controller.onLoading.value = false;
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      )
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