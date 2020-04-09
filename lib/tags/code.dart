import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag:  code
InlineSpan _defaultCodeSpan(m.Element node, TextStyle textStyle) => WidgetSpan(
      child: defaultCodeWidget(node, textStyle),
    );

Widget defaultCodeWidget(m.Element node, TextStyle textStyle) {
  final StyleConfig styleConfig = StyleConfig();
  final codeWidget = styleConfig.pConfig?.codeWidget;

  return codeWidget?.call(node.textContent) ??
      Container(
        padding: EdgeInsets.only(left: 4, right: 4),
        child: SelectableText(
          node.textContent,
          style: textStyle ?? defaultCodeStyle,
        ),
        color: defaultCodeBackground,
      );
}

InlineSpan getCodeSpan(m.Element node, TextStyle textStyle) {
  final StyleConfig styleConfig = StyleConfig();
  final textStyle = styleConfig.pConfig?.codeStyle;
  return _defaultCodeSpan(node, textStyle);
}
