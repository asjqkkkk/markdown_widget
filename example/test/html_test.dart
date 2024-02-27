import 'package:example/markdown_custom/custom_node.dart';
import 'package:flutter/src/painting/inline_span.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

class DivNode extends ElementNode {
  final Map<String, String> attribute;

  DivNode(this.attribute);

  @override
  InlineSpan build() => childrenSpan;
}

SpanNodeGeneratorWithTag divGeneratorWithTag = SpanNodeGeneratorWithTag(
    tag: 'div', generator: (e, config, visitor) => DivNode(e.attributes));

final source = '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>I'm a title</title>
</head>
<body>

<h1>I'm a head</h1>
<p>I'm a paragraph</p>

</body>
</html>
''';

void main() {
  test("test for html with generator", () {
    final generator = MarkdownGenerator(
        textGenerator: (node, config, visitor) =>
            CustomTextNode(node.textContent, config, visitor),
        generators: [divGeneratorWithTag]);
    final widgets = generator.buildWidgets(source);
    print(widgets);
  });

  test('test for html with visitor', () {
    final m.Document document = m.Document(
        extensionSet: m.ExtensionSet.gitHubFlavored, encodeHtml: false);
    final List<String> lines = source.split(WidgetVisitor.defaultSplitRegExp);
    final List<m.Node> nodes = document.parseLines(lines);
    final visitor = WidgetVisitor(
        textGenerator: (node, config, visitor) =>
            CustomTextNode(node.textContent, config, visitor),
        generators: [divGeneratorWithTag]);
    final spans = visitor.visit(nodes);
    final buildSpans = spans.map((e) => e.build()).toList();
    print(buildSpans);
  });
}
