import 'package:get/get.dart';
import 'package:karaj/controllers/authController.dart';
import 'package:karaj/controllers/userController.dart';

class BindingControllers extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<UserController>(() => UserController());

  }

}