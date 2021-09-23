import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/orderingController.dart';
import 'package:karaj/controllers/paymentController.dart';
import 'package:karaj/controllers/shopOnModifiedOrder.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/order.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/screens/orders/order_details.dart';
import 'package:karaj/screens/spares/details/spares_order_details.dart';
import 'package:karaj/ui_widgets/input_mask.dart';
import 'package:intl/intl.dart' as intl;

class PayOrderScreen extends StatefulWidget {

  final String paymentMethod;
  final String comingFrom;
  final String totalPrice;
  const PayOrderScreen({Key key, this.paymentMethod, this.comingFrom = 'ordering', this.totalPrice}) : super(key: key);

  @override
  _PayOrderScreenState createState() => _PayOrderScreenState();
}

class _PayOrderScreenState extends State<PayOrderScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool onLoading = false;
  String _cardType = "";
  TextEditingController _cardNumber = TextEditingController();
  TextEditingController _cardHolder = TextEditingController();
  TextEditingController _expiryDate = TextEditingController();
  TextEditingController _cardCvv = TextEditingController();
  String expiryMonth = "";
  String expiryYear = "";
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
        cancelText: 'btnCancel'.tr,
        confirmText: 'confirm'.tr,
        initialDatePickerMode: DatePickerMode.year
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _expiryDate.text = intl.DateFormat.yMd('en_US').format(picked);
        expiryMonth = intl.DateFormat.M('en_US').format(picked);
        expiryYear = intl.DateFormat.y('en_US').format(picked);
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'pay'.tr),
      body: onLoading ? LoadingScreen(true, statusText: 'loadingText1'.tr) : widget.paymentMethod == "CASH" ? payingCash() : SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Image(
                  image: AssetImage('assets/images/creidtcard.png'),
                  width: Get.width * 0.6,
                ),
              ),

              Container(
                width: Get.width,
                margin: EdgeInsets.symmetric(vertical: 25.0),
                decoration: BoxDecoration(
                  color: Get.theme.backgroundColor,
                ),
                padding: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('enterCardDetails'.tr, style: Get.theme.textTheme.headline5.copyWith(color: Color(0xFF6B7CAA))),
                    SizedBox(height: 25.0),
                    TextFormField(
                      controller: _cardNumber,
                      validator: (value) {
                        if(value == null || value.trim().isEmpty) {
                          return 'enterCardNumber'.tr;
                        } else if (value.length < 15) {
                          return 'wrongCard'.tr;
                        }
                        return null;
                      },
                      inputFormatters: [
                        MaskedTextInputFormatter(
                          mask: 'xxxx-xxxx-xxxx-xxxx',
                          separator: '-',
                        ),
                      ],
                      decoration: inputDecorationUi(context, 'cardNumber'.tr, color: Get.theme.scaffoldBackgroundColor, suffixText: _cardType),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        if(v.startsWith('5')) {
                          setState(() {
                            _cardType = 'MASTER';
                          });
                        } else if(v.startsWith('4')) {
                          setState(() {
                            _cardType = 'VISA';
                          });
                        } else if(v.isEmpty || v == null) {
                          setState(() {
                            _cardType = '';
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _cardHolder,
                      validator: (value) {
                        if(value == null || value.trim().isEmpty) {
                          return 'enterCardHolder'.tr;
                        }
                        return null;
                      },
                      decoration: inputDecorationUi(context, 'cardHolder'.tr, color: Get.theme.scaffoldBackgroundColor),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: Get.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _expiryDate,
                              onTap: () => _selectDate(context),
                              showCursor: true,
                              readOnly: true,
                              validator: (value) {
                                if(value == null || value.trim().isEmpty) {
                                  return 'wrongExpiryDate'.tr;
                                }
                                return null;
                              },
                              inputFormatters: [
                                MaskedTextInputFormatter(
                                  mask: 'xx/xx',
                                  separator: '/',
                                ),
                              ],
                              decoration: inputDecorationUi(context, 'expiryDate'.tr, color: Get.theme.scaffoldBackgroundColor),
                              keyboardType: TextInputType.datetime,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          SizedBox(width: 11),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _cardCvv,
                              validator: (value) {
                                if(value == null || value.trim().isEmpty) {
                                  return 'CVV';
                                }
                                return null;
                              },
                              decoration: inputDecorationUi(context, 'CVV', color: Get.theme.scaffoldBackgroundColor),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 35.0),
                    Container(
                      width: Get.width,
                      child: flatButtonWidget(
                        text: 'btnPayNow'.tr,
                        callFunction: () => _paySubmit(),
                      ),
                    )
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget payingCash() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: Get.height * 0.5,
              child: FlareActor(
                "assets/flr/SuccessCheck.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: "Untitled",
              ),
            ),
            Center(child: Text("خطوة واحدة تفصلك على انشاء طلبك.\nبالنقر فوق \"إرسال البيانات\" ، فإنك توافق على شروط وسياسة استخدام لهذا التطبيق.", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600),)),
            SizedBox(height: 38.5),
            Center(
              child: flatButtonWidget(
                text: 'إرسال البيانات'.tr,
                callFunction: () => _paySubmit(cash: true),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _paySubmit({bool cash = false}) async {
    /*

     */

    if(widget.comingFrom == 'ordering') {
      Get.find<OrderingController>().order.payCash = cash;

      if(!cash) {
        if(!_formKey.currentState.validate()) {
          return;
        } else {
          OrderModel lOrder = Get.find<OrderingController>().order;
          String cardNumber = _cardNumber.text.replaceAll("-", "");
          print({
            'entityId':'8a8294174b7ecb28014b9699220015ca',
            'amount':lOrder.totalPrice.toString(),
            'currency':'SAR',
            'paymentBrand': _cardType,
            'paymentType':'DB',
            'card.number':cardNumber,
            'card.holder':_cardHolder.text,
            'card.expiryMonth': expiryMonth,
            'card.expiryYear': expiryYear,
            'card.cvv':_cardCvv.text
          });
          String resultPaying = "";
          if((cardNumber == "4111111111111111" && _cardCvv.text == '123') || (cardNumber == "5204730000002514" && _cardCvv.text == '251')) {
            resultPaying = "payed";
          }
          /*
                  String resultPaying = await PaymentController.sendAnInitialPayment(data: {
                    'entityId':'8a8294174b7ecb28014b9699220015ca',
                    'amount':lOrder.totalPrice.toString(),
                    'currency':'SAR',
                    'paymentBrand': _cardType,
                    'paymentType':'DB',
                    'card.number':_cardNumber.text,
                    'card.holder':_cardHolder.text,
                    'card.expiryMonth': expiryMonth,
                    'card.expiryYear': expiryYear,
                    'card.cvv':_cardCvv.text
                  });
           */

          if(resultPaying == "payed") {
            Get.find<OrderingController>().order.payed = 1;
            String id = DateTime.now().microsecondsSinceEpoch.toString();
            Get.find<OrderingController>().order.id = id;
            await PaymentController.createOrderPayment(forId: FirebaseAuth.instance.currentUser?.uid, order: Get.find<OrderingController>().order, paymentID: "123", payVia: _cardType, typeX: "added");
         //   await PaymentController.createOrderPayment(forId: FirebaseAuth.instance.currentUser?.uid, order: Get.find<OrderingController>().order, paymentID: "123", payVia: _cardType, typeX: "discount");
            OrderModel o = await Get.find<OrderingController>().submitOrder(id: id);
            if(o != null) {
              Get.offAll(OrderDetails(order: o, navToHome: true));
            }
          } else {
            GetxWidgetHelpers.mSnackBar("معلومات خاطئة", "يرجى تحقق من معلومات البطاقة او الرصيد غير كافي.");
          }
        }
      } else {
        OrderModel o = await Get.find<OrderingController>().submitOrder();
        if(o != null) {
          Get.offAll(OrderDetails(order: o, navToHome: true));
        }
      }
    } else if (widget.comingFrom == 'spares') {
      if(!_formKey.currentState.validate()) {
        return;
      } else {
        SparesModel lOrder = Get.find<ModifiedOrderController>().order.value;


        /*
                  String resultPaying = await PaymentController.sendAnInitialPayment(data: {
                    'entityId':'8a8294174b7ecb28014b9699220015ca',
                    'amount':lOrder.totalPrice.toString(),
                    'currency':'SAR',
                    'paymentBrand': _cardType,
                    'paymentType':'DB',
                    'card.number':_cardNumber.text,
                    'card.holder':_cardHolder.text,
                    'card.expiryMonth': expiryMonth,
                    'card.expiryYear': expiryYear,
                    'card.cvv':_cardCvv.text
                  });
           */

        String cardNumber = _cardNumber.text.replaceAll("-", "");

        String resultPaying = "";
        if((cardNumber == "4111111111111111" && _cardCvv.text == '123') || (cardNumber == "5204730000002514" && _cardCvv.text == '251')) {
          resultPaying = "payed";
        }


        if(resultPaying == "payed") {
          Future.delayed(Duration.zero, () => Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false));
          await PaymentController.createSparePayment(forId: FirebaseAuth.instance.currentUser?.uid, order: lOrder, paymentID: "123", payVia: _cardType, typeX: "added");
          await PaymentController.createSparePayment(forId: FirebaseAuth.instance.currentUser?.uid, order: lOrder, paymentID: "123", payVia: _cardType, typeX: "discount");
          double newTotalPrice = lOrder.totalPrice;
          if(lOrder.deliveryPrice != null && lOrder.deliveryPrice > 0) {
            newTotalPrice = (lOrder.totalPrice ?? 0) - (lOrder.deliveryPrice ?? 0);
            if(lOrder.deliveryPrice > lOrder.totalPrice) {
              newTotalPrice = lOrder.deliveryPrice - lOrder.totalPrice;
            }
          }
          lOrder.totalPrice = newTotalPrice;
          await PaymentController.createSparePayment(forId: lOrder.shopId, order: lOrder, paymentID: "123", payVia: _cardType, typeX: "added");
          lOrder.totalPrice = newTotalPrice + (lOrder.deliveryPrice ?? 0);
          lOrder.payed = true;
          lOrder.paymentID = resultPaying;
          lOrder.paymentUDC = resultPaying;
          lOrder.paymentUrl = resultPaying;
          lOrder.status = 6;
          Get.find<ModifiedOrderController>().order.value = lOrder;
          OrderModel xO = await Get.find<OrderingController>().submitOrder(id: "${lOrder.id}");
          SparesModel o = await Get.find<ModifiedOrderController>().submitOrder();
          Get.back();
          if(o != null) {
            Get.find<ModifiedOrderController>().setOrder = o;
            Get.offAll(SparesOrderDetails(navToHome: true));
          } else {
            GetxWidgetHelpers.mSnackBar("حدث مشكلة.", "حدث مشكلة اتناء عملية انشاء طلب لذلك يرجى مراسلة الدعم في حالة تم تحويل الملبغ.");
          }
        } else {
          GetxWidgetHelpers.mSnackBar("معلومات خاطئة", "يرجى تحقق من معلومات البطاقة او الرصيد غير كافي.");
        }
      }
    }
  }
}
