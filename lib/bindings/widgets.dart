import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/helpers.dart';

Widget appBar({String title, Color clr, Color iconClr}) {
  return AppBar(
    title: Text(title ?? '', style: TextStyle(color: Get.theme.colorScheme.primaryVariant)),
    centerTitle: true,
    backgroundColor: clr ?? null,
    iconTheme: IconThemeData(
      color: iconClr,
    ),
  );
}


Widget circleAvatarNetwork({String src, double radius, Color color, Widget imageWidget}) {
  return src != null && src.trim().isNotEmpty ?  CircleAvatar(
    backgroundColor: color == null ? Colors.grey : color,
    backgroundImage: imageWidget == null ? NetworkImage(src) : imageWidget,
    radius: radius,
  ) : CircleAvatar(
    backgroundColor: color == null ? Colors.grey : color,
    radius: radius,
  );
}

class NotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(
          image: AssetImage("assets/images/404.png"),
        ),
        Text("404", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 80.0))
      ],
    );
  }
}


class StarDisplay extends StatelessWidget {
  final value;

  const StarDisplay({Key key, this.value = 0}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    int v = value.toInt();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(Icons.star,
            color: index < v ? Colors.yellow[600] : Colors.grey,
            size: 17.0);
      }),
    );
  }
}

class StarDisplayVote extends StatelessWidget {
  final int value;
  final void Function(int index) onChanged;

  const StarDisplayVote({Key key, this.value, this.onChanged}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Container(
          width: 30.0,
          child: IconButton(
            onPressed: onChanged != null ? () {
              onChanged(value == index + 1 ? index : index + 1);
            } : null ,
            icon: Icon(index < value ? Icons.star : Icons.star_border,
                color: index < value ? Colors.yellow[600] : Colors.grey,
                size: 30.0
            ),
          ),
        );
      }),
    );
  }
}

Widget displayNearByKm({var km}) {
  return RichText(
    text: TextSpan(
        text: '$km ',
        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13.0),
        children: <TextSpan>[
          TextSpan(text: "km".tr, style: TextStyle(color: Get.theme.primaryColor, fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11.0)),
        ]
    ),
  );
}

Widget flatButtonWidget({BuildContext context, String text, VoidCallback callFunction}) {
  return TextButton(
    onPressed: callFunction,
    child: Text('$text', style: Get.theme.textTheme.headline6),
    style: TextButton.styleFrom(
        backgroundColor: Get.theme.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 7.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        )
    ),

  );
}

Widget normalFlatButtonWidget({bool onLoading = false, BuildContext context, String text, VoidCallback callFunction, EdgeInsetsGeometry padding, double radius = 18.0, Color colour, Color textColor}) {
  Color colourX = colour ?? Get.theme.primaryColor;
  return TextButton(
    onPressed: onLoading ? () => {} : callFunction,
    child: onLoading ? Container(height: 21, width: 21, child: CircularProgressIndicator(color: Get.theme.backgroundColor)) : Text('$text', style: Get.theme.textTheme.headline6.copyWith(color: textColor)),
    style: TextButton.styleFrom(
      backgroundColor: colourX,
      padding: padding == null ? EdgeInsets.symmetric(horizontal: 18.0) : padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

Widget titleText(String text) {
  return Text(text ?? '', style: Get.theme.textTheme.headline5);
}


InputDecoration inputDecorationUi(BuildContext context, hintText, {Color color, IconData icon, String suffixText = "", String counterText = ""}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.only(right: 11.0, left: 5.0),
    suffixText: suffixText,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: color != null ? color : Get.theme.backgroundColor,
    counterText: counterText,
  );
}


Widget serviceContainer({String title, String subtitle, String trailing,Color containerColor, Color textColor, bool selected = false}) {
  return Container(
    margin: EdgeInsets.only(bottom: 15.0),
    decoration: BoxDecoration(
        color: selected ? Get.theme.primaryColor : Get.theme.backgroundColor,
        borderRadius: BorderRadius.circular(5)
    ),
    child: ListTile(
      title: Text(title ?? '', style: TextStyle(color: selected ? Get.theme.colorScheme.secondaryVariant : Get.theme.colorScheme.primaryVariant)),
      subtitle: Text(subtitle ?? '', style: TextStyle(color: selected ? Get.theme.colorScheme.secondaryVariant : Colors.grey, fontSize: 11.0,)),
      trailing: Text("$trailing ${"sar".tr}" ?? '', style: TextStyle(color: selected ? Get.theme.colorScheme.secondaryVariant : Get.theme.primaryColor, fontWeight: FontWeight.bold),),
    ),
  );
}


class LoadingScreen extends StatefulWidget {
  final bool visible;
  final String statusText;
  LoadingScreen(this.visible, {this.statusText});
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Visibility(
        visible: widget.visible,
        child: Container(
          alignment: Alignment.center,
          color: Get.theme.scaffoldBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
              SizedBox(height: 35.0),
              widget.statusText != null ? Text("${widget.statusText ?? ''} ") : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: Get.width,
      height: Get.height * 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage("assets/images/empty.png"),
            width: Get.width * 0.7,
          ),
          Text("noOrdersToDisplay".tr, style: TextStyle(fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }
}



Widget paymentListDetails(String name, String value, {double size, String keyTr = '', String uid, Color clr, TextDirection textDirection, var lat, var lng}) {
  Widget vText = Text(value, style: TextStyle(fontSize: size != null ? size : null, color: clr != null ? clr : null), textDirection: textDirection ?? null);
  return Container(
    width: Get.width,
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: TextStyle(color: Color(0xFF6B7CAA))),
        keyTr.toLowerCase().contains('phone') || keyTr.toLowerCase().contains('driverName') || keyTr.toLowerCase().contains('map') ? InkWell(
          onTap: () {
            if(keyTr.toLowerCase().contains('phone')) {
              Helpers.makeCallPhone(value);
            } else if (keyTr.toLowerCase().contains('map')) {
              Helpers.launchMap(lat: lat, lng: lng);
            }
          },
          child: vText,
        ) : vText, //Color(0xFF4A4A4A)
      ],
    ),
  );
}


Widget orderStatus(int status) {
  String text = "";
  Color color;
  switch(status) {
    case 0: {
      text = "waitingPay".tr;
      color = Colors.grey;
    }
    break;
    case 1: {
      text = "searching".tr;
      color = Colors.grey[200];
    }
    break;
    case 2: {
      text = "waitingAccept".tr;
      color = Colors.orange;
    }
    break;
    case 3: {
      text = "picking".tr;
      color = Colors.black;
    }
    break;
    case 4: {
      text = "picking".tr;
      color = Colors.black;
    }
    break;
    case 5: {
      text = "picking".tr;
      color = Colors.black;
    }
    break;
    case 9: {
      text = "delivered".tr;
      color = Colors.green;
    }
    break;
    case 97: {
      text = "canceledOrder".tr;
      color = Colors.red;
    }
    break;
  }
  if(color == null) {
    return SizedBox.shrink();
  } else {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: color),
        color: Get.theme.backgroundColor
      ),
      child: Text(text, style: TextStyle(fontSize: 13.0)),
    );
  }
}

String orderSpareStatus(int status) {
  String text = "";
  //Color color;
  switch(status) {
    case 0: {
      text = "draft".tr;
      //color = Colors.grey;
    }
    break;
    case 1: {
      text = "waiting".tr;
      //color = Colors.grey[200];
    }
    break;
    case 2: {
      text = "offering".tr;
      //color = Colors.orange;
    }
    break;
    case 3: {
      text = "waitingPay".tr;
      //color = Colors.black;
    }
    break;
    case 5: {
      text = "waitingToGet".tr;
      //color = Colors.black;
    }
    break;
    case 6: {
      text = "waitingToGet".tr;
      //color = Colors.black;
    }
    break;
    case 7: {
      text = "picking".tr;
      //color = Colors.green;
    }
    break;
    case 8: {
      text = "picking".tr;
      //color = Colors.green;
    }
    break;
    case 9: {
      text = "delivered".tr;
      //color = Colors.green;
    }
    break;
    case 97: {
      text = "canceledOrder".tr;
      //color = Colors.red;
    }
    break;
  }
  return text;
}

class LogoUi extends StatelessWidget {
  final bool isSmallScreen;

  const LogoUi({Key key, this.isSmallScreen = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: Align(
        alignment: Alignment.center,
        child: Image(
          image: AssetImage('assets/images/logo.jpg'),
          width: isSmallScreen ? 150.0: 250.0,
        ),
      ),
    );
  }
}


class ContainerCard extends StatelessWidget {

  final Widget child;
  final double padd;

  const ContainerCard({Key key, this.child, this.padd}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padd != null ? padd : 25.0),
      decoration: BoxDecoration(
        color: Get.theme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
          )
        ]
      ),
      child: child,
    );
  }
}

