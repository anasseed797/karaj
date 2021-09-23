import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:karaj/controllers/sparesOrderingController.dart';
import 'package:karaj/helpers.dart';
import 'package:karaj/models/spares.dart';
import 'package:karaj/screens/spares/save_vehicles_list.dart';
import 'package:karaj/screens/spares/shops_list_screen.dart';
import 'package:karaj/services/categories_data.dart';

class RequestSparesScreen extends StatefulWidget {
  @override
  _RequestSparesScreenState createState() => _RequestSparesScreenState();
}

class _RequestSparesScreenState extends State<RequestSparesScreen> {

  SparesOrderingController orderCtrl;
  Map<String, List<String>> _brands = Brands.brands;

  List<String> _brandsList = [];
  List<String> _modelList = [];
  List<String> _categoryList = [];
  String brandValue, modelValue, categoryValue;
  TextEditingController chassisNumber;

  @override
  void initState() {
    orderCtrl = Get.put(SparesOrderingController());
    _brands = Brands.brands;

    if(_brands != null) {
      _brands.forEach((key, value) {
        _brandsList.add(key);
      });
      _modelList = Brands.models();

      brandValue = _brandsList[0];
      modelValue = _modelList[0];
      categoryValue = _brands[brandValue][0];
      _categoryList = _brands[brandValue];

    }

    chassisNumber = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: "requestSpares".tr),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            ContainerCard(
              padd: 10.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 2, child: Text("brand".tr)),
                  Expanded(
                    flex: 1,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: brandValue,
                      hint: Text("all".tr),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (v) {
                        brandValue = v;
                        if(_brands.containsKey(v)) {
                          categoryValue = _brands[v][0];
                          _categoryList = _brands[v];
                        }
                        setState(() {

                        });
                      },
                      underline: Container(
                        color: Colors.transparent,
                      ),
                      items: _brandsList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value ?? ''),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 35.0),
            ContainerCard(
              padd: 10.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 2, child: Text("model".tr)),
                  Expanded(
                    flex: 1,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: modelValue,
                      hint: Text("الكل".tr),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (v) {
                        setState(() {
                          modelValue = v;
                        });
                      },
                      underline: Container(
                        color: Colors.transparent,
                      ),
                      items: _modelList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value ?? ''),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 35.0),
            _categoryList != null && _categoryList.length > 0 ? ContainerCard(
              padd: 10.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 2, child: Text("category".tr)),
                  Expanded(
                    flex: 1,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: categoryValue,
                      hint: Text("all".tr),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (v) {
                        setState(() {
                          categoryValue = v;
                        });
                      },
                      underline: Container(
                        color: Colors.transparent,
                      ),
                      items: _categoryList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value ?? ''),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ) : SizedBox.shrink(),


            SizedBox(height: 35.0),

            TextFormField(
              controller: chassisNumber,
              validator: (value) {
                if (value != null && (value.length > 9 || value.length < 9)) {
                  return "chassisNumber".tr;
                }
                return null;
              },
              decoration: inputDecorationUi(context, 'chassisNumber'.tr, color: Get.theme.backgroundColor),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
            ),

            SizedBox(height: Get.height * 0.03),
            flatButtonWidget(
              context: context,
              text: 'search'.tr,
              callFunction: () => doSearch()
            ),
            SizedBox(height: Get.height * 0.03),
            Container(
              child: Padding(
                padding: EdgeInsets.only(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(child: horizontalLine()),
                    Text("or".tr),
                    Expanded(child: horizontalLine())
                  ],
                ),
              ),
            ),
            Container(child: SavedVehiclesSpares()),
          ],
        ),
      ),
    );
  }

  Widget horizontalLine() =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          height: 1.0,
          color: Colors.black.withOpacity(0.6),
        ),
      );

  void doSearch() async {
    if(brandValue.isEmpty || brandValue == null) {
      GetxWidgetHelpers.mSnackBar('يرجى ملئ جميع الخانات', 'يرجى اختيار ماركة السيارة التي تريد البحث لها عن قطع غيار');
      return;
    } else if (modelValue.isEmpty || modelValue == null) {
      GetxWidgetHelpers.mSnackBar('يرجى ملئ جميع الخانات', 'يرجى اختيار سنة صنع السيارة.');
      return;
    } else if (categoryValue.isEmpty || categoryValue == null) {
      GetxWidgetHelpers.mSnackBar('يرجى ملئ جميع الخانات', 'يرجى اختيار فئة السيارة التي تريد البحث لها عن قطع غيار');
      return;
    } else if (chassisNumber.text.isEmpty || chassisNumber.text == null) {
      GetxWidgetHelpers.mSnackBar('يرجى ملئ جميع الخانات', 'يرجى ادخال رقم الهيكل الخاص بالسيارة.');
      return;
    }

    SparesModel _o = orderCtrl.order;
    _o.brand = brandValue;
    _o.model = modelValue;
    _o.category = categoryValue;
    _o.chassisNumber = chassisNumber.text;
    orderCtrl.setOrder = _o;
    String id = "$brandValue-$modelValue-$categoryValue-${chassisNumber.text}";
    FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).collection("vehiclesSpares").doc(id).set(
      {
        "brand": brandValue,
        "model": modelValue,
        "category": categoryValue,
        "chassisNumber": chassisNumber.text,
      }
    );
    Get.to(ShopsListScreen());
  }
}
