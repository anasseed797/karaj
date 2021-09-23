import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karaj/controllers/orderingController.dart';
import 'package:karaj/ui_widgets/animations/fade_animation.dart';

class HomeCard extends StatelessWidget {
  final String image;
  final String text;
  final Widget navTo;
  final VoidCallback callFunction;
  final checkUserOnRIDE;
  final double delay;
  final IconData icon;

  const HomeCard({Key key, this.image, this.text, this.navTo, this.callFunction, this.checkUserOnRIDE = false, this.delay, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      delay: delay ?? 1,
      child: InkWell(
        onTap: () {
          if(!checkUserOnRIDE) {
            if(navTo == null) {
              return callFunction();
            } else if(navTo != null) {
              Get.put(OrderingController());
              Get.to(navTo);
            }
          } else {
            Get.snackbar('', 'لايمكنك تنفيد الامر حتى تنتهي من طلبك الحالي.', backgroundColor: Get.theme.backgroundColor.withOpacity(0.7));
          }

        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          decoration: BoxDecoration(
              color: Get.theme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                )
              ]
          ),
          child: Center(
            child: Column(
              children: [
                Container(
                  height: 80.0,
                  child: icon != null ? Icon(icon, size: 47) : image != null ? Image(
                    image: AssetImage(image),
                    width: 80.0,
                  ) : Container(),
                ),
                Text(text, style: TextStyle(color: Color(0xFF404b69), fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
