import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as m;

SpanNodeGeneratorWithTag latexGenerator = SpanNodeGeneratorWithTag(
    tag: _latexTag,
    generator: (e, config, visitor) =>
        LatexNode(e.attributes, e.textContent, config));

const _latexTag = 'latex';

class LatexSyntax extends m.InlineSyntax {
  LatexSyntax() : super(r'(\$\$[^\$]+?\$\$)|(\$[^\$]+?\$)');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final input = match.input;
    final matchValue = input.substring(match.start, match.end);
    String content = '';
    bool isInline = true;
    if (matchValue.startsWith('\$\$') && matchValue.endsWith('\$\$')) {
      content = matchValue.substring(2, matchValue.length - 2);
      isInline = false;
    } else if (matchValue.startsWith('\$') && matchValue.endsWith('\$')) {
      content = matchValue.substring(1, matchValue.length - 1);
    }
    if (content.isEmpty) {
      parser.addNode(m.Text(matchValue));
      return true;
    }
    m.Element el = m.Element.text(_latexTag, matchValue);
    el.attributes['content'] = content;
    el.attributes['isInline'] = '$isInline';
    parser.addNode(el);
    return true;
  }
}

class LatexNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  LatexNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    final content = attributes['content'] ?? '';
    final isInline = attributes['isInline'] == 'true';
    final style = parentStyle ?? config.p.textStyle;
    if (content.isEmpty) return TextSpan(style: style, text: textContent);
    final latex = Math.tex(
      content,
      mathStyle: MathStyle.text,
      textStyle: style,
      textScaleFactor: 1,
      onErrorFallback: (error) {
        return Text(
          '$textContent',
          style: style.copyWith(color: Colors.red),
        );
      },
    );
    return WidgetSpan(
        child: !isInline
            ? Container(
                width: double.infinity,
                child: Center(child: latex),
                margin: EdgeInsets.symmetric(vertical: 16),
              )
            : latex);
  }
}
