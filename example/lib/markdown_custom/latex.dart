import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_math_fork/flutter_math.dart';

SpanNodeGeneratorWithTag latexGeneratorWithTag = SpanNodeGeneratorWithTag(
    tag: _latexTag,
    generator: (e, config, visitor) =>
        LatexNode(e.attributes, e.textContent, config));

const _latexTag = 'latex';

class LatexNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  LatexNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    final content = attributes['content'] ?? '';
    final style = parentStyle ?? config.p.textStyle;
    if (content.isEmpty) return TextSpan(style: style, text: textContent);
    return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          content,
          mathStyle: MathStyle.display,
          textStyle: style,
          onErrorFallback: (error) {
            return Text(
              'parse error:$content',
              style: style.copyWith(color: Colors.red),
            );
          },
        ));
  }
}
