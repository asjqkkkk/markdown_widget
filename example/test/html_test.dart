import 'package:example/markdown_custom/custom_node.dart';
import 'package:flutter/src/painting/inline_span.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;


class DivNode extends ElementNode{

  final Map<String, String> attribute;

  DivNode(this.attribute);

  @override
  InlineSpan build() => childrenSpan;
}

SpanNodeGeneratorWithTag divGeneratorWithTag = SpanNodeGeneratorWithTag(
    tag: 'div',
    generator: (e, config, visitor) =>
        DivNode(e.attributes));

final source = '''# Topic: User Data Not Found 
<div style="display:inline-block;background-color:red;border-radius: 50%; color:white; padding:5px;float:right;">
  Error code: e209
</div>''';

void main(){
  test("test for html with generator", (){
    final generator = MarkdownGenerator(
        textGenerator: (node, config, visitor) =>
            CustomTextNode(node.textContent, config, visitor), generators: [
      divGeneratorWithTag
    ]);
    final widgets = generator.buildWidgets(source);
    print(widgets);
  });

  test('test for html with visitor', (){
    final m.Document document = m.Document(
      extensionSet: m.ExtensionSet.gitHubFlavored,
      encodeHtml: false
    );
    final List<String> lines = source.split(RegExp(r'(\r?\n)|(\r?\t)|(\r)'));
    final List<m.Node> nodes = document.parseLines(lines);
    final visitor = WidgetVisitor(
        textGenerator: (node, config, visitor) =>
            CustomTextNode(node.textContent, config, visitor),
      generators: [divGeneratorWithTag]
        );
    final spans = visitor.visit(nodes);
    print(spans);
  });
}