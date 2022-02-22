import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: a
InlineSpan getLinkSpan(m.Element element) =>
    WidgetSpan(child: AWidget(element: element));

///the link widget
class AWidget extends StatelessWidget {
  final m.Element element;

  const AWidget({Key? key, required this.element}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PConfig? pConfig = StyleConfig().pConfig;
    final url = element.attributes['href'];
    final linkWidget = PWidget(
      children: element.children,
      parentNode: element,
      textStyle: pConfig?.linkStyle ?? defaultLinkStyle,
      selectable: false,
    );
    return pConfig?.linkGesture?.call(linkWidget, url) ??
        GestureDetector(
          child: linkWidget,
          onTap: () => pConfig?.onLinkTap?.call(url),
        );
  }
}
