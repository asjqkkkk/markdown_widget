import '../config/style_config.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;

///Tag: other --- this is for you to custom widget
InlineSpan getOtherWidgetSpan(m.Element node) =>
    WidgetSpan(child: getOtherWidget(node));

Widget getOtherWidget(m.Element node) {
  final customWidget = StyleConfig().pConfig?.custom;

  final customNode =
  m.Element((node.children[0] as m.Element).tag, node.children);

  if (customWidget != null) {
    // return customWidget.call(customNode);
    return customWidget.call(customNode);
  } else {
    debugPrint('UnCatch Node:${customNode.tag}');
    return Container();
  }
}