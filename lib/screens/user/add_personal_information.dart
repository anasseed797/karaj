import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/user/personal_information.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/screens/driver/driver_personal_information.dart';
import 'package:karaj/screens/map/select_location.dart';
import 'package:karaj/screens/map/select_location_new.dart';
import 'package:karaj/screens/shop/shop_personal_information.dart';
import 'package:karaj/ui_widgets/animations/fade_animation.dart';



class AddPersonalInformation extends StatelessWidget {

  final String typeSignIn;



  final PersonalInformationController controller = Get.put(PersonalInformationController());

  AddPersonalInformation({Key key, this.typeSignIn}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    if(typeSignIn == 'normalUser') {
      controller.switchAccountType = 0;
    } else {
      controller.switchAccountType = 1;
    }

    return Scaffold(
      appBar: appBar(title: "personalInformation".tr),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FadeAnimation(
                  delay: 1,
                    child: LogoUi(),
                ),
                SizedBox(height: 35.0),
                FadeAnimation(
                  delay: 1.1,
                  child: ContainerCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("personalInformation".tr, style: Get.textTheme.headline5),
                        TextFormField(
                          controller: controller.firstNameController,
                          onSaved: (value) {
                            controller.firstName = value;
                            controller.updatePersonalData('firstName', value);


                          },
                          validator: (value) {
                            return controller.validateName(value);
                          },
                          decoration: inputDecorationUi(context, 'firstName'.tr, color: Get.theme.scaffoldBackgroundColor),
                          keyboardType: TextInputType.text,
                        ),

                        typeSignIn != 'normalUser' ? Obx(
                              () => typeSignIn != 'normalUser' && controller.accountType == 1 ? Container(
                            margin: EdgeInsets.symmetric(vertical: 15.0),
                            child: TextFormField(
                              initialValue: controller.personalData["fatherName"] ?? '',
                              onSaved: (value) {
                                controller.personalData["fatherName"] = value;
                              },
                              validator: (value) {
                                return controller.validateMapData(value);
                              },
                              decoration: inputDecorationUi(context, "fatherName".tr, color: Get.theme.scaffoldBackgroundColor),
                              keyboardType: TextInputType.text,
                            ),
                          ) : SizedBox.shrink(),
                        ) : SizedBox.shrink(),
                        SizedBox(height: 15.0),

                        TextFormField(
                          controller: controller.lastNameController,
                          onSaved: (value) {
                            controller.lastName = value;
                          },
                          validator: (value) {
                            return controller.validateName(value);
                          },
                          decoration: inputDecorationUi(context, 'lastName'.tr, color: Get.theme.scaffoldBackgroundColor),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 15.0),

                        typeSignIn != 'normalUser' ? Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('accountType'.tr),
                          ),
                        ) : SizedBox.shrink(),

                        SizedBox(height: 5.0),
                        Obx(
                              () => Column(
                                children: [

                                  typeSignIn == 'displayAccountType' ? Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 15.0),
                                    child: CupertinoSegmentedControl(
                                        children: controller.accountTypeWidget,
                                        borderColor: Theme.of(context).primaryColor,
                                        pressedColor: Theme.of(context).primaryColor,
                                        selectedColor: Theme.of(context).primaryColor,

                                        onValueChanged: (int val) {
                                          if(val == 9) {
                                            controller.switchAccountType = 1;
                                          } else {
                                            controller.switchAccountType = val;
                                          }
                                        },
                                        groupValue: controller.accountType > 0 ? 9 : 0,
                                      ),
                                    ) : SizedBox.shrink(),
                                    controller.accountType > 0 ? Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(bottom: 15.0),
                                      child: CupertinoSegmentedControl(
                                        children: controller.moreAccountTypeWidget,
                                        borderColor: Theme.of(context).primaryColor,
                                        pressedColor: Theme.of(context).primaryColor,
                                        selectedColor: Theme.of(context).primaryColor,

                                        onValueChanged: (int val) {
                                          controller.switchAccountType = val;
                                        },
                                        groupValue: controller.accountType == 9 ? 1 : controller.accountType,
                                      ),
                                    ) : SizedBox.shrink(),

                                  SizedBox(height: 15.0),

                                  TextFormField(
                                    onTap: () async {
                                      if(controller.accountType == 2) {
                                        Map<String, dynamic> result = await Get.to(SelectLocation());

                                        if(result != null ) {
                                          controller.fullAddressController.text = result['address'];
                                          controller.personalData['addressData'] = result;
                                        }
                                      }
                                    },
                                    controller: controller.fullAddressController,
                                    onSaved: (value) {
                                      controller.fullAddress = value;
                                    },
                                    validator: (value) {
                                      return controller.validateName(value);
                                    },
                                    decoration: inputDecorationUi(context, 'fullAddress'.tr, color: Get.theme.scaffoldBackgroundColor),
                                    keyboardType: TextInputType.text,
                                    maxLines: 3,

                                  ),
                                  SizedBox(height: 15.0),

                                  controller.accountType == 1 ? DriverPersonalInformation() : Container(),
                                  controller.accountType == 2 ? ShopPersonalInformation() : Container(),
                                  SizedBox(height: 35.0),
                                  CheckboxListTile(
                                    title:  RichText(
                                      text: TextSpan(
                                          text: 'agreeOn'.tr,
                                          style: TextStyle(fontFamily: 'Cairo', color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'rules'.tr, style: TextStyle(color: Colors.blueAccent),
                                                recognizer: TapGestureRecognizer()..onTap = () {
                                                  GetxWidgetHelpers.mSnackBar('noRulesTitle'.tr, 'noRulesText'.tr);
                                                }
                                            ),
                                            TextSpan(text: 'textR'.tr)
                                          ]
                                      ),
                                    ),
                                    checkColor: Get.theme.backgroundColor,
                                    activeColor: Get.theme.primaryColor,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    value: controller.personalData['agreeing'] ?? false,
                                    onChanged: (v) {
                                      controller.updatePersonalData('agreeing', v);
                                    },
                                  ),
                                ],
                              ),
                        ),

                        SizedBox(height: 15.0),
                        Container(
                          width: Get.width,
                          child: normalFlatButtonWidget(
                            context: context,
                            text: 'btnSaveInfo'.tr,
                            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                            radius: 5.0,
                            callFunction: () {
                              controller.saveData();
                            },
                          ),
                        ),
                      ],
                    ),
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
