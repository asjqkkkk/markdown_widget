import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_highlight/themes/arduino-light.dart';

final Map<String, Object> lightThemeMap = {
  'PStyle': const TextStyle(color: Color(0xff1E2226)),
  'CodeStyle': TextStyle(
      fontSize: 12,
      color: const Color(0xff1e2226),
      background: _getCodeBgPaint()),
  'BlockStyle': const TextStyle(color: Color(0xffA9AAB4)),
  'LinkStyle': const TextStyle(color: Color(0xff1D81F0)),
  'CodeBackground': const Color(0xffF5F5F5),
  'TableBorderColor': const Color(0xffD7DBDF),
  'DividerColor': const Color(0xffE5E6EB),
  'BlockColor': const Color(0xffD7DBDF),
  'PreBackground': Color(0xffF3F6F9),
  'TitleColor': const Color(0xff000000),
  'UlDotColor': const Color(0xff000000),
  'HightLightCodeTheme': arduinoLightTheme,
};

Paint _getCodeBgPaint() {
  return Paint()
    ..color = Color(0xffdcdcdc)
    ..style = PaintingStyle.fill;
}
