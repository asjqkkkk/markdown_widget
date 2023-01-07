import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:path/path.dart' as p;

void main() {
  test('test widget_visitor', () {
    final list = getTestJsonList();
    final config = MarkdownGeneratorConfig();
    for (var i = 0; i < list.length; ++i) {
      _checkWithIndex(i);
      _checkWithIndex(i,
          config: MarkdownConfig.darkConfig, generatorConfig: config);
    }
  });

  test('input tag', () {
    transformMarkdown('''- [ ] I'm input
    - [x] I' input too''');
  });

  test('table tag', () {
    transformMarkdown('''| align left | centered | align right |
| :-- | :-: | --: |
| a | b | c | ''');
  });

  test('getNodeByElement', () {
    final visitor = WidgetVisitor();
    visitor.getNodeByElement(
        m.Element("aaa", []), MarkdownConfig.defaultConfig);
  });
}

List<Widget> testMarkdownGenerator(
  String markdown, {
  MarkdownConfig? config,
  MarkdownGeneratorConfig? generatorConfig,
}) {
  final markdownGenerator = MarkdownGenerator(
    config: config,
    inlineSyntaxes: generatorConfig?.inlineSyntaxList ?? [],
    blockSyntaxes: generatorConfig?.blockSyntaxList ?? [],
    generators: generatorConfig?.generators ?? [],
    onNodeAccepted: generatorConfig?.onNodeAccepted,
    textGenerator: generatorConfig?.textGenerator,
  );
  return markdownGenerator.buildWidgets(markdown, onTocList: (list) {});
}

List<SpanNode> transformMarkdown(String markdown, {MarkdownConfig? config}) {
  final m.Document document = m.Document(
      extensionSet: m.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
      inlineSyntaxes: []);
  final lines = markdown.replaceAll('\r\n', '\n').split('\n');
  final nodes = document.parseLines(lines);
  List<HeadingNode> headings = [];
  final visitor = WidgetVisitor(
      onNodeAccepted: (node, index) {
        if (node is HeadingNode) {
          headings.add(node);
        }
      },
      config: config);
  return visitor.visit(nodes);
}

void _checkWithIndex(int index,
    {MarkdownConfig? config, MarkdownGeneratorConfig? generatorConfig}) {
  final list = getTestJsonList();
  assert(index >= 0 && index < list.length);
  String current = list[index]['markdown'];
  testMarkdownGenerator(current,
      config: config, generatorConfig: generatorConfig);
}

List<dynamic> getTestJsonList() {
  if (_mdList != null) return _mdList;
  final current = Directory.current;
  final jsonPath = p.join(current.path, 'test', 'test_markdowns', 'test.json');
  File jsonFile = File(jsonPath);
  final content = jsonFile.readAsStringSync();
  final json = jsonDecode(content);
  _mdList = json;
  return _mdList;
}

dynamic _mdList;
