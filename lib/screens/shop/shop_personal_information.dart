import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/user/personal_information.dart';
import 'package:karaj/services/categories_data.dart';

class ShopPersonalInformation extends GetWidget<PersonalInformationController> {


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
          _textInputInformation(mapKey: "companyName", context: context),
          _textInputInformation(mapKey: "companyNameEn", context: context),
          _textInputInformation(mapKey: "commercialNumber", context: context),
          _textInputInformation(mapKey: "commercialName", context: context),
          _textInputInformation(mapKey: "region", context: context),
          _textInputInformation(mapKey: "city", context: context),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('brands'.tr),
            ),
          ),
          Container(height: 50, width: Get.width,child: _buildBrandsSelector(context)),
          SizedBox(height: 15.0),

          _textInputInformation(mapKey: "numberBranches", context: context, noValid: true),

          _textInputInformation(mapKey: "directPhoneNumber", context: context),
          _textInputInformation(mapKey: "websiteOrSocialLink", context: context),



          _buildAvatarPickupButton(text: "imageShopPlate".tr, key: 'imageShopPlate'),




          CheckboxListTile(
            title: Text("agreeKeeping".tr),
            checkColor: Get.theme.backgroundColor,
            activeColor: Get.theme.primaryColor,
            controlAffinity: ListTileControlAffinity.leading,
            value: controller.personalData['agreeKeeping'] ?? false,
            onChanged: (v) {
              controller.updatePersonalData('agreeKeeping', v);
            },
          ),




        ],
      ),
    );
  }

  Widget _textInputInformation({String mapKey, BuildContext context, bool noValid = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        initialValue: controller.personalData[mapKey] ?? '',
        onSaved: (value) {
          controller.personalData[mapKey] = value;
        },
        validator: (value) {
          if(noValid) {
            return null;
          }
          return controller.validateMapData(value);
        },
        decoration: inputDecorationUi(context, mapKey.tr, color: Get.theme.scaffoldBackgroundColor),
        keyboardType: mapKey.contains('Date') || mapKey.contains('Phone') ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildBrandsSelector(BuildContext context) {

    return GetBuilder<PersonalInformationController>(
        id: "brandSelector",
        builder: (ctrl) {
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Brands.brands.length,
              itemBuilder: (BuildContext context, index) {
                String brand = Brands.brands.keys.elementAt(index);
                bool selected = false;
                if(ctrl.shopBrands.contains(brand)) {
                  selected = true;
                }
                return InkWell(
                  onTap: () {
                    ctrl.updateShopBrands(brand);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0),
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                        color: selected ? Get.theme.primaryColor : Get.theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Center(child: Text(brand ?? '', style: TextStyle(color: !selected ? Colors.black : Colors.white))),
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
                        text: 'الغاء',
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
