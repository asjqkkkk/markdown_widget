import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: a
InlineSpan getLinkSpan(m.Element element) => defaultASpan(element);

///the link widget
TextSpan defaultASpan(m.Element element) {
  final config = StyleConfig().pConfig;
  final url = element.attributes['href'];
  final style = config?.linkStyle ?? defaultLinkStyle;
  final gesture = config?.linkGesture;
  return TextSpan(
      text: element.textContent, style: style, recognizer: gesture?.call(url));
}
