import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag:  code
InlineSpan _defaultCodeSpan(m.Element node, TextStyle textStyle) =>
    WidgetSpan(child: defaultCodeWidget(node, textStyle));

Widget defaultCodeWidget(m.Element node, TextStyle textStyle) {
  final StyleConfig styleConfig = StyleConfig();
  final codeWidget = styleConfig.pConfig?.codeWidget;

  return codeWidget?.call(node.textContent) ??
      Container(
        padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          color: defaultCodeBackground,
        ),
        child: SelectableText(
          node.textContent,
          style: textStyle ?? defaultCodeStyle,
        ),
      );
}

InlineSpan getCodeSpan(m.Element node, TextStyle textStyle) {
  final StyleConfig styleConfig = StyleConfig();
  final textStyle = styleConfig.pConfig?.codeStyle;
  return _defaultCodeSpan(node, textStyle);
}
