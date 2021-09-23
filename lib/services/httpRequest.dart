import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HttpRequestService {


  static Future<dynamic> get(String url) async {
    try {
      http.Response res = await http.get(Uri.tryParse(url));
      print(url);
      if(res.statusCode == 200) {
        var data = jsonDecode(res.body);
        return data;
      } else {
        return 'error';
      }
    } catch (e) {
      print(e);
      return 'error';
    }
  }

  static Future<dynamic> post({String url, }) async {
    try {


      http.Response res = await http.post(
          Uri.tryParse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer OGE4Mjk0MTc0YjdlY2IyODAxNGI5Njk5MjIwMDE1Y2N8c3k2S0pzVDg='
          }
      );
      print(url);
      if(res.statusCode == 200) {
        var data = jsonDecode(res.body);
        return data;
      } else {
        return 'error';
      }
    } catch (e) {
      Get.snackbar('حدث خطاء!', e.toString());
      return 'error';
    }
  }
}