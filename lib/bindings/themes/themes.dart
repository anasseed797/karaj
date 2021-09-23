import 'package:flutter/material.dart';



class Themes {
  static const Color siteColor = Colors.black;
  static const Color bg = Colors.white;
  static const Color scaffoldBg = const Color(0xfffafbfc);

  static const _lightFillColor = Colors.white;

  static ThemeData lightTheme = ThemeData(
      colorScheme: ColorScheme(
        primary: siteColor,
        primaryVariant: Colors.black,
        secondary: Color(0xFFEFF3F3),
        secondaryVariant: Colors.white,
        background: Colors.white,
        surface: Color(0xFFFAFBFB),
        onBackground: Colors.grey[200],
        error: _lightFillColor,
        onError: _lightFillColor,
        onPrimary: _lightFillColor,
        onSecondary: Color(0xFF322942),
        onSurface: Color(0xFF241E30),
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(
              color: Colors.black
          ),
        elevation: 0.0,
      ),
      primaryColor: siteColor,
      primaryColorDark: Color(0xFFffd700),
      scaffoldBackgroundColor: scaffoldBg,
      backgroundColor: Colors.white,
      fontFamily: 'Cairo',
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          foregroundColor: Colors.white
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: siteColor,
      ),

      textTheme: TextTheme(
        headline6: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15.0),
        headline5: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        headline4: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),

      )
  );


}
