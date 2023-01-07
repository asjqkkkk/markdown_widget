import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:highlight/highlight.dart' as hi;

import '../../../config/configs.dart';
import '../../span_node.dart';

///Tag: [MarkdownTag.pre]
///
///An indented code block is composed of one or more indented chunks separated by blank lines
///A code fence is a sequence of at least three consecutive backtick characters (`) or tildes (~)
class CodeBlockNode extends ElementNode {
  CodeBlockNode(this.content, this.preConfig);

  final String content;
  final PreConfig preConfig;

  @override
  InlineSpan build() {
    return WidgetSpan(
      child: Builder(builder: (context) {
        return Container(
          decoration: preConfig.decoration,
          margin: preConfig.margin,
          padding: preConfig.padding,
          width: double.infinity,
          child: Text.rich(TextSpan(
            children: highLightSpans(content,
                language: preConfig.language,
                theme: preConfig.theme,
                textStyle: style),
          )),
        );
      }),
    );
  }

  @override
  TextStyle get style => preConfig.textStyle.merge(parentStyle);
}

///transform code to highlight code
List<InlineSpan> highLightSpans(
  String input, {
  String? language,
  bool autoDetectionLanguage = false,
  Map<String, TextStyle> theme = const {},
  TextStyle? textStyle,
  int tabSize = 8,
}) {
  return convertHiNodes(
      hi.highlight
          .parse(input.trimRight(),
              language: autoDetectionLanguage ? null : language,
              autoDetection: autoDetectionLanguage)
          .nodes!,
      theme,
      textStyle);
}

List<TextSpan> convertHiNodes(
    List<hi.Node> nodes, Map<String, TextStyle> theme, TextStyle? style) {
  List<TextSpan> spans = [];
  var currentSpans = spans;
  List<List<TextSpan>> stack = [];

  _traverse(hi.Node node) {
    if (node.value != null) {
      currentSpans.add(node.className == null
          ? TextSpan(text: node.value, style: style)
          : TextSpan(
              text: node.value, style: theme[node.className!]?.merge(style)));
    } else if (node.children != null) {
      List<TextSpan> tmp = [];
      currentSpans.add(
          TextSpan(children: tmp, style: theme[node.className!]?.merge(style)));
      stack.add(currentSpans);
      currentSpans = tmp;

      node.children!.forEach((n) {
        _traverse(n);
        if (n == node.children!.last) {
          currentSpans = stack.isEmpty ? spans : stack.removeLast();
        }
      });
    }
  }

  for (var node in nodes) {
    _traverse(node);
  }
  return spans;
}

///config class for pre
class PreConfig implements LeafConfig {
  final EdgeInsetsGeometry padding;
  final Decoration decoration;
  final EdgeInsetsGeometry margin;
  final TextStyle textStyle;

  ///see package:flutter_highlight/themes/
  final Map<String, TextStyle> theme;
  final String language;

  const PreConfig({
    this.padding = const EdgeInsets.all(16.0),
    this.decoration = const BoxDecoration(
      color: Color(0xffeff1f3),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.margin = const EdgeInsets.all(8.0),
    this.textStyle = const TextStyle(fontSize: 16),
    this.theme = a11yLightTheme,
    this.language = 'dart',
  });

  static PreConfig get darkConfig => PreConfig(
      decoration: const BoxDecoration(
        color: Color(0xff555555),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      theme: a11yDarkTheme);

  @nonVirtual
  @override
  String get tag => MarkdownTag.pre.name;
}
