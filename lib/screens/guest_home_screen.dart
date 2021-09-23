import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/screens/auth/login.dart';
import 'package:karaj/services/localization_services_lang.dart';
import 'package:karaj/ui_widgets/animations/fade_animation.dart';
import 'package:karaj/ui_widgets/home_card.dart';

class GuestHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (controller) {
        bool isEnglish = Get.locale.languageCode == 'en';
        return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeAnimation(
                      delay: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: InkWell(
                          onTap: () {
                            LocalizationService().changeLocale(isEnglish ? 'عربي' : 'English');
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(color: Colors.grey),
                                color: Get.theme.backgroundColor
                            ),
                            child: Text(isEnglish ? "arabic".tr : "english".tr, style: TextStyle(fontSize: 13.0)),
                          ),
                        ),
                      ),
                    ),
                    FadeAnimation(
                      delay: 1.4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(icon: Icon(Icons.menu_rounded, size: 30.0), onPressed: () => Get.to(LoginScreen())),
                      ),
                    ),
                  ],
                ),

                FadeAnimation(delay: 1.6,child: Text('howCanHelp'.tr, style: TextStyle(color: Color(0xFF404b69), fontWeight: FontWeight.bold, fontSize: 45.0))),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: HomeCard(
                          image: 'assets/images/vehicle1.jpeg',
                          text: "orderType1".tr,
                          navTo: LoginScreen(),
                          delay: 1.7,
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Expanded(
                        child: HomeCard(
                          image: 'assets/images/vehicle2.jpeg',
                          text: "orderType2".tr,
                          navTo: LoginScreen(),
                          delay: 1.8,
                        ),
                      )
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: HomeCard(
                          icon: Icons.handyman,
                          text: 'spares'.tr,
                          navTo: LoginScreen(),
                          delay: 1.9,
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Expanded(
                        child: HomeCard(
                          icon: Icons.hearing,
                          text: 'sos'.tr,
                          navTo: LoginScreen(),
                          delay: 2.0,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
        },
    );
  }
}
