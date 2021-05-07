import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag:  code
InlineSpan getCodeSpan(m.Element node) => defaultCodeSpan(node);

///the code span
TextSpan defaultCodeSpan(m.Element node){
  final config = StyleConfig().codeConfig;
  final style = config?.codeStyle ?? defaultCodeStyle;
  final realStyle = style!.copyWith(background: Paint()..color = Colors.grey);
  return TextSpan(text: node.textContent, style: realStyle);
}

class CodeConfig {
  final TextStyle? codeStyle;

  CodeConfig({this.codeStyle});
}
