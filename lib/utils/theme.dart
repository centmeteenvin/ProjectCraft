import 'package:flutter/material.dart';
final ColorScheme colorScheme = ColorScheme.fromSwatch(
  primarySwatch: Colors.indigo,
);

final ThemeData theme = ThemeData(
  brightness: Brightness.light,
  colorScheme:  colorScheme,

  fontFamily: 'Roboto',

  textTheme: const TextTheme(
    titleLarge:  TextStyle(
      fontSize: 70,
      fontWeight: FontWeight.bold
    ), 
    
    ), 

  appBarTheme: AppBarTheme(
    titleTextStyle: TextStyle(
      fontSize: 30,
      color: colorScheme.onPrimary
    ),
  )


);