import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

import 'html_support.dart';

class CustomTextNode extends SpanNode {
  final String text;
  final MarkdownConfig config;
  final WidgetVisitor visitor;

  CustomTextNode(this.text, this.config, this.visitor);

  @override
  InlineSpan build() {
    final textStyle = config.p.textStyle.merge(parentStyle);
    if (!text.contains(htmlRep)) return TextSpan(text: text, style: textStyle);

    ///Do not pass [TextNodeGenerator] again!!!
    final spans = parseHtml(
      m.Text(text),
      visitor:
          WidgetVisitor(config: visitor.config, generators: visitor.generators),
      parentStyle: textStyle,
    );
    final tempNode = _TempNode(textStyle);
    spans.forEach((e) {
      tempNode.accept(e);
    });
    return tempNode.build();
  }
}

class _TempNode extends ElementNode {
  final TextStyle? style;

  _TempNode(this.style);

  @override
  InlineSpan build() => childrenSpan;
}
