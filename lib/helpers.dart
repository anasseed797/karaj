import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  static  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  static Future<List<LatLng>> decodeEndpointPolyline(String endpoint) async {
    List<LatLng> pLineCoordinates = [];
    if(endpoint != null) {
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodePolyLinePointsResult = polylinePoints.decodePolyline(endpoint);
      if (decodePolyLinePointsResult.isNotEmpty) {
        decodePolyLinePointsResult.forEach((PointLatLng pointLatLng) {
          pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        });
      }

      return pLineCoordinates;
    } else {
      return null;
    }
  }

  static Future<bool> checkLocationPermission() async {
    bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if(!gpsEnabled) {
      GetxWidgetHelpers.mSnackBar('خدمات تحديد الموقع غير مفعلة', 'يرجى تفعيل خاصية تحديد الموقع بهاتفك لكي تتمكن من استهدام الخاصية.', duration: Duration(seconds: 3));
      return false;
    }
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if(permission == null) {
      GetxWidgetHelpers.mSnackBar('خدمات تحديد الموقع غير مفعلة', 'تم رفض السماح باستخدام خاصية تحديد الموقع.', duration: Duration(seconds: 3));
      return false;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        GetxWidgetHelpers.mSnackBar('خدمات تحديد الموقع غير مفعلة', 'تم رفض السماح باستخدام خاصية تحديد الموقع.', duration: Duration(seconds: 3));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      GetxWidgetHelpers.mSnackBar('خدمات تحديد الموقع مرفوضة', 'خدمة تحديد الموقع مرفضة بشكل دائم لذلك يرجى تفعلها من خصائص التطبيق.', duration: Duration(seconds: 3));
      return false;
    }

    return true;
  }
  /*

  String googleUrl = 'https://www.google.com/maps/place/${userData.lat},${userData.lng}/@${userData.lat},${userData.lng}';
                                                              String iosUrl = 'https://maps.apple.com/?ll=${userData.lat},${userData.lng}';
                                                              if (await canLaunch(googleUrl)) {
                                                                await launch(googleUrl);
                                                              } else if (await canLaunch(iosUrl)) {
                                                                await launch(iosUrl);
                                                              } else {
                                                                Toast.show('لايمكن فتح الخريطة حاليا.', context);
                                                              }


   */
  static Future<void> makeCallPhone(String numberPhone) async {
    String number = numberPhone.replaceAll('+9660', '0');
    number = numberPhone.replaceAll('+966', '0');
    if(number.startsWith('5')) {
      number = "0$number";
    }

    // var url = 'whatsapp://send?phone=$phone&text=${Uri.parse("السلام عليكم \n انا اراسلك من تطبيق دلالة بخصوص اعلانك \"${setUpPostTitle(postData)}\".")}';
    var url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> launchMap({var lat, var lng}) async {
    String googleUrl = 'https://www.google.com/maps/place/$lat,$lng/@$lat,$lng';
    String iosUrl = 'https://maps.apple.com/?ll=$lat,$lng';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else if (await canLaunch(iosUrl)) {
      await launch(iosUrl);
    } else {
      GetxWidgetHelpers.mSnackBar("حدث خطاء!", "لايمكن فتح الخريطة حاليا.");
    }
  }


  static String farsiToEnglish(String string) {
    if(string.isNotEmpty) {
      const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
      const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨','٩'];
      const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      string = string.toString();
      for (int i = 0; i < english.length; i++) {
        string = string.replaceAll(farsi[i], english[i]);
      }
      for (int i = 0; i < english.length; i++) {
        string = string.replaceAll(arabic[i], english[i]);
      }
      return string;
    }
    return string;
  }

  static String englishToArabic(String string) {
    if(string.isNotEmpty) {
      const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨','٩'];
      string = string.toString();
      for (int i = 0; i < arabic.length; i++) {
        string = string.replaceAll(english[i], arabic[i]);
      }
      return string;
    }
    return string;
  }


  static String fixPrice(var price) {
    double sPrice = double.tryParse(price.toString() ?? "0.0");
    if(sPrice != null) {
      return sPrice.toStringAsFixed(2);
    }
    return "0.00";
  }

  static int toIntFix(var number) {
    if(number != null && number.toString().isNotEmpty) {
      int sNumber = int.tryParse(number.toString() ?? "0");
      if(sNumber != null) {
        return sNumber;
      }
    }
    return 0;
  }

}

class GetxWidgetHelpers {
  static void mSnackBar(String title, String body, {Duration duration, Color colorText}) {
    return Get.snackbar(title ?? '', body ?? '', duration: duration ?? Duration(seconds: 3), backgroundColor: Get.theme.backgroundColor.withOpacity(0.7));
  }
}


























