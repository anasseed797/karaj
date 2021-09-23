import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/authController.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/screens/spares/list_spares_orders.dart';
import 'package:karaj/services/database.dart';

class ShopOrdersScreen extends StatefulWidget {
  @override
  _ShopOrdersScreenState createState() => _ShopOrdersScreenState();
}

class _ShopOrdersScreenState extends State<ShopOrdersScreen> {

  AuthController authCtrl = Get.find();

  int selectedPage = 0;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'sparesOrders'.tr),
      body: SingleChildScrollView(
        child: Container(
            child: StreamBuilder<List<SparesModel>>(
              stream: Database().getSparesOrdersStream(userId: authCtrl.user.uid, whereF: 'shopId'),
              builder: (BuildContext context, AsyncSnapshot<List<SparesModel>> snapshot) {
                if(snapshot.hasData) {
                  List<SparesModel> _sparesOrders = snapshot.data;
                  _sparesOrders.sort((a, b) => a.id.compareTo(b.id));
                  return ListSparesOrdersWidget(orders: _sparesOrders);
                }
                return Container();
              },
            )),
      ),
    );
  }
}

