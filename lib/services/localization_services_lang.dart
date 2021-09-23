import 'dart:ui';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:karaj/lang/ar.dart';
import 'package:karaj/lang/en.dart';


class LocalizationService extends Translations {
  final _getStorage = GetStorage();

  final keyName = "langCode";

  static final locale = Locale('ar', 'SA');

  static final fallbackLocale = Locale('ar', 'SA');

  static final languages = [ // One of this will be save in storage with key name $keyName
    'عربي',
    'English'
  ];

  static final localesSupported = [
    Locale('ar', 'SA'),
    Locale('en', 'US'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en,
    'ar_SA': ar,
  };


  Locale getLangLocale() {
    String code = _getStorage.read(keyName);
    final locale = _getLocaleFromLanguage(code);
    return locale;
  }

  Locale _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < languages.length; i++) {
      if(lang == languages[i]) return localesSupported[i];
    }
    if(Get.locale == null) {
      return localesSupported[0];
    }
    return Get.locale;
  }


  void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    saveToStorage(lang);
    Get.updateLocale(locale);
  }


  void saveToStorage(String code) {
    _getStorage.write(keyName, code);
  }

}