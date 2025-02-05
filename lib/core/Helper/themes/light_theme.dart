import 'package:flutter/material.dart';

ThemeData lightTheme(
    {Color? bkColor,
    sfBkColor,
    btmNvBkColor,
    btmNvUnSItColor,
    btmNvSItColor,
    appBrColor,
    txtColor}) {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: sfBkColor,
    dialogBackgroundColor: bkColor,
    canvasColor: appBrColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: btmNvBkColor,
      unselectedItemColor: btmNvUnSItColor,
      selectedItemColor: btmNvSItColor,
      elevation: 0,
    ),
    bottomAppBarTheme: BottomAppBarTheme(color: appBrColor),
    buttonTheme: ButtonThemeData(
      textTheme:
          ButtonTextTheme.normal, //  <-- this auto selects the right color
    ),
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      color: appBrColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: txtColor,
        fontSize: 20,
      ),
    ),
    textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: txtColor,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(
          color: txtColor,
          fontSize: 20,
        )),
  );
}
