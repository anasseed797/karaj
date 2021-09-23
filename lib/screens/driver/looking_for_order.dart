import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/screens/orders/list_order_widget.dart';
import 'package:karaj/services/database.dart';


class StartWorkingSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Container(
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 35.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
                text: ' بالنقر فوق متابعة وإكمال عملية البحث عن عميل لنقل اغراضه، فإنك توافق على ',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                      text: 'الشروط والأحكام ', style: TextStyle(color: Colors.blueAccent),
                      recognizer: TapGestureRecognizer()..onTap = () {
                      }
                  ),
                  TextSpan(text: 'المنصوص عليها في هذا التطبيق.')
                ]
            ),
          ),
          SizedBox(height: 35.0),
          flatButtonWidget(
            text: 'متابعة',
            context: context,
            callFunction: () => Get.back(result: 'agree'),
          ),
          SizedBox(height: 11.0),

          TextButton(
            onPressed: () => Get.back(result: 'not'),
            child: Text('الغاء'),
          )


        ],
      ),
    ));
  }
}



class DriverLookingForOrderScreen extends StatefulWidget {
  @override
  _DriverLookingForOrderScreenState createState() => _DriverLookingForOrderScreenState();
}

class _DriverLookingForOrderScreenState extends State<DriverLookingForOrderScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'الطلبات المتوفرة'),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: Database().getWaitingOrders(),
          builder: (BuildContext context, AsyncSnapshot<List<OrderModel>> snapshot) {
            print(snapshot);
            print("snapshot.connectionState : ${snapshot.connectionState}");
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Container(height: Get.height * 0.9, child: LoadingScreen(true));
            } else {
              if(snapshot.hasData && snapshot.data.length > 0) {
                return ListOrderWidget(orders: snapshot.data);
              } else {
                return EmptyScreen();
              }
            }
          },
        ),
      ),
    );
  }
}
