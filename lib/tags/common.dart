import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;

import '../config/html_support.dart';
import '../config/style_config.dart';
import 'markdown_tags.dart';

///get textSpan by nodes
InlineSpan getBlockSpan(
    List<m.Node>? nodes, m.Node parentNode, TextStyle? parentStyle) {
  if (nodes == null || nodes.isEmpty) return TextSpan();
  return TextSpan(
    children: List.generate(
      nodes.length,
      (index) {
        bool shouldParseHtml = needParseHtml(parentNode);
        final node = nodes[index];
        if (node is m.Text)
          return buildTextSpan(node, parentStyle, shouldParseHtml);
        else if (node is m.Element) {
          if (node.tag == code) return getCodeSpan(node);
          if (node.tag == img) return getImageSpan(node);
          if (node.tag == video) return getVideoSpan(node);
          if (node.tag == a) return getLinkSpan(node);
          if (node.tag == input) return getInputSpan(node);
          if (node.tag == other) return getOtherWidgetSpan(node);
          return getBlockSpan(
              node.children, node, parentStyle!.merge(getTextStyle(node.tag)));
        }
        return TextSpan();
      },
    ),
  );
}

///get textSpan by one node
InlineSpan buildTextSpan(
    m.Text node, TextStyle? parentStyle, bool shouldParseHtml) {
  final nodes = shouldParseHtml ? parseHtml(node) : [];
  if (nodes.isEmpty) {
    return TextSpan(text: node.text, style: parentStyle);
  } else {
    return getBlockSpan(nodes as List<m.Node>?, node, parentStyle);
  }
}

//get textSpans by nodes
List<InlineSpan> buildSpans(m.Element? parentNode, TextStyle? parentStyle) {
  if (parentNode == null) return [];
  List<m.Node>? nodes = parentNode.children;
  if (nodes == null || nodes.isEmpty) return [];
  return List.generate(nodes.length, (index) {
    final node = nodes[index];
    if (node is m.Text) {
      bool shouldParseHtml = needParseHtml(parentNode);
      return buildTextSpan(node, parentStyle, shouldParseHtml);
    } else if (node is m.Element) {
      return getBlockSpan(node.children, node, parentStyle);
    } else {
      print('node: $node can\'t be parse');
      return TextSpan();
    }
  });
}
