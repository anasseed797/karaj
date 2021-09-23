import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/utilsController.dart';
import 'package:karaj/screens/shop/shop_orders.dart';
import 'package:karaj/screens/user/tabs/my_profile_screen.dart';
import 'package:karaj/screens/user/tabs/my_wallet_screen.dart';
import 'package:karaj/screens/user/user_my_orders.dart';

class MainTabsContent extends StatelessWidget {
  final bool isShop;
  final int selectedIndex;

  final UtilsController utilsCtrl = Get.put(UtilsController());

  final List<Widget> screens = [
    UserMyOrders(),
    MyWalletScreen(),
    MyProfileScreen(),

  ];

  MainTabsContent({Key key, this.isShop = false, this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(isShop) {
      screens[0] = ShopOrdersScreen();
    }
    if(selectedIndex != null) {
      utilsCtrl.setTabIndex = selectedIndex;
    }
    return Obx(
            () =>  Scaffold(
              extendBody: true,
              body: screens.elementAt(utilsCtrl.tabSelectedIndex),
              bottomNavigationBar: BottomWidget(),
            ),
    );
  }
}



class BottomWidget extends StatelessWidget {
  final UtilsController utilsCtrl = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
          () => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: utilsCtrl.tabSelectedIndex,
        onTap: (index) {
          utilsCtrl.setTabIndex = index;
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu_outlined), label: 'طلباتي',),
          BottomNavigationBarItem(icon: Icon(Icons.restore), label: 'سجلي'),
          BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: 'حسابي'),
        ],
      ),
    );
  }
}