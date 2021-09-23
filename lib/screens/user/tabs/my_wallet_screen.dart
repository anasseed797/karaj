import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/warp_widget.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/screens/orders/order_details.dart';
import 'package:karaj/screens/spares/details/spares_order_details.dart';
import 'package:karaj/services/routing.dart';
import 'package:karaj/ui_widgets/components/walt_card.dart';

class MyWalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light
    ));
    UserModel _user = Get.find<UserController>().user;
    return WrapTextOptions(
      child: SafeArea(
        child: Scaffold(
          appBar: appBar(title: '', clr: Get.theme.primaryColor, iconClr: Get.theme.backgroundColor),
          backgroundColor: Color(0xfff5f5fd),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Stack(
                  children: [
                    Container(
                      height: Get.height * 0.25,
                      width: Get.width,
                      color: Get.theme.primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          circleAvatarNetwork(
                            src: _user.avatar,
                            radius: 25,
                          ),
                          SizedBox(height: 5.0),
                          Text("${_user.firstName} ${_user.lastName}", style: TextStyle(fontWeight: FontWeight.bold, color: Get.theme.backgroundColor, fontSize: 21.0)),
                          Text("${_user.fullAddress}", style: TextStyle(color: Get.theme.backgroundColor, fontSize: 13.0)),
                          Container(
                            padding: const EdgeInsets.all(15.0),
                            margin: const EdgeInsets.only(top: 25.0),
                            decoration: BoxDecoration(
                                color: Get.theme.backgroundColor,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 7
                                  )
                                ]
                            ),
                            child: WaltCard(),
                          )
                        ],
                      ),
                    )
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Container(
                        width: Get.width,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: WalletEarnCard(
                                      amount: Helpers.fixPrice(_user.balance),
                                      text: "رصيدك",
                                      checkAmount: true,
                                  ),
                                ),
                                SizedBox(width: 15.0),
                                Expanded(
                                  child: WalletEarnCard(
                                      amount: "0",
                                      text: "مستحقات عليك"
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: WalletEarnCard(
                                      amount: Helpers.fixPrice(_user.totalBalance),
                                      text: "اجمالي الستخدم"
                                  ),
                                ),
                                SizedBox(width: 15.0),
                                Expanded(
                                  child: WalletEarnCard(
                                      amount: "0",
                                      text: "قيد المراجعة"
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                      color: Get.theme.backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 11,
                            offset: Offset(1,1)
                        )
                      ]
                  ),
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Center(child: Text('سجل المدفوعات', style: TextStyle(color: Colors.grey))),

                      StreamBuilder<Object>(
                          stream: FirebaseFirestore.instance.collection("payments").where("userId", isEqualTo: FirebaseAuth.instance.currentUser.uid).snapshots(),
                          builder: (context, snapshot) {
                            if(snapshot.hasData) {
                              QuerySnapshot records = snapshot.data;
                              return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                primary: true,
                                itemCount: records.docs.length,
                                reverse: true,
                                itemBuilder: (BuildContext context, index) {
                                  Map<String, dynamic> record = records.docs[index].data();
                                  bool added = false;
                                  if(double.tryParse(record["totalAmount"].toString()) >= 0) {
                                    added = true;
                                  }
                                  return InkWell(
                                    onTap: () {
                                      print(record);
                                      if(record["paymentType"] == "order") {
                                        Get.to(OrderDetails(orderIDX: record["forId"]));
                                      } else if(record["paymentType"] == "spares" || record["paymentType"] == "spare") {
                                        RoutingSwitch.routeToSpareOrder(id: record["forId"]);
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 5.0),
                                          decoration: BoxDecoration(
                                            color: Get.theme.backgroundColor,
                                          ),
                                          child: ListTile(
                                            title: Text("بخصوص طلب رقم ${record["forId"]}"),
                                            subtitle: Text(record["date"] ?? "", textDirection: TextDirection.ltr, textAlign: TextAlign.right,),
                                            trailing: Text("${Helpers.fixPrice(record["totalAmount"])} ${"sar".tr}" ?? "", style: TextStyle(color: !added ? Get.theme.errorColor : Colors.green),),
                                          ),
                                        ),
                                        Divider()
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Center(child: Container(height: 100, width: 100,child: LoadingScreen(true)));
                            }
                          }
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class WalletEarnCard extends StatelessWidget {
  final String amount, text;
  final Color clr;
  final bool checkAmount;
  const WalletEarnCard({Key key, this.amount, this.text, this.clr, this.checkAmount = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color clrX = clr ?? Color(0xfffdaa58);
    if(checkAmount == true) {
      double amountInit = double.tryParse(amount ?? "0.0");
      if(amountInit >= 0) {
        clrX = Color(0xFF34B55E);
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      margin: const EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
          color: Get.theme.backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 11,
                offset: Offset(1,1)
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'Cairo'),
              children: <TextSpan>[
                TextSpan(text: "$amount ", style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: clrX )),
                TextSpan(text: 'sar'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: clrX )),
              ]
            )
            ,
          ),
          Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        ],
      ),
    );
  }
}
