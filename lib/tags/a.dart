import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

import 'p.dart';

InlineSpan getLinkSpan(m.Element element) =>
    WidgetSpan(child: defaultAWidget(element));

Widget defaultAWidget(m.Element element) {
  PConfig pConfig = StyleConfig().pConfig;

  return GestureDetector(
    child: P().getPWidget(
      element.children, element,
      textStyle: pConfig?.linkStyle ?? TextStyle(color: Colors.blue),
      selectable: false,
    ),
    onTap: () {
      final url = element.attributes['href'];
      pConfig?.onLinkTap?.call(url);
    },
  );
}
