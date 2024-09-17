import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/configs.dart';
import '../../state/state.dart';
import '../span_node.dart';

///Tag:  [MarkdownTag.code]
///the code textSpan
class CodeNode extends ElementNode {
  final CodeConfig codeConfig;
  final String text;

  CodeNode(this.text, this.codeConfig);

  @override
  InlineSpan build() {
    String? query = MarkdownRenderingState().query;

    if (query == null) {
      return TextSpan(
        text: text,
        style: style,
      );
    }

    List<InlineSpan> children = [];

    text.splitMapJoin(query, onMatch: (Match match) {
      children.add(TextSpan(
        text: match.group(0),
        style: style.merge(parentStyle).copyWith(color: Colors.black, backgroundColor: Colors.yellow),
      ));

      return '';
    }, onNonMatch: (value) {
      children.add(TextSpan(
        text: value,
        style: style.merge(parentStyle),
      ));

      return '';
    });

    return TextSpan(
      children: children,
    );
  }

  @override
  TextStyle get style => codeConfig.style.merge(parentStyle);
}

///config class for code, tag: code
class CodeConfig implements InlineConfig {
  final TextStyle style;

  const CodeConfig({this.style = const TextStyle(backgroundColor: Color(0xCCeff1f3))});

  static CodeConfig get darkConfig => CodeConfig(style: const TextStyle(backgroundColor: Color(0xCC555555)));

  @nonVirtual
  @override
  String get tag => MarkdownTag.code.name;
}
