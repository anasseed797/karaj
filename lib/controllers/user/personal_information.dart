import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/screens/home_screen.dart';
import 'package:karaj/services/PushNotificationService.dart';
import 'package:karaj/services/database.dart';

class PersonalInformationController extends GetxController {
  GlobalKey<FormState> formKey;
  TextEditingController firstNameController,lastNameController,fullAddressController;
  String firstName, lastName, fullAddress;
  Rx<int> _accountType = 0.obs;
  set switchAccountType(value) => _accountType.value = value;
  int get accountType => _accountType.value;
  Rx<bool> onInsertToDb = false.obs;

  Rx<double> indexFadeAnimation = 1.0.obs;


  RxMap<String, dynamic> personalData = RxMap<String, dynamic>();

  PersonalInformationController() {
    indexFadeAnimation.value = 1;
  }

  updatePersonalData(String key, dynamic value) {
    personalData[key] = value;
    update();
  }

  var userCities = <String>[].obs;
  var shopBrands = <String>[].obs;
  var vehiclesSupport = <String>[].obs;


  updateUserCities(String city) {
    if(!userCities.contains(city)) {
      userCities.add(city);
    } else {
      userCities.remove(city);
    }
    update(["citiesBuilder"]);
  }

  updateVehiclesSupport(String car) {
    if(!vehiclesSupport.contains(car)) {
      vehiclesSupport.add(car);
    } else {
      vehiclesSupport.remove(car);
    }
    update(["vehiclesBuilder"]);
  }

  updateShopBrands(String city) {
    if(!shopBrands.contains(city)) {
      shopBrands.add(city);
    } else {
      shopBrands.remove(city);
    }
    update(["brandSelector"]);
  }


  final Map<int, Widget> accountTypeWidget = <int, Widget> {
    0: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('مستخدم')),
    9: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('مزود خدمة')),
  };

  final Map<int, Widget> moreAccountTypeWidget = <int, Widget> {
    1: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('سائق')),
    2: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('متجر')),
    3: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('البحث والانقاذ')),
  };

  @override
  void onInit() {
    super.onInit();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    fullAddressController = TextEditingController();
    formKey = GlobalKey<FormState>();
    indexFadeAnimation.value = 1;
  }

  @override
  void onClose() {
    super.onClose();
    firstNameController.dispose();
    lastNameController.dispose();
    fullAddressController.dispose();
  }


  String validateName(String value) {
    if(value == null || value.isEmpty) {
      return "EnterACorrectName".tr;
    } else if (value.trim().length <= 1) {
      return "EnterACorrectName".tr;
    }
    return null;
  }

  String validateMapData(String value) {
    if(value == null || value.isEmpty) {
      return "EnterACorrectName".tr;
    } else if (value.trim().length < 1) {
      return "EnterACorrectName".tr;
    }
    return null;
  }

  Future<void> saveData() async {
    if(onInsertToDb.value == true) {
      Get.snackbar('يرجى الانتظار', 'جاري مراجعة و حفظ المعلومات...');
      return;
    }
    final isValid = formKey.currentState?.validate();
    if(!isValid) {
      return;
    }
    if(personalData['agreeing'] != true) {
      return Get.snackbar('سياسة الاستخدام!', 'نعتذر لكن لايمكنك المتابعة لطالما لم تواقق على شروط واخكام.');
    }
    personalData['brands'] = shopBrands;
    personalData['cities'] = userCities;
    personalData['vehicles'] = vehiclesSupport;
    formKey.currentState?.save();
    personalData['phone'] = FirebaseAuth.instance.currentUser.phoneNumber;
    int active = 1;
    if(accountType == 1 || accountType == 2) {
      active = 0;
    }
    UserModel _user = UserModel(
      id: FirebaseAuth.instance.currentUser.uid,
      firstName: firstName,
      lastName: lastName,
      fullAddress: fullAddress,
      phone: FirebaseAuth.instance.currentUser.phoneNumber,
      isDriver: accountType == 1,
      isShop: accountType == 2,
      active: active,
      personalData: personalData,
      token: Get.find<UserController>().user?.token
    );

    onInsertToDb.value = true;

     try {
       Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
       bool created = await Database().createUser(_user);
       PushNotificationService().getToken();
       Get.back();
      if(created) {
        FirebaseAuth.instance.currentUser.updateProfile(displayName: "${_user.firstName} ${_user.lastName}");
        onInsertToDb.value = false;
        Get.find<UserController>().setUser = _user;
        UserController().streamingUserData();
        Get.offAll(HomeScreen());
      }
    }catch(e) {
      Get.snackbar('حدث خطاء اتناء انشاء الملف', e);
    }
  }


}