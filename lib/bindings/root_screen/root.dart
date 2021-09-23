import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/root_screen/unactive_account.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/authController.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/screens/guest_home_screen.dart';
import 'package:karaj/screens/home_screen.dart';
import 'package:karaj/screens/user/sign_select_type_information_form.dart';

class Root extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
        () {
          Widget re = LoadingScreen(true);
          UserModel _u = Get.find<UserController>().user;
          if(controller.user == null) {
            re = GuestHomeScreen();
          } else if(controller.splashScreenLoaded.value == true) {
            if (controller.user.displayName == null || controller.user.displayName == '' || _u.firstName == null || _u.firstName == '') {
              re = SignSelectTypeInformationForm();
            } else if(_u.active == 0) {
              re = WaitingForReviewScreen();
            } else {
              if(_u != null && _u.isDriver && _u.isOnRide && _u.onOrderID != null) {
                re = HomeScreen();
              } else {
                re = HomeScreen();
              }
            }
          }

          return re;
        }
    );
  }
}


