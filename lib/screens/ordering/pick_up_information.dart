import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/orderingController.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/screens/ordering/confirm_order.dart';
import 'package:karaj/services/categories_data.dart';

class PickUpDetails extends StatefulWidget {
  @override
  _PickUpDetailsState createState() => _PickUpDetailsState();
}

class _PickUpDetailsState extends State<PickUpDetails> {

  int numberOfPieces = 1, numberOfWorkers = 1, fromFloor = 0, toFloor = 0;
  String fromFloorString, toFloorString;

  @override
  void initState() {
    fromFloorString = Floors.floorsList[fromFloor] ?? '';
    toFloorString = Floors.floorsList[toFloor] ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    OrderingController _orderCtrl = Get.find();

    return Scaffold(
      appBar: appBar(title: 'detailsOfTransfer'.tr),
      backgroundColor: Get.theme.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _orderCtrl.order.orderType == 2 ? Column(
              children: [
                SizedBox(height: 25.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('numberOfPieces'.tr),
                      Text(numberOfPieces.toString())
                    ]
                ),
                Slider(
                  value: numberOfPieces.toDouble(),
                  min: 1.0,
                  max: 50.0,
                  //divisions: 19,
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey[200],
                  label: numberOfPieces.toString(),
                  onChanged: (double val) {
                    setState(() {
                      numberOfPieces = val.toInt();
                    });
                  },
                  semanticFormatterCallback: (double val) {
                    return val.toString();
                  },
                ),
             /*   SizedBox(height: 25.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('numberOfWorkers'.tr),
                      Text(numberOfWorkers.toString())
                    ]
                ),
                Slider(
                  value: numberOfWorkers.toDouble(),
                  min: 1.0,
                  max: 19.0,
                  //divisions: 19,
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey[200],
                  label: numberOfWorkers.toString(),
                  onChanged: (double val) {
                    setState(() {
                      numberOfWorkers = val.toInt();
                    });
                  },
                  semanticFormatterCallback: (double val) {
                    return val.toString();
                  },
                ),*/
              ],
            ) : SizedBox.shrink(),
            SizedBox(height: 25.0),
            Text('fromFloor'.tr),
            SizedBox(height: 15.0),
            Container(height: 35.0, child: _buildFloorsList()),
            SizedBox(height: 25.0),
            Text('toFloor'.tr),
            SizedBox(height: 15.0),
            Container(height: 35.0, child: _buildFloorsList(isFrom: false)),
            SizedBox(height: 35.0),
            Container(
              width: Get.width,
              child: flatButtonWidget(
                context: context,
                text: 'btnContinue'.tr,
                callFunction: () => _submit(_orderCtrl),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _submit(OrderingController _oCtrl) {
    _oCtrl.setStep = 4;
    OrderModel _o = _oCtrl.order;
    _o.numberOfPieces = numberOfPieces;
    _o.numberOfWorkers = numberOfWorkers;
    _o.fromFloor = fromFloor;
    _o.toFloor = toFloor;
    _o.fromFloorString = fromFloorString;
    _o.toFloorString = toFloorString;
    _oCtrl.setOrder = _o;
    Get.to(ConfirmOrder());
  }


  Widget _buildFloorsList({bool isFrom = true}) {


    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: Floors.floorsList.length,
        itemBuilder: (BuildContext context, index) {
          bool selected = false;
          if(isFrom && fromFloor == index) {
            selected = true;
          } else if(!isFrom && toFloor == index){
            selected = true;
          }
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              color: selected ? Get.theme.colorScheme.primaryVariant : Color(0xfff4f6f8),
              borderRadius: BorderRadius.circular(5)
            ),
            child: InkWell(onTap: () { setState(() {
              if(isFrom) {
                fromFloor = index;
                fromFloorString = Floors.floorsList[index] ?? '';
              } else {
                toFloor = index;
                toFloorString = Floors.floorsList[index] ?? '';

              }
            }); }, child: Center(child: Text(Floors.floorsList[index] ?? '', style: TextStyle(color: selected ? Get.theme.colorScheme.secondaryVariant : Color(0xff949ec7))))),
          );
        });
  }

}
