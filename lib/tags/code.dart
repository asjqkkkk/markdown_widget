import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag:  code
InlineSpan getCodeSpan(m.Element node) =>
    WidgetSpan(child: defaultCodeWidget(node));

///the code widget
Widget defaultCodeWidget(m.Element node) {
  final config = StyleConfig().codeConfig;

  return Container(
    padding: config?.padding ??
        EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
    decoration: config?.decoration ??
        BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          color: defaultCodeBackground,
        ),
    child: SelectableText(
      node.textContent,
      style: config?.codeStyle ?? defaultCodeStyle,
    ),
  );
}

class CodeConfig {
  final EdgeInsetsGeometry padding;
  final Decoration decoration;
  final TextStyle codeStyle;

  CodeConfig({this.padding, this.decoration, this.codeStyle});
}
