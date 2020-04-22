import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: isDarkNow ? Brightness.dark : Brightness.light
      ),
      home: HomePage(),
    );
  }

}

bool get isDarkNow{
  final int curHour = DateTime.now().hour;
  return curHour > 18 || curHour < 7;
}