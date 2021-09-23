import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/screens/home_screen.dart';
import 'package:karaj/screens/orders/cancel_order.dart';
import 'package:karaj/screens/orders/on_order_map.dart';
import 'package:karaj/screens/orders/order_map_screen.dart';
import 'package:karaj/screens/rating/rating_screen.dart';
import 'package:karaj/services/database.dart';
import 'package:karaj/ui_widgets/order_card_direction.dart';

class OrderDetails extends StatefulWidget {
  final OrderModel order;
  final bool navToHome;
  final String orderIDX;
  OrderDetails({Key key, this.order, this.navToHome = false, this.orderIDX}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {

  int status = 0;
  int selectedReasonIndex;
  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find<UserController>();
    bool isDriver = controller.user?.id != null && controller.user.isDriver;
    String orderID = widget.orderIDX;
    if(widget.orderIDX == null && widget.order != null) {
      orderID = widget.order.id;
      orderID = widget.order.id;
    }
    print("============= $orderID");
    return Scaffold(
      backgroundColor: Get.theme.backgroundColor,
      appBar: appBar(title: "orderDetails".tr),
      body: orderID == null ? NotFound() : StreamBuilder<Object>(
          stream: FirebaseFirestore.instance.collection("orders").doc(orderID).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              DocumentSnapshot x = snapshot.data;
              if(x.exists) {
                OrderModel orderSnap = OrderModel.fromFirestore(snapshot.data);
                status = orderSnap.status;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: Get.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("orderId".tr),
                                    Text("${orderSnap.id}", style: TextStyle(color: Color(0xff4a90e2), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            orderStatus(status),
                          ],
                        ),
                      ),
                      status >= 1 && status < 9 ? Container(
                        margin: EdgeInsets.symmetric(vertical: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(orderSnap.totalDuration ?? '', overflow: TextOverflow.ellipsis),
                                Text('الوقت المقدر', style: TextStyle(fontSize: 13.0, color: Colors.grey))
                              ],
                            ),
                            Column(
                              children: [
                                Text("${orderSnap.distance.toString()} ${"km".tr}" ?? '', overflow: TextOverflow.ellipsis),
                                Text('distance'.tr, style: TextStyle(fontSize: 13.0, color: Colors.grey))
                              ],
                            ),
                            Column(
                              children: [
                                Text(orderSnap.payCash == true ? 'الدفع كاش' : orderSnap.payed == 1 ? 'تم الدفع' : 'في انتظار', overflow: TextOverflow.ellipsis),
                                Text('المبلغ'.tr, style: TextStyle(fontSize: 13.0, color: Colors.grey))
                              ],
                            ),
                          ],
                        ),
                      ) : SizedBox.shrink(),
                      (status >= 3 && status < 9) && !isDriver && orderSnap.driverId != null? Column(
                        children: [

                          InkWell(
                            onTap: () {
                              Helpers.makeCallPhone(orderSnap.driverPhone);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 15.0),
                              child: Row(
                                children: [
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100], //background color of box
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 7.0,
                                              offset: Offset(
                                                1,
                                                1,
                                              ),
                                            )
                                          ],
                                        ),
                                        child: Image(
                                          image: NetworkImage(orderSnap.driverAvatar),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(orderSnap.driverName ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0)),
                                          Row(
                                            children: [
                                              Text(orderSnap.driverPhone ?? '', style: TextStyle(color: Colors.blueAccent), textDirection: TextDirection.ltr),
                                              SizedBox(width: 5),
                                              Icon(Icons.call, size: 13.0),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Image(
                                          image: orderSnap.carFrontImage != null ? NetworkImage(orderSnap.carFrontImage):  AssetImage("assets/images/vehicle${orderSnap.orderType}.jpeg"),
                                          width: 50,
                                          height: 50,
                                        ),
                                        Text(orderSnap.plateNumber ?? '', style: TextStyle(fontSize: 11.0),),

                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      ) : SizedBox.shrink(),

                      InkWell(
                        onTap: () {
                          if(status <= 1 || status == 9) {
                            Get.to(OrderingMapScreen(order: orderSnap));
                          } else {
                            Get.to(OnOrderMap(orderID: orderSnap.id));
                          }
                        },
                        child: OrderCardDirection(orderModel: orderSnap, displayShadow: false),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 15.0),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              right: MediaQuery.of(context).size.width * 0.1,
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                width: 1,
                                color: Color(0xFFCDD0D9),
                              ),
                            ),
                            Column(
                              children: [
                                statusList(text: "orderPayed".tr, date: orderSnap.dates['orderPayed'] ?? '', selected: orderSnap.payed == 1),
                                statusList(text: "orderAccepted".tr, date: orderSnap.dates['orderAccepted'] ?? '', selected: (status >= 3 && status != 97)),
                                statusList(text: "orderDriverAtOrderLocation".tr, date: orderSnap.dates['orderDriverAtOrderLocation'] ?? '', selected: (status >= 4 && status != 97)),
                                statusList(text: "orderPicked".tr, date: orderSnap.dates['orderPicked'] ?? '', selected: (status >= 5 && status != 97)),
                                statusList(text: "orderAtDropOff".tr, date: orderSnap.dates['orderAtDropOff'] ?? '', selected: (status >= 6 && status != 97)),
                                statusList(text: "done".tr, date: orderSnap.dates['done'] ?? '', selected: (status >= 9 && status != 97)),
                                statusList(text: "rated".tr, widgetContent: StarDisplay(value: orderSnap.stars), selected: orderSnap.rated),

                              ],
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: Get.height * 0.07),
                      (status >= 3 && status < 9) && isDriver ? Column(
                        children: [
                          paymentListDetails('clientName'.tr, "${orderSnap.userName}" ?? '', uid: orderSnap.userId),
                          paymentListDetails('clientPhone'.tr, "${orderSnap.userPhone}" ?? '', keyTr: 'clientPhone', clr: Colors.blueAccent, textDirection: TextDirection.ltr),
                          Divider(),
                        ],
                      ) : SizedBox.shrink(),

                      orderSnap.isSpareOrder == true ? Column(
                        children: [
                          paymentListDetails('shopName'.tr, "${orderSnap.shopName}" ?? '', uid: orderSnap.userId),
                          paymentListDetails('numberPhone'.tr, "${orderSnap.shopPhone}" ?? '', keyTr: 'phone', clr: Colors.blueAccent, textDirection: TextDirection.ltr),
                          Divider(),
                        ],
                      ) : SizedBox.shrink(),

                      orderSnap.orderType == 2 ? Column(
                        children: [
                          paymentListDetails('numberOfPieces'.tr, "${orderSnap.numberOfPieces}" ?? ''),
                          // paymentListDetails('numberOfWorkers'.tr, "${orderSnap.numberOfWorkers}" ?? ''),
                        ],
                      ) : SizedBox.shrink(),
                      paymentListDetails('vehicleType'.tr, "${orderSnap.vehicleName}" ?? ''),
                      paymentListDetails('distance'.tr, "${orderSnap.distance.toString()} ${"km".tr}" ?? ''),


                      status > 1 ? Column(
                        children: [
                          paymentListDetails('openCounter'.tr, "${orderSnap.distanceStartPrice} ${"sar".tr}" ?? ''),
                          paymentListDetails('distancePrice'.tr, "${orderSnap.distancePrice}  ${"sar".tr}" ?? ''),
                          paymentListDetails('vehiclePrice'.tr, "${orderSnap.vehiclePrice}  ${"sar".tr}" ?? ''),
                          Divider(),
                          paymentListDetails('totalPrice'.tr, "${orderSnap.totalPrice ?? ''}SAR", size: 21.0),
                        ],
                      ) : SizedBox.shrink(),

                      orderSnap.payCash == true ? paymentListDetails('طريقة الدفع'.tr, "كاش") : SizedBox.shrink(),

                      paymentListDetails('date'.tr, orderSnap.date ?? ''),

                      SizedBox(height: Get.height * 0.03),

                      isDriver && status == 1 ? flatButtonWidget(
                          context: context,
                          text: 'btnAcceptOrder'.tr,
                          callFunction: () async {
                            if(controller.user.isOnRide) {
                              GetxWidgetHelpers.mSnackBar('ليس لك الحق!', 'ليس لك الحق في قبول اي طلب اخر حتى تنهي طلبك الحالي');
                            } else if(await Helpers.checkLocationPermission()) {
                              await Database().setDriver(order: orderSnap, status: 3, orderID: orderSnap.id, user: controller.user, clientID: orderSnap.userId);
                            }

                          }
                      ) : SizedBox.shrink(),

                      isDriver && status == 3 ? flatButtonWidget(
                          context: context,
                          text: 'orderDriverAtOrderLocation'.tr,
                          callFunction: () async {
                            await Database().setOrderStatus(status: 4, orderID: orderSnap.id, order: orderSnap);

                          }
                      ) : SizedBox.shrink(),

                      isDriver && status == 4 ? flatButtonWidget(
                          context: context,
                          text: 'orderPicked'.tr,
                          callFunction: () async {
                            await Database().setDriver(order: orderSnap, status: 5, orderID: orderSnap.id, user: controller.user, clientID: orderSnap.userId);

                          }
                      ) : SizedBox.shrink(),

                      isDriver && status == 5 ? flatButtonWidget(
                          context: context,
                          text: 'orderAtDropOff'.tr,
                          callFunction: () async {
                            await Database().setOrderStatus(status: 6, orderID: orderSnap.id, order: orderSnap);

                          }
                      ) : SizedBox.shrink(),

                      isDriver && status == 6 ? flatButtonWidget(
                          context: context,
                          text: 'done'.tr,
                          callFunction: () async {
                            await Database().setDriver(order: orderSnap, status: 9, orderID: orderSnap.id, user: controller.user, clientID: orderSnap.userId);

                          }
                      ) : SizedBox.shrink(),

                      status == 9 && orderSnap.rated != true && FirebaseAuth.instance.currentUser.uid == orderSnap.userId ? flatButtonWidget(
                          context: context,
                          text: 'ratingDRIVER'.tr,
                          callFunction: () async {
                            Get.to(RatingScreen(type: 'driver', type2: 'order', userID: orderSnap.driverId, voter: controller.user, orderID: orderSnap.id));
                          }
                      ) : SizedBox.shrink(),

                      status == 9 && orderSnap.clientRated != true && FirebaseAuth.instance.currentUser.uid == orderSnap.driverId ? flatButtonWidget(
                          context: context,
                          text: 'ratingUSER'.tr,
                          callFunction: () async {
                            if(FirebaseAuth.instance.currentUser.uid == orderSnap.driverId) {
                              Get.to(RatingScreen(type: 'user', type2: 'order', userID: orderSnap.userId, voter: controller.user, orderID: orderSnap.id));
                            }
                          }
                      ) : SizedBox.shrink(),
                      SizedBox(height: Get.height * 0.03),

                      widget.navToHome ? normalFlatButtonWidget(
                          colour: Colors.transparent,
                          textColor: Get.theme.primaryColor,
                          context: context,
                          text: 'home'.tr,
                          callFunction: () async {
                            Get.offAll(HomeScreen());
                          }
                      ) : SizedBox.shrink(),

                      controller.user?.id == orderSnap.userId && status <= 2 ? normalFlatButtonWidget(
                          colour: Colors.transparent,
                          textColor: Get.theme.errorColor,
                          context: context,
                          text: 'btnCancelOrder'.tr,
                          callFunction: () async {
                            await Database().setOrderStatus(status: 97, orderID: orderSnap.id, order: orderSnap);
                          }
                      ) : SizedBox.shrink(),

                      controller.user?.id == orderSnap.driverId && status > 1 && status <= 3 ? normalFlatButtonWidget(
                          colour: Get.theme.errorColor,
                          context: context,
                          text: 'btnCancelOrder'.tr,
                          callFunction: () async {
                            var reason = await Get.to(CancelOrderReasons());

                            if(reason.toString().startsWith("canceledBy-")) {
                              await Database().setOrderStatus(status: 97, orderID: orderSnap.id, isDriver: true, reason: reason.toString().replaceAll("canceledBy-", ''), order: orderSnap);

                            }


                          }
                      ) : SizedBox.shrink(),

                    ],
                  ),
                );
              } else {
                return NotFound();
              }
            } else {
              return LoadingScreen(true);
            }
          }
      ),
    );
  }

  /*Widget checkboxDetails({String text, String date, bool selected}) {
    Color checkColor = Colors.grey[100];
    Color activeColor = Colors.grey[100];
    Color textColor = Colors.grey;
    if(selected) {
      checkColor = Get.theme.colorScheme.secondaryVariant;
      activeColor = Get.theme.primaryColor;
      textColor = null;
    }
    return CheckboxListTile(
      title: Text(text, style: TextStyle(color: textColor)),
      secondary: Text(date ?? '', style: TextStyle(color: textColor)),
      checkColor: checkColor,
      activeColor: activeColor,
      controlAffinity: ListTileControlAffinity.leading,
      value: selected,
      onChanged: (v) {},
    );
  }*/

  Widget statusList({String text, String date, bool selected, Widget widgetContent}) {
    return Container(
      margin: EdgeInsets.only(top: 5.0, bottom: 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 15,
            height: 15,
            margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.1 - (15/2), top: 15.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !selected ? Colors.grey[200] : Color(0xFF479AFA),
                border: Border.all(color: Colors.white, width: 3.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 7,
                    offset: Offset(0,1),
                  )
                ]
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 370),
              opacity: selected ? 1 : 0.3,
              child: Container(
                padding: EdgeInsets.all(15.0),
                margin: EdgeInsets.only(right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text),
                    widgetContent != null ? widgetContent : Text(date ?? '', style: TextStyle(fontSize: 11.0, color: Color(0xFF949597)), textDirection: TextDirection.ltr),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}