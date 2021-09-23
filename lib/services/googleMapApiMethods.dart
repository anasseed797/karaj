import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:karaj/services/httpRequest.dart';

const key = "AIzaSyCKL8wpSgwMipHrhva5Ggoch0gbPZmKeQo";
class GoogleMapApiMethods {
  static String lang = Get.locale.languageCode;

  static Future<String> getFullAddress(double latitude, double longitude) async {
    String address = "";
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$key&language=$lang";
    var res = await HttpRequestService.get(url);

    if(res != "error") {
      address = res["results"][0]["formatted_address"];
    }
    return address;
  }

  static Future<Map<String, String>> getDirections(LatLng from, LatLng to) async {
    Map<String, String> mapReturn = {
      "polylines": "",
      "totalDuration": "غير محسوب"
    };
    String polylineX = "";
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${from.latitude},${from.longitude}&destination=${to.latitude},${to.longitude}&key=$key&language=$lang";
    var res = await HttpRequestService.get(url);
    if(res == "error") {
      return null;
    }
    if(res != null && res["routes"] != null && res["routes"].length > 0) {
      polylineX = res["routes"][0]["overview_polyline"]["points"];
      mapReturn["polylines"] = polylineX;
      mapReturn["totalDuration"] = res["routes"][0]["legs"][0]["duration"]["text"];
    }
    return mapReturn;
  }


  static Future findPlaces(String placeName) async {
    String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$key&components=country:sa&language=$lang";
    var res = await HttpRequestService.get(url);

    if(res != "error") {
      return res;
    }
    return null;
  }

  static Future getPlaceDetails(String placeID) async {
    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$key&language=$lang";
    var res = await HttpRequestService.get(url);

    if(res != "error") {
      return res;
    }
    return null;
  }

  static Future getDuration({lat1, lng1, lat2, lng2}) async {
    String url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$lat1,$lng1|$lat2,$lng2&key=$key&language=$lang";
  }
}