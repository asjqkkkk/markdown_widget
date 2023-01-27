import 'package:example/markdown_custom/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  final input = '''asdasd((xxxxx))asdasd  (yyyy)bb((zzzzz))''';

  test('test for (()) regexp', () {
    final m.Document document = m.Document(
        extensionSet: m.ExtensionSet.gitHubFlavored,
        encodeHtml: false,
        inlineSyntaxes: [DBSyntax()]);
    final List<String> lines = input.split(RegExp(r'(\r?\n)|(\r?\t)|(\r)'));
    final List<m.Node> nodes = document.parseLines(lines);
    print(nodes);
  });
}


