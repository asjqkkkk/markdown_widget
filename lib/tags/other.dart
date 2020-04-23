import '../config/style_config.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;

InlineSpan getOtherWidgetSpan(m.Element node) =>
    WidgetSpan(child: getOtherWidget(node));

Widget getOtherWidget(m.Element node) {
  final customWidget = StyleConfig().pConfig?.custom;
  final m.Element customNode = node.children[0];
  if (customWidget != null) {
    return customWidget.call(customNode);
  } else {
    print('Uncatch Node:${customNode.tag}');
    return Container();
  }
}
