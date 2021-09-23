import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/screens/user/sign_select_type_information_form.dart';

class WaitingForReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: Get.height * 0.1),
                height: Get.height * 0.5,
                child: FlareActor(
                  "assets/flr/SuccessCheck.flr",
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: "Untitled",
                ),
              ),
              Center(child: Text("الحساب قيد المراجعة", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),)),

              Center(child: Text("حسابك قيد المراجعة حتى نقوم بمراجعته. يستغرق الامر عادة أقل من 48 ساعة. سوف نقوم باشعارك قريبا!", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600),)),
              SizedBox(height: 38.5),
             /* Center(
                child: flatButtonWidget(
                  text: 'اعادة ملئ البيانات'.tr,
                  callFunction: () => Get.to(SignSelectTypeInformationForm()),
                ),
              )*/

            ],
          ),
        ),
      ),
    );
  }
}
