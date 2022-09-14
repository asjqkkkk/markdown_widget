import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag:  code
InlineSpan getCodeSpan(m.Element node) => _getCodeTextSpan(node);

///the code textSpan
TextSpan _getCodeTextSpan(m.Element node) {
  final config = StyleConfig().codeConfig;
  final style = config?.codeStyle ?? defaultCodeStyle;
  return TextSpan(style: style, children: buildSpans(node, style));
}

class CodeConfig {
  final TextStyle? codeStyle;

  CodeConfig({this.codeStyle});
}
