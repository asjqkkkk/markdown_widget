import 'dart:io';
import 'package:markdown_widget/markdown_generator.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as h;
import 'package:html/parser.dart';

void printNode(m.Node node, int deep) {
  if (node == null) return;
  if (node is m.Text) {
    final text = node.text;
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

    if (text.contains(exp)) {
      h.Document document = parse(text);
      print('GET:${document.nodes.length}');
      document.nodes.forEach((element) {
        htmlPrintNode(element, 0);
      });
    }
    print('${'  ' * deep}Text:${node.text}');
  } else if (node is m.Element) {
    print('${'  ' * deep}Tag:${node.tag}   attr:${node.attributes}');
    if (node.children == null) return;
    node.children.forEach((n) {
      printNode(n, deep + 1);
    });
  }
}

void htmlPrintNode(h.Node node, int deep) {
  if (node == null) return;
  if (node is h.Text) {
    print('${'  ' * deep}h.Text:${node.text}');
  } else if (node is h.Element) {
    print('${'  ' * deep}h.Tag:${node.localName}   h.attr:${node.attributes}');
    if (node.nodes == null || node.nodes.isEmpty) return;
    node.nodes.forEach((n) {
      htmlPrintNode(n, deep + 1);
    });
  } else
    print('I am not:$node');
}

void main() {
  test('test for markdown', () {
    final current = Directory.current;
//    final markdownPath = p.join(current.path,'demo_en.md');
    final markdownPath = current.path + '/demo_en.md';
    File mdFile = File(markdownPath);
    if (!mdFile.existsSync()) return;
    final content = mdFile.readAsStringSync();

    final m.Document document = m.Document(
        extensionSet: m.ExtensionSet.gitHubFlavored,
        inlineSyntaxes: [
          TaskListSyntax(),
        ]);

    final List<String> lines = content.split(RegExp(r'\r?\n'));

    final nodes = document.parseLines(lines);
    nodes.forEach((node) {
      if (node is m.Element) {
        printNode(node, 0);
      } else
        printNode(node, 0);
    });
  });
}
