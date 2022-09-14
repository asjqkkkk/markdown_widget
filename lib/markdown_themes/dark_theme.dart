import 'package:flutter/painting.dart';
import 'package:markdown_widget/config/highlight_themes.dart';

final Map<String, Object> darkThemeMap = {
  'PStyle': const TextStyle(color: Color(0xffFAFAFA)),
  'CodeStyle': TextStyle(
      fontSize: 12,
      color: const Color(0xffFAFAFA),
      background: _getCodePaint()),
  'BlockStyle': const TextStyle(color: Color(0xffFAFAFA)),
  'LinkStyle': const TextStyle(color: Color(0xff1D81F0)),
  'CodeBackground': const Color(0xff555555),
  'TableBorderColor': const Color(0xffD7DBDF),
  'DividerColor': const Color(0xFF646464),
  'BlockColor': const Color(0xff646464),
  'PreBackground': const Color(0xff555555),
  'TitleColor': const Color(0xffFAFAFA),
  'UlDotColor': const Color(0xffFAFAFA),
  'HightLightCodeTheme': darkTheme,
};

Paint _getCodePaint() {
  return Paint()
    ..color = Color(0xff9c9c9c)
    ..style = PaintingStyle.fill;
}
