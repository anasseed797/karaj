import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/root_screen/root.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/screens/auth/verified_code.dart';
import 'package:karaj/screens/guest_home_screen.dart';
import 'package:karaj/services/database.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rxn<User> _firebaseUser = Rxn<User>();

  User get user => _firebaseUser.value;

  String _verificationId;

  RxBool splashScreenLoaded = false.obs;


  RxBool onLoading = false.obs;
  RxBool logged = false.obs;

  @override
  void onInit() {
    print("================================== Start binding AuthController");
    _firebaseUser.bindStream(_auth.authStateChanges());
    getUserData();
    super.onInit();
  }

  void login(String numberPhone) async {
    try{
      logged.value = false;
      Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
      final PhoneVerificationCompleted verificationCompleted = (AuthCredential credential) async {
        FirebaseAuth.instance.signInWithCredential(credential);
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
        } catch (e) {
          Get.snackbar('errorAtSending'.tr, e.message, snackPosition: SnackPosition.TOP);
        }
      };

      final PhoneVerificationFailed verificationFailed = (FirebaseAuthException athExp) {
        print('verificationFailed and error code is ${athExp.code} with a message says : ${athExp.message}');
      };

      final PhoneCodeSent codeSent = (String verficationId, [int forceResendingToken]) async {
        _verificationId = verficationId;
        print("code send");
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verficationId) {
        _verificationId = verficationId;
        print("TimeOut of sending sms code");
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: numberPhone,
          timeout: const Duration(milliseconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout
      );

      Get.back();
      Get.to(VerifiedCode(numberPhone));
    }catch(e) {
      Get.snackbar("errorCatch".tr, e.message, snackPosition: SnackPosition.TOP);
    }
  }

  Future<bool> verifiedCodeFunction(String code) async {
    try{
      final AuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: code);
      await FirebaseAuth.instance.signInWithCredential(credential);
      UserController().streamingUserData();
      await getUserData();
      onLoading.value = false;
      logged.value = true;
      Future.delayed(Duration(milliseconds: 3000), () {
        Get.offAll(Root());
      });
      return true;
    }catch(e) {
      Get.snackbar("errorCatch".tr, e.message, snackPosition: SnackPosition.TOP, duration: Duration(seconds: 7));
      return false;
    }
  }

  void signOut() async {
    try{
      Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
      await _auth.signOut();
      Get.find<UserController>().clear();
      Get.back();
      Get.offAll(GuestHomeScreen());
    }catch(e) {
      Get.snackbar("errorCatch".tr, e.message, snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> getUserData() async {
    if(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser?.uid != null) {
      print("================================== Start getting user Data from AuthController");
      UserModel _user = await Database().getUser(FirebaseAuth.instance.currentUser.uid);
      splashScreenLoaded.value = true;
      if(_user.id != null && _user.id == FirebaseAuth.instance.currentUser?.uid) {
        Get.find<UserController>().setUser = _user;
        Get.find<UserController>().streamingUserData();
      }
    } else {
      splashScreenLoaded.value = true;
    }
  }

}