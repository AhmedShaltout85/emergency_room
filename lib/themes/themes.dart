import 'package:flutter/material.dart';

class AppTheme {
  static const primColor = Colors.indigo;
  static const txtColor = Colors.white;
  static const primTextColor = Colors.blue;
  static const bgColor = Colors.indigoAccent;
  static ThemeData setTheme() {
    return ThemeData(
      scaffoldBackgroundColor: txtColor,
      primarySwatch: primColor,
      primaryColor: primColor,
      appBarTheme: const AppBarTheme(
        // systemOverlayStyle: SystemUiOverlayStyle(
        //   statusBarBrightness: Brightness.light,
        // ),
        centerTitle: true,
        elevation: 3.0,
        color: primColor,
        iconTheme: IconThemeData(
          color: txtColor,
        ),
        actionsIconTheme: IconThemeData(
          color: txtColor,
        ),
        titleTextStyle: TextStyle(
          color: txtColor,
        ),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: primColor,
        elevation: 4.0,
      ),
      buttonTheme: const ButtonThemeData(
          buttonColor: primColor,
          height: 43,
          textTheme: ButtonTextTheme.normal,
          splashColor: bgColor),
      drawerTheme: DrawerThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(13),
            bottomRight: Radius.circular(13),
          ),
        ),
        backgroundColor: txtColor,
        elevation: 7.0,
        scrimColor: Colors.black12.withOpacity(0.7),
      ),
     
      iconTheme: const IconThemeData(
        color: primTextColor,
        size: 27.0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 17,
          color: txtColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 23,
          color: primTextColor,
        ),
      ),
      primaryTextTheme: const TextTheme(),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(),
      ),
    );
  }
}

