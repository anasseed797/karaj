import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/authController.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/screens/driver/looking_for_order.dart';
import 'package:karaj/screens/ordering/select_location_from_to.dart';
import 'package:karaj/screens/orders/on_order_map.dart';
import 'package:karaj/screens/spares/request_spares_screen.dart';
import 'package:karaj/screens/user/tabs/main_tabs_content.dart';
import 'package:karaj/services/localization_services_lang.dart';
import 'package:karaj/ui_widgets/animations/fade_animation.dart';
import 'package:karaj/ui_widgets/clips/home_clipper.dart';
import 'package:karaj/ui_widgets/components/walt_card.dart';
import 'package:karaj/ui_widgets/home_card.dart';

class HomeScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    bool isEnglish = Get.locale.languageCode == 'en';
    print("================================== HomeScreen()");
    return GetBuilder<UserController>(
      builder: (controller) => Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              ClipPath(
                child: Container(
                  color: Get.theme.primaryColor, // 089A2B | 34B55E
                  height: Get.height * 0.4,
                ),
                clipper: HomeClipper(),
              ),
              SingleChildScrollView(
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
                          delay: 1.4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(icon: Icon(Icons.menu_rounded, size: 30.0, color: Get.theme.backgroundColor,), onPressed: () => Get.to(MainTabsContent(isShop: controller.user.isShop))),
                          ),
                        ),

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
                                    color: Get.theme.backgroundColor
                                ),
                                child: Text(isEnglish ? "arabic".tr : "english".tr, style: TextStyle(fontSize: 13.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    WaltCard(isHomeScreen: true),
                    Container(
                      margin: EdgeInsets.only(top: 27.0),
                      child: FadeAnimation(
                        delay: 1.6,
                        child: controller.user.isDriver ? SizedBox.shrink() : Text('services'.tr, style: TextStyle(color: Get.theme.backgroundColor, fontWeight: FontWeight.bold, fontSize: 27.0)),
                      ),
                    ),
                   /* FadeAnimation(
                      delay: 1.6,
                      child: controller.user.isDriver ? startWorkSwitchCard(controller) : onRideCardForUser(controller),
                    ),*/

                    !controller.user.isDriver && !controller.user.isShop ? Container(
                      margin: EdgeInsets.only(top: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: HomeCard(
                              image: 'assets/images/vehicle1.jpeg',
                              text: "orderType1".tr,
                              navTo: SelectLocation(
                                orderType: 1,
                                orderTypeString: "نقل وتنزيل",
                              ),
                              checkUserOnRIDE: controller.user.isOnRide ?? false,
                              delay: 1.6,
                            ),
                          ),
                          SizedBox(width: 15.0),
                          Expanded(
                            child: HomeCard(
                              image: 'assets/images/vehicle2.jpeg',
                              text: "orderType2".tr,
                              navTo: SelectLocation(
                                orderType: 2,
                                orderTypeString: "نقل تحميل تركيب",
                              ),
                              checkUserOnRIDE: controller.user.isOnRide ?? false,
                              delay: 1.7,
                            ),
                          )
                        ],
                      ),
                    ) : SizedBox.shrink(),

                    Container(
                      margin: EdgeInsets.symmetric(vertical: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          !controller.user.isDriver ? !controller.user.isShop ? Expanded(
                            child: HomeCard(
                              icon: Icons.handyman,
                              text: 'spares'.tr,
                              navTo: RequestSparesScreen(),
                              delay: 1.8,
                            ),
                          ) : Expanded(
                            child: HomeCard(
                              icon: Icons.receipt_long,
                              text: 'browseRequests'.tr,
                              callFunction: () => Get.to(MainTabsContent(isShop: true)),
                              delay: 1.6,
                            ),
                          ) : Expanded(
                            child: HomeCard(
                              icon: Icons.receipt_long,
                              text: 'browseRequests'.tr,
                              callFunction: () => startWorking(),
                              delay: 1.6,
                            ),
                          ),
                          SizedBox(width: 15.0),
                          Expanded(
                            child: HomeCard(
                              icon: Icons.hearing,
                              text: 'sos'.tr,
                              navTo: Container(),
                              delay: 1.9,
                            ),
                          )
                        ],
                      ),
                    ),

                    FadeAnimation(
                      delay: 1.6,
                      child: controller.user.isDriver ? startWorkSwitchCard(controller) : SizedBox.shrink(),
                    ),

                    controller.user.isOnRide == true && controller.user.onOrderID != null ? FadeAnimation(
                      delay: 1.8,
                      child: InkWell(
                        onTap: () {
                          Get.to(OnOrderMap(orderID: controller.user.onOrderID));
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: Get.height * 0.07, top: Get.height * 0.02),
                          width: Get.width,
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          child: ListTile(
                            leading: Icon(Icons.info),
                            title: Text('${"resumeOrder".tr}'),
                          ),
                        ),
                      ),
                    ) : SizedBox.shrink(),
                    SizedBox(height: 35.0),

                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.find<AuthController>().signOut();
          },
          backgroundColor: Color(0xFF34B55E),
          child: Icon(Icons.logout)
        ),
      ),
    );

  }

  Widget startWorkSwitchCard(UserController controller) {
    return Obx(
        () {
          if(controller.user.isOnRide == true && controller.user.onOrderID != null) {
            return SizedBox.shrink();
          } else {
            Widget text = Container(key: ValueKey<int>(controller.user.isOnline ? 0 : 1),child: Text(controller.user.isOnline ? "stopWork".tr : "startWork".tr, style: TextStyle(color: Color(0xFF404b69), fontWeight: FontWeight.bold, fontSize: 30.0)));
            return GestureDetector(
              onTap: () async{
                bool val = !controller.user.isOnline;
                if(val == true && await Helpers.checkLocationPermission()) {
                  controller.setDriverOnline(val);
                } else {
                  controller.setDriverOnline(false);
                }
              },
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AnimatedSwitcher(
                        duration: Duration(milliseconds: 350),
                        child: controller.user.isOnline ? text : text,
                        switchInCurve: Curves.bounceIn,
                        switchOutCurve: Curves.bounceOut,
                    ),
                    SizedBox(width: 15),
                    Container(
                        width: 150,
                        height: 120,
                        child: FlareActor("assets/flr/SmileySwitch.flr", animation: controller.user.isOnline ? "On" : "Off", fit: BoxFit.contain))
           /*       Switch(
                      activeColor: Get.theme.primaryColor,
                      value: controller.user.isOnline,
                      onChanged: (val) async {

                      },
                    )*/
                  ],
                ),
              ),
            );
          }
        }
    );


  }

  void startWorking() async {
      Get.to(DriverLookingForOrderScreen());
  }

  Widget onRideCardForUser(UserController controller) {
    return Obx(
        () {
          if(controller.user.isOnRide == true && controller.user.onOrderID != null) {
            return InkWell(
              onTap: () {
                Get.to(OnOrderMap(orderID: controller.user.onOrderID));
              },
              child: Container(
                margin: EdgeInsets.only(bottom: Get.height * 0.07, top: Get.height * 0.07),
                width: Get.width,
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15.0)
                ),
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('${"resumeOrder".tr}'),
                ),
              ),
            );
          } else {
            return Text('howCanHelp'.tr, style: TextStyle(color: Color(0xFF404b69), fontWeight: FontWeight.bold, fontSize: 45.0));
          }
        }
    );


  }
}


