import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown/src/charcode.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown_widget/widget/widget_visitor.dart';
import 'package:path/path.dart' as p;

void main() {
  test('test widget_visitor', () {
    final list = _getJsonList();
    for (var i = 0; i < list.length; ++i) {
      _checkWithIndex(i);
    }
    print(_tags);
  });

  test('test widget_visitor with specific text', (){
    _transformMarkdown('''<img width="250" height="250" src="https://user-images.githubusercontent.com/30992818/65225126-225fed00-daf7-11e9-9eb7-cd21e6b1cc95.png"/>''');
  });
}

void _transformMarkdown(String markdown){
  final m.Document document = m.Document(
      extensionSet: m.ExtensionSet.gitHubFlavored, encodeHtml: false, inlineSyntaxes: []);
  final lines = markdown.replaceAll('\r\n', '\n').split('\n');
  final nodes = document.parseLines(lines);
  List<HeadingNode> headings = [];
  final visitor = WidgetVisitor(onNodeAccepted: (node, index){
    if(node is HeadingNode){
      headings.add(node);
    }
  });
  final spans = visitor.visit(nodes);
  final buildSpans = spans.map((e) => e.build()).toList();
}

void _checkWithIndex(int index){
  final list = _getJsonList();
  assert(index >= 0 && index < list.length);
  String current = list[index]['markdown'];
  _transformMarkdown(current);
}

List<dynamic> _getJsonList(){
  if(_mdList != null) return _mdList;
  final current = Directory.current;
  final jsonPath =
  p.join(current.path, 'test', 'test_markdowns', 'test.json');
  File jsonFile = File(jsonPath);
  final content = jsonFile.readAsStringSync();
  final json = jsonDecode(content);
  _mdList = json;
  return _mdList;
}

dynamic _mdList;
final Set<String> _tags = {};
