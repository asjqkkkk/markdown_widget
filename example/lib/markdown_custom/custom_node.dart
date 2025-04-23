import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

import 'html_support.dart';

class CustomTextNode extends ElementNode {
  final String text;
  final MarkdownConfig config;
  final WidgetVisitor visitor;
  bool isTable = false;

  CustomTextNode(this.text, this.config, this.visitor);

  @override
  InlineSpan build() {
    if (isTable) {
      //deal complex table tag with html core widget
      return WidgetSpan(
        child: HtmlWidget(text),
      );
    } else {
      return super.build();
    }
  }

  @override
  void onAccepted(SpanNode parent) {
    final textStyle = config.p.textStyle.merge(parentStyle);
    children.clear();
    if (!text.contains(htmlRep)) {
      accept(TextNode(text: text, style: textStyle));
      return;
    }
    //Intercept as table tag
    if (text.contains(tableRep)) {
      isTable = true;
      accept(parent);
      return;
    }

    //The remaining ones are processed by the regular HTML processing.
    final spans = parseHtml(
      m.Text(text),
      visitor: WidgetVisitor(
        config: visitor.config,
        generators: visitor.generators,
        richTextBuilder: visitor.richTextBuilder,
      ),
      parentStyle: parentStyle,
    );
    spans.forEach((element) {
      isTable = false;
      accept(element);
    });
  }
}
