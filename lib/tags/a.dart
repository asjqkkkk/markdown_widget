import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

import 'p.dart';

///Tag: a
InlineSpan getLinkSpan(m.Element element) =>
    WidgetSpan(child: defaultAWidget(element));

///the link widget
Widget defaultAWidget(m.Element element) {
  PConfig pConfig = StyleConfig().pConfig;
  final url = element.attributes['href'];
  final linkWidget = P().getPWidget(
    element.children,
    element,
    textStyle: pConfig?.linkStyle ?? defaultLinkStyle,
    selectable: false,
  );
  return pConfig?.linkGesture?.call(linkWidget, url) ??
      GestureDetector(
        child: linkWidget,
        onTap: () => pConfig?.onLinkTap?.call(url),
      );
}
