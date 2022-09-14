import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: a
InlineSpan getLinkSpan(m.Element element) => _getLinkTextSpan(element);

///the link textSpan
TextSpan _getLinkTextSpan(m.Element node) {
  PConfig? pConfig = StyleConfig().pConfig;
  final url = node.attributes['href'];
  final style = pConfig?.linkStyle ?? defaultLinkStyle;
  return TextSpan(
    text: node.textContent,
    recognizer: TapGestureRecognizer()
      ..onTap = () => pConfig?.onLinkTap?.call(url),
    style: style,
  );
}
