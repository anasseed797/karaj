import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/orderingController.dart';
import 'package:karaj/controllers/shopOnModifiedOrder.dart';
import 'package:karaj/controllers/userController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/screens/home_screen.dart';
import 'package:karaj/screens/ordering/pay_screen.dart';
import 'package:karaj/screens/ordering/select_location_from_to.dart';
import 'package:karaj/screens/rating/rating_screen.dart';
import 'package:karaj/screens/spares/details/add_tax_form.dart';
import 'package:karaj/screens/spares/details/shop_modified_item.dart';



class SparesOrderDetails extends GetWidget<ModifiedOrderController> {

  final bool navToHome;

  SparesOrderDetails({this.navToHome});

  @override
  Widget build(BuildContext context) {
    User _userAuth = FirebaseAuth.instance.currentUser;
    UserController controller = Get.find<UserController>();
    bool isShop = controller.user?.id != null && controller.user.isShop;
    return GetBuilder<ModifiedOrderController>(
      builder: (ctrl) => Scaffold(
        appBar: appBar(title: ctrl.orderData.id ?? ''),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  primary: true,
                  shrinkWrap: true,
                  itemCount: ctrl.orderData?.items?.length ?? 0,
                  itemBuilder: (BuildContext context, index) {
                    Item item = ctrl.orderData?.items[index];
                    return InkWell(
                      onTap: () async {
                        if(ctrl.orderData.status == 1 && _userAuth.uid == ctrl.orderData?.shopId) {
                          Get.bottomSheet(ShopModifiedItem(item: item));
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(8.0),
                        color: Get.theme.backgroundColor,
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(Icons.add, size: 20.0),
                                  ),
                                  Text(item.quantity.toString() ?? '', style: TextStyle(fontSize: 11.0),),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(Icons.remove, size: 20.0),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 15.0),
                            Expanded(
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[200],
                                ),
                                title: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(item.name ?? '', overflow: TextOverflow.ellipsis)),
                                    ctrl.orderData?.userId == _userAuth.uid && ctrl.orderData?.status == 2 ? IconButton(
                                      icon: Icon(Icons.cancel),
                                      onPressed: () {
                                       // ctrl.orderData.items.removeAt(index);
                                        ctrl.removeItem(index: index);
                                      },
                                    ) : SizedBox.shrink(),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(item.number ?? ''),
                                    ctrl.orderData.status > 0 ? (item.available ?? true) ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('متوفر'),
                                        Text(item.type != 1 ? 'اصلي': 'غير اصلي'),
                                        item.discount == null ? Text("${item.price ?? 0.0} ريال") : RichText(
                                          text: TextSpan(
                                              text: "${item.price ?? 0.0} ريال",
                                              style: TextStyle(fontFamily: 'Cairo', color: Colors.black),
                                              children: <TextSpan>[
                                                TextSpan(text: '\n -${item.discount ?? ''} ر.س', style: TextStyle(color: Colors.black, fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11.0)),
                                              ]
                                          ),
                                        )
                                      ],
                                    ) : Text('غير متوفر', style: TextStyle(color: Colors.red)) : SizedBox.shrink()
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),

              Container(
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.all(15.0),
                child: ctrl.orderData.status >= 1 ? Column(
                  children: [
                    ctrl.orderData?.shopId == FirebaseAuth.instance.currentUser?.uid ? Column(
                      children: [
                        paymentListDetails('clientName'.tr, "${ctrl.orderData.userName}" ?? ''),
                        paymentListDetails('clientPhone'.tr, "${ctrl.orderData.userPhone}" ?? '', keyTr: 'clientPhone', clr: Colors.blueAccent),
                      ],
                    ) : ctrl.orderData.payed == true ? Column(
                      children: [
                        paymentListDetails('shopName'.tr, "${ctrl.orderData.shopName}" ?? ''),
                        paymentListDetails('numberPhone'.tr, "${ctrl.orderData.shopPhone}" ?? '', keyTr: 'phone', textDirection: TextDirection.ltr, clr: Colors.blueAccent),
                        paymentListDetails('', 'openAddressMap'.tr, keyTr: 'map', lat: ctrl.orderData.shopAddressData['lat'], lng: ctrl.orderData.shopAddressData['lng'], clr: Colors.blueAccent),
                      ],
                    ) : SizedBox.shrink(),
                    paymentListDetails('brand'.tr, "${ctrl.orderData?.brand}"),
                    paymentListDetails('category'.tr, "${ctrl.orderData?.category}"),
                    paymentListDetails('model'.tr, "${ctrl.orderData?.model}"),
                    paymentListDetails('chassisNumber'.tr, "${ctrl.orderData?.chassisNumber}"),
                    paymentListDetails('date'.tr, ctrl.orderData.date ?? ''),

                    Divider(),
                    paymentListDetails('مجموع سعر القطع', "${ctrl.orderData?.items?.fold(0, (previousValue, element) => previousValue + (element.price ?? 0))} ر.س"),
                    paymentListDetails('الخصم', "${ctrl.orderData?.items?.fold(0, (previousValue, element) => previousValue + (element.discount ?? 0))} ر.س"),
                    InkWell(
                      onTap: () async {
                       /* if(ctrl.orderData.status == 1 && _userAuth.uid == ctrl.orderData?.shopId) {
                          Get.bottomSheet(AddTaxForm());
                        }*/
                      },
                      child:Container(
                        width: Get.width,
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("الضريبة", style: TextStyle(color: Color(0xFF6B7CAA))),
                               // SizedBox(width: 5),
                              //  Icon(Icons.mode_edit, size: 15.0,),
                              ],
                            ),
                            Text("${ctrl.orderData.tax ?? '0'} ر.س"), //Color(0xFF4A4A4A)
                          ],
                        ),
                      ),
                    ),
                    ctrl.orderData.deliveryPrice != null && ctrl.orderData.deliveryPrice > 0 ? paymentListDetails('سعر النقل', "${ctrl.orderData?.deliveryPrice} ر.س") : SizedBox(),

                    Divider(),
                    paymentListDetails('اجمالي السعر', "${Helpers.fixPrice(ctrl.orderData.totalPrice) ?? '-'} ر.س", size: 21.0),
                    _userAuth.uid == ctrl.orderData?.shopId && ctrl.orderData.deliveryPrice != null && ctrl.orderData.deliveryPrice > 0 ? paymentListDetails('سعر النقل', "${ctrl.orderData.deliveryPrice}-", size: 17.0, clr: Get.theme.errorColor) : SizedBox.shrink(),
                    paymentListDetails('', ctrl.orderData.status > 4 && ctrl.orderData.payed ? "تم الدفع" : "", size: 17.0, clr: Color(0xFF34B55E)),

                  ],
                ) : SizedBox.shrink(),
              ),

              _userAuth.uid == ctrl.orderData?.shopId && ctrl.orderData?.status == 1 ? flatButtonWidget(
                context: context,
                text: 'ارسال العرض',
                callFunction: () => ctrl.submitOffer(),
              ) : SizedBox.shrink(),

              _userAuth.uid == ctrl.orderData?.userId && ctrl.orderData?.status == 2 ? flatButtonWidget(
                context: context,
                text: 'قبول العرض',
                callFunction: () => acceptOffer(ctrl),
              ) : SizedBox.shrink(),

              _userAuth.uid == ctrl.orderData?.userId && ctrl.orderData?.status == 4 ? flatButtonWidget(
                context: context,
                text: 'تحديد موقع الاستلام',
                callFunction: () async {
                  Get.put(OrderingController());
                  Get.to(SelectLocation(isSpareOrder: true, spare: {"shopName": ctrl.orderData.shopName,"shopPhone": ctrl.orderData.shopPhone,"fromLat": ctrl.orderData.shopAddressData["lat"], "fromLng": ctrl.orderData.shopAddressData["lng"], "id": ctrl.orderData.id}));
                },
              ) : SizedBox.shrink(),

              _userAuth.uid == ctrl.orderData?.userId && ctrl.orderData.status >= 5 && ctrl.orderData?.payed == false ? flatButtonWidget(
                context: context,
                text: 'التوجه لدفع',
                callFunction: () => Get.bottomSheet(
                    Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("طريقة الدفع".tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.5)),
                            SizedBox(height: Get.height * 0.025),
                            paymentMethodCard(icon: Icons.credit_card, name: "بطاقة ماستر", key: "CARD" ),
                            paymentMethodCard(icon: Icons.credit_card, name: "بطاقة فيزا", key: "CARD" ),
                            paymentMethodCard(icon: Icons.money_sharp, name: "بطاقة مدى", key: "MADA"),
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
                    ),
                  backgroundColor: Get.theme.backgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), topLeft: Radius.circular(15.0))
                  ),
                ),
              ) : SizedBox.shrink(),


              _userAuth.uid == ctrl.orderData?.shopId && ctrl.orderData?.driverId != null && ctrl.orderData.status == 6 && ctrl.orderData.deliveryPrice != null && ctrl.orderData.deliveryPrice > 0 ? flatButtonWidget(
                context: context,
                text: 'تم تسليم لسائق',
                callFunction: () => ctrl.giveItToDriver(),
              ) : SizedBox.shrink(),

              _userAuth.uid == ctrl.orderData?.shopId && ctrl.orderData.status == 6 && (ctrl.orderData.deliveryPrice == null || ctrl.orderData.deliveryPrice <= 0) ? flatButtonWidget(
                context: context,
                text: 'تم تسليم القطع',
                callFunction: () => ctrl.giveItToUser(),
              ) : SizedBox.shrink(),


              ctrl.orderData.status == 9 && ctrl.orderData.shopVoted != true && FirebaseAuth.instance.currentUser.uid == ctrl.orderData.userId ? flatButtonWidget(
                  context: context,
                  text: 'ratingSHOP'.tr,
                  callFunction: () async {
                    var x = await Get.to(RatingScreen(type: 'shop', type2: 'spares', userID: ctrl.orderData.shopId, voter: controller.user, orderID: ctrl.orderData.id));
                    if(x == "voted") {
                      Get.back();
                    }
                  }
              ) : SizedBox.shrink(),

              ctrl.orderData.status == 9 && ctrl.orderData.clientRated != true && FirebaseAuth.instance.currentUser.uid == ctrl.orderData.shopId ? flatButtonWidget(
                  context: context,
                  text: 'ratingUSER'.tr,
                  callFunction: () async {
                    if(FirebaseAuth.instance.currentUser.uid == ctrl.orderData.shopId) {
                      var x = await Get.to(RatingScreen(type: 'user', type2: 'spares', userID: ctrl.orderData.userId, voter: controller.user, orderID: ctrl.orderData.id));
                      if(x == "voted") {
                        Get.back();
                      }
                    }
                  }
              ) : SizedBox.shrink(),

              navToHome != null && navToHome == true ? normalFlatButtonWidget(
                  colour: Colors.transparent,
                  textColor: Get.theme.primaryColor,
                  context: context,
                  text: 'home'.tr,
                  callFunction: () async {
                    Get.offAll(HomeScreen());
                  }
              ) : SizedBox.shrink(),

              SizedBox(height: 25.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentMethodCard({IconData icon, String name, bool selected = false, String key}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 7,
                offset: Offset(0,0)
            )
          ]
      ),
      child: ListTile(
        onTap: () {
          Get.back();
          Get.to(PayOrderScreen(paymentMethod: key, comingFrom: 'spares'));
        },
        leading: Icon(icon),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
      ),
    );
  }

  void acceptOffer(ModifiedOrderController ctrl) async {
    return Get.dialog(PickupType(ctrl: ctrl));
  }
  
  
  //
}

class PickupType extends StatefulWidget {
  final ModifiedOrderController ctrl;

  const PickupType({Key key, this.ctrl}) : super(key: key);

  @override
  _PickupTypeState createState() => _PickupTypeState();
}

class _PickupTypeState extends State<PickupType> {

  final Map<int, Widget> pickupTypeWidget = <int, Widget> {
    0: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('استلام من المحل')),
    1: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 7.0), child: Text('طلب توصيل')),
  };

  @override
  Widget build(BuildContext context) {
    ModifiedOrderController ctrl = widget.ctrl;
    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
            width: Get.width * 0.8,
            decoration: BoxDecoration(
                color: Get.theme.backgroundColor,
                borderRadius: BorderRadius.circular(5)
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('طريقة الاستلام'),
                  SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 35.0),
                    child: CupertinoSegmentedControl(
                      children: pickupTypeWidget,
                      borderColor: Get.theme.primaryColor,
                      pressedColor: Get.theme.primaryColor,
                      selectedColor: Get.theme.primaryColor,

                      onValueChanged: (int val) {
                        ctrl.orderData.pickupType = val;
                        ctrl.orderData.pickupTypeString = val == 0 ? 'استلام من المحل' : 'طلب توصيل';
                        ctrl.orderData.status = val == 0 ? 5 : 4;
                        ctrl.setOrder = ctrl.orderData;
                        setState(() {

                        });
                      },
                      groupValue: ctrl.orderData.pickupType,
                    ),
                  ),

                  flatButtonWidget(
                    context: Get.context,
                    text: 'متابعة',
                    callFunction: () async {
                      Get.back();
                      ctrl.updateStatus(ctrl.orderData.pickupType == 0 ? 5 : 4);
                    },
                  ),
                  SizedBox(height: 25),
                  normalFlatButtonWidget(
                    colour: Get.theme.backgroundColor,
                    textColor: Get.theme.errorColor,
                    context: Get.context,
                    text: 'الغاء',
                    callFunction: () => Get.back(),
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}
