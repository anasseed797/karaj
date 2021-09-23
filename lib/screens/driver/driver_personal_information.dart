import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karaj/bindings/input_masked.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/user/personal_information.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/services/categories_data.dart';

class DriverPersonalInformation extends GetWidget<PersonalInformationController> {


  Future<void> getAvatarImage(ImageSource imageSource, String key) async {
    final pickedAvatar = await ImagePicker().getImage(source: imageSource);

    if(pickedAvatar != null) {
      controller.updatePersonalData(key, pickedAvatar.path);
    }
    Get.back();
  }


  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _textInputInformation(mapKey: "numberID", context: context),
          _textInputInformation(mapKey: "nationality", context: context),
          _textInputInformation(mapKey: "nationalityExpiryDate", context: context),
          _textInputInformation(mapKey: "birthdayDate", context: context),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("workArea".tr),
            ),
          ),
          Container(height: 50, width: Get.width,child: _buildCitiesMultiSelected(context)),


          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("vehicleSupport".tr),
            ),
          ),
          Container(height: 50, width: Get.width,child: _buildVehicleSelected(context)),


          _buildAvatarPickupButton(text: "uploadAvatar".tr, key: 'imageAvatarPath'),




          Text("additionalInfo".tr, style: Get.textTheme.headline5),


          CheckboxListTile(
            title: Text("hasLicense".tr),
            checkColor: Get.theme.backgroundColor,
            activeColor: Get.theme.primaryColor,
            controlAffinity: ListTileControlAffinity.leading,
            value: controller.personalData['hasLicense'] ?? false,
            onChanged: (v) {
              controller.updatePersonalData('hasLicense', v);
            },
          ),

          controller.personalData['hasLicense'] != null && controller.personalData['hasLicense'] == true ? _textInputInformation(mapKey: "licenseExpiryDate", context: context) : SizedBox.shrink(),


          Text("vehicleInfo".tr, style: Get.textTheme.headline5),
          Container(
            width: Get.width,
            height: 70,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _textInputInformation(mapKey: "plateLetters", context: context)),
                Expanded(child: _textInputInformation(mapKey: "plateNumbersX", context: context)),
              ],
            ),
          ),

          CheckboxListTile(
            title: Text("hasInsurance".tr),
            checkColor: Get.theme.backgroundColor,
            activeColor: Get.theme.primaryColor,
            controlAffinity: ListTileControlAffinity.leading,
            value: controller.personalData['hasInsurance'] ?? false,
            onChanged: (v) {
              controller.updatePersonalData('hasInsurance', v);
            },
          ),

          _buildAvatarPickupButton(text: "imageSideViewCar".tr, key: 'imageSideViewCar'),

          _buildAvatarPickupButton(text: "imageCarFront".tr, key: 'imageCarFront'),


        ],
      ),
    );
  }

  Widget _textInputInformation({String mapKey, BuildContext context, double width, double mLeft = 0.0}) {
    return Container(
      width: width,
      margin: EdgeInsets.only(bottom: 15.0, left: mLeft),
      child: TextFormField(
        initialValue: controller.personalData[mapKey] ?? '',
        onSaved: (value) {
          controller.personalData[mapKey] = value;
          if(mapKey == "plateNumbersX") {
            String plt = "${controller.personalData["plateLetters"]} - ${controller.personalData["plateNumbersX"]}";
            controller.personalData["plateNumbers"] = Helpers.englishToArabic(plt);
            controller.personalData["plateNumber"] = Helpers.englishToArabic(plt);
          }
        },
        validator: (value) {
          return controller.validateMapData(value);
        },
          inputFormatters: [
            mapKey.contains('Date') ? MaskedTextInputFormatter(
              mask: 'xx/xx/xxxx',
              separator: '/',
            ) : MaskedTextInputFormatter(
              mask: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
              separator: '/',
            ),
          ],
        decoration: inputDecorationUi(context, mapKey.tr, color: Get.theme.scaffoldBackgroundColor),
        keyboardType: mapKey.contains('Date') ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildVehicleSelected(BuildContext context) {
    List<String> vehicles = ["van".tr,"pickup".tr];
    return GetBuilder<PersonalInformationController>(
        id: "vehiclesBuilder",
        builder: (ctrl) {
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vehicles.length,
              itemBuilder: (BuildContext context, index) {
                String car = vehicles[index];
                bool selected = false;
                if(ctrl.vehiclesSupport.contains(car)) {
                  selected = true;
                }
                return InkWell(
                  onTap: () {
                    ctrl.updateVehiclesSupport(car);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0),
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                        color: selected ? Get.theme.primaryColor : Get.theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Center(child: Text(car, style: TextStyle(color: !selected ? Colors.black : Colors.white))),
                  ),
                );
              }
          );
        }
    );
  }

  Widget _buildCitiesMultiSelected(BuildContext context) {

    return GetBuilder<PersonalInformationController>(
        id: "citiesBuilder",
        builder: (ctrl) {
        return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: Categories.cities.length,
            itemBuilder: (BuildContext context, index) {
              String city = Categories.cities[index];
              bool selected = false;
              if(ctrl.userCities.contains(city)) {
                selected = true;
              }
              return InkWell(
                onTap: () {
                  ctrl.updateUserCities(city);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0),
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                      color: selected ? Get.theme.primaryColor : Get.theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(child: Text(city, style: TextStyle(color: !selected ? Colors.black : Colors.white))),
                ),
              );
            }
        );
      }
    );
  }

  Widget _buildAvatarPickupButton({String text, String key}) {
    return GetBuilder<PersonalInformationController>(
      builder: (ctrl) => InkWell(
        onTap: () {
          return Get.bottomSheet(
            Container(
              padding: EdgeInsets.all(15.0),
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.photo),
                    title: Text("openGallery".tr),
                    onTap: () async {
                      return getAvatarImage(ImageSource.gallery, key);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.camera),
                    title: Text("openCamera".tr),
                    onTap: () async {
                      return getAvatarImage(ImageSource.camera, key);
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: Center(
                      child: flatButtonWidget(
                        context: Get.context,
                        text: 'btnCancel'.tr,
                        callFunction: () => Get.back(),
                      ),
                    ),
                  )
                ],
              ),
            ),
            backgroundColor: Get.theme.backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), topLeft: Radius.circular(15.0))
            ),
          );
        },
        child: Container(
            margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 35.0),
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(5)
            ),
            child: Column(
              children: [
                Center(child: Text(text ?? '')),
                controller.personalData[key ?? ''] != null ? Container(
                  child: Image.file(File(controller.personalData[key ?? ''])),
                ) : SizedBox.shrink()
              ],
            )),
      ),
    );
  }
}
