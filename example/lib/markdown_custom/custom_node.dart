import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

import 'html_support.dart';

class CustomTextNode extends ElementNode {
  final String text;
  final MarkdownConfig config;
  final WidgetVisitor visitor;

  CustomTextNode(this.text, this.config, this.visitor);

  @override
  void onAccepted(SpanNode parent) {
    final textStyle = config.p.textStyle.merge(parentStyle);
    children.clear();
    if (!text.contains(htmlRep)) {
      accept(TextNode(text: text, style: textStyle));
      return;
    }
    final spans = parseHtml(
      m.Text(text),
      visitor:
          WidgetVisitor(config: visitor.config, generators: visitor.generators),
      parentStyle: parentStyle,
    );
    spans.forEach((element) {
      accept(element);
    });
  }
}
