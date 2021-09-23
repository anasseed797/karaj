import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/sparesOrderingController.dart';
import 'package:karaj/models/user.dart';
import 'package:karaj/screens/shop/shop_profile.dart';
import 'package:karaj/services/database.dart';

class ShopsListScreen extends GetWidget<SparesOrderingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: '${controller.order.brand} ${controller.order.category} ${controller.order.model}'),
      body: SingleChildScrollView(
        child: Container(
          height: Get.height,
          child: StreamBuilder(
            stream: Database().getShops(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasData) {
                List<UserModel> users = snapshot.data ?? [];
                bool isEnglish = Get.locale.languageCode == "en";
                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, index) {
                      UserModel _user = users[index];
                      String name = _user.personalData["companyName"] ?? (_user.firstName + " "+ _user.lastName);
                      if(isEnglish) {
                        name = _user.personalData["companyNameEn"] ?? name;
                      }
                      if(_user.personalData != null && _user.personalData["brands"] != null && _user.personalData["brands"].contains(controller.order.brand)) {
                        return InkWell(
                          onTap: () => Get.to(ShopProfileScreen(shop: _user)),
                          child: Container(
                            margin: EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(8.0),
                            color: Get.theme.backgroundColor,
                            child: ListTile(
                              leading: circleAvatarNetwork(
                                src: _user.avatar ?? _user.personalData["ShopPlate"],
                                radius: 30,
                                color: Colors.grey[200],
                              ),
                              title: Text(name ?? ""),
                              subtitle: Row(
                                children: [
                                  StarDisplay(value: _user.stars ?? 0),
                                  SizedBox(width: 15.0),
                                  Text('(${_user.voters} ${"reviews".tr})')
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();

                    }
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
