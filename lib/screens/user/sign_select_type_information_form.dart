import 'package:flutter/material.dart';
import 'package:karaj/bindings/widgets.dart';
import 'package:get/get.dart';
import 'package:karaj/screens/user/add_personal_information.dart';

class SignSelectTypeInformationForm extends StatefulWidget {
  @override
  _SignSelectTypeInformationFormState createState() => _SignSelectTypeInformationFormState();
}

class _SignSelectTypeInformationFormState extends State<SignSelectTypeInformationForm> {

  PageController _pageController;
  double offset = 0;
  double page = 0;
  double opy1 = 1;
  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    addLis();
    super.initState();
  }

  void addLis() {
    _pageController.addListener(() {
      offset = _pageController.offset;
      page = _pageController.page;
      opy1 = 1 - 2 * page;
      if(opy1 < 0) {
        opy1 = 0;
      } else if (opy1 > 1) {
        opy1 = 1;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: ClampingScrollPhysics(),
        controller: _pageController,
        children: [
          Padding(
            padding: EdgeInsets.all(40.0),
            child: Opacity(
              opacity: opy1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Spacer(),
                  Container(
                    child: Transform.translate(
                      offset: Offset(0.5 * offset, 0),
                      child: Center(
                        child: Icon(Icons.person_pin, size: Get.width * 0.3),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Transform.translate(
                    offset: Offset(0.4 * offset, 0),
                    child: Text('regAsUser'.tr, style: TextStyle(
                      color: Colors.black,
                      fontSize: 26.0,
                    ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Transform.translate(
                    offset: Offset(0.3 * offset, 0),
                    child: Text('regAsUserText'.tr,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),

                  Transform.translate(
                    offset: Offset(0.2 * offset, 0),
                    child: flatButtonWidget(
                      context: context,
                      text: 'regAsU'.tr,
                      callFunction: () => Get.to(AddPersonalInformation(typeSignIn: 'normalUser')),
                    ),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        _pageController.animateToPage(1, duration: Duration(milliseconds: 370), curve: Curves.linear);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('provider'.tr),
                          SizedBox(width: 5.0),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Spacer(),

                Center(
                  child: Icon(Icons.drive_eta, size: Get.width * 0.3),
                ),
                SizedBox(height: 30.0),
                Text('provider'.tr, style: TextStyle(
                  color: Colors.black,
                  fontSize: 26.0,
                ),
                ),
                SizedBox(height: 15.0),
                Text('providerText'.tr,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13.0,
                  ),
                ),
                SizedBox(height: 15.0),

                flatButtonWidget(
                  context: context,
                  text: 'createRegRequest'.tr,
                  callFunction: () => Get.to(AddPersonalInformation(typeSignIn: 'service')),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      _pageController.animateToPage(0, duration: Duration(milliseconds: 370), curve: Curves.linear);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_back),
                        SizedBox(width: 5.0),
                        Text('u'.tr),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            flatButtonWidget(
              context: context,
              text: 'مستخدم عادي',
              callFunction: () => Get.to(AddPersonalInformation(typeSignIn: 'normalUser')),
            ),
            flatButtonWidget(
              context: context,
              text: 'مزود خدمة',
              callFunction: () => Get.to(AddPersonalInformation(typeSignIn: 'service')),
            ),
          ],
        ),
      ),

 */