import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/services/categories_data.dart';

class CancelOrderReasons extends StatefulWidget {

  @override
  _CancelOrderReasonsState createState() => _CancelOrderReasonsState();
}

class _CancelOrderReasonsState extends State<CancelOrderReasons> {
  final List<String> reasons = CancelRideReasons.reasons;
  String selectedReason = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.05),
              Container(
                child: Image(
                  image: AssetImage("assets/images/cancel.png"),
                  width: Get.width * 0.5,
                ),
              ),
              Text("سبب الغاء الطلب", style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.w600),),
              SizedBox(height: 15),
              for (String reason in reasons) AnimatedContainer(
                duration: Duration(milliseconds: 350),
                margin: EdgeInsets.only(bottom: 15.0),
                decoration: BoxDecoration(
                    color: reason == selectedReason ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 7,
                          offset: Offset(0,0)
                      )
                    ]
                ),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      selectedReason = reason;
                    });
                  },
                  title: Text(reason ?? "", style: TextStyle(color: reason == selectedReason ? Colors.white : Colors.black),),
                  trailing: Container(
                    width: 35,
                    height: 35,
                    child: reason == selectedReason ? FlareActor(
                      "assets/flr/SuccessCheck.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: "Untitled",
                      color: Colors.white,
                    ) : SizedBox.shrink(),
                  ),
                ),
              ),

              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: normalFlatButtonWidget(
                          context: context,
                          text: "الغاء الطلب",
                          colour: Color(0xFFfcf0f0),
                          textColor: Color(0xFFb22a4a),
                          radius: 5,
                          callFunction: () {
                            if(selectedReason != "" && selectedReason != null) {
                              Get.back(result: "canceledBy-$selectedReason");
                            } else {
                              GetxWidgetHelpers.mSnackBar("", "يرجى اختيار سبب الغاء الطلب.");
                            }
                          }

                      ),
                    ),
                    SizedBox(width: 15.0),
                    Expanded(
                      child: normalFlatButtonWidget(
                          context: context,
                          text: "تراجع",
                          colour: Color(0xFFf0f2f4),
                          textColor: Colors.black,
                          radius: 5,
                          callFunction: () => Get.back()
                      ),
                    )
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