import '../config/style_config.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;

///Tag: other --- this is for you to custom widget
InlineSpan getOtherWidgetSpan(m.Element node) =>
    WidgetSpan(child: OtherWidget(node: node));

///the custom widget
class OtherWidget extends StatelessWidget {
  final m.Element node;

  const OtherWidget({
    Key? key,
    required this.node,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customWidget = StyleConfig().pConfig?.custom;
    final m.Element customNode = node.children![0] as m.Element;
    if (customWidget != null) {
      return customWidget.call(customNode);
    } else {
      debugPrint('UnCatch Node:${customNode.tag}');
      return Container();
    }
  }
}
