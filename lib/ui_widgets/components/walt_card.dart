import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/screens/user/tabs/main_tabs_content.dart';

class WaltCard extends GetWidget<UserController> {
  final String amount;
  final bool isHomeScreen;
  const WaltCard({Key key, this.amount, this.isHomeScreen = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if(Get.find<UserController>().user == null) {
      return Container();
    } else {
      Color colourBgBtn = Get.theme.backgroundColor;
      Color textColoBtn = Get.theme.primaryColor;
      Color textColor = Get.theme.colorScheme.secondaryVariant;

      if(!isHomeScreen) {
        colourBgBtn = Color(0xFF34B55E);
        textColoBtn = Get.theme.backgroundColor;
        textColor = Get.theme.colorScheme.primary;
      }

      UserModel _user = Get.find<UserController>().user;
      Widget waltButton = normalFlatButtonWidget(
        context: context,
        callFunction: () => {},
        text: 'btnRequestPayment'.tr,
        colour: colourBgBtn,
        textColor: textColoBtn,
        radius: 5.0,
      );

      if(!_user.isShop && !_user.isDriver) {
        if(isHomeScreen) {
          waltButton = normalFlatButtonWidget(
            context: context,
            callFunction: () {
              Get.to(MainTabsContent(selectedIndex: 1));
            },
            text: 'myWallet'.tr,
            colour: colourBgBtn,
            textColor: textColoBtn,
            radius: 5.0,
          );
        } else {
          waltButton = Container();
        }
      }



      return Obx(
            () => Row(
          children: [
            waltButton,
            Expanded(
              child: Get.find<UserController>().user?.balance == null ? Container() : Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Get.locale.languageCode == "ar" ? Alignment.centerLeft : Alignment.centerRight,
                    child: Text("${Helpers.fixPrice(Get.find<UserController>().user.balance)} ${"sar".tr}", style: Get.theme.textTheme.headline5.copyWith(color: textColor)),
                  ),
                  Align(
                      alignment: Get.locale.languageCode == "ar" ? Alignment.centerLeft : Alignment.centerRight,
                      child: Text(Get.find<UserController>().user.balance < 0 ? 'yourFees'.tr: 'yourBalance'.tr, style: TextStyle(color: textColor),)),
                ],
              ),
            ),
          ],
        ),
      );
    }

  }
}
