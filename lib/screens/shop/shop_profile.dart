import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/screens/spares/select_items.dart';
import 'package:karaj/services/categories_data.dart';

class ShopProfileScreen extends StatelessWidget {
  final UserModel shop;

  const ShopProfileScreen({Key key, this.shop}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    List brands = [];
    brands = shop?.personalData["brands"] ?? [];
    String name = shop?.personalData["commercialName"] ?? (shop.firstName + " "+ shop?.lastName);
    if(Get.locale.languageCode == "en") {
      name = shop?.personalData["companyNameEn"] ?? name;
    }
    return Scaffold(
      appBar: appBar(title: shop.personalData["commercialName"] ?? ""),
      body: SingleChildScrollView(
        child: Container(
          width: Get.width,
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 27.0),
                child: circleAvatarNetwork(
                  src: shop.avatar ?? shop.personalData["ShopPlate"],
                  radius: 97,
                  color: Colors.grey[200],
                ),
              ),

              Text(name ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27.0)),
              Container(
                margin: EdgeInsets.only(bottom: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StarDisplay(value: shop.stars ?? 0),
                    SizedBox(width: 15.0),
                    Text('(${shop.voters} ${"reviews".tr})')
                  ],
                ),
              ),
              InkWell(
                  onTap: () {
                    Helpers.launchMap(lat: shop.personalData["addressData"]["lat"], lng: shop.personalData["addressData"]["lng"]);
                  },
                  child: Text(shop.fullAddress ?? shop.personalData["addressData"]["address"] ?? "", textAlign: TextAlign.center)),
              SizedBox(height: 15.0),
              Wrap(
                spacing: 3.0,
                runSpacing: 15.0,
                children: brands.map((element) {
                  return ActionChip(
                      avatar: Image(
                        image: NetworkImage(Brands.logos[element.toString()] ?? ""),
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(element.toString() ?? ""),
                      ),
                      onPressed: () => {},
                  );
                }).toList().cast<Widget>(),
              ),
              SizedBox(height: 31.0),
              Center(
                child: flatButtonWidget(
                    context: context,
                    text: 'requestSpares'.tr,
                    callFunction: () => Get.to(SelectItemsScreen(shop: shop)),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
