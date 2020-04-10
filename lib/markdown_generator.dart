import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'config/style_config.dart';
import 'config/widget_config.dart';
import 'markdown_helper.dart';

class MarkdownGenerator {
  MarkdownGenerator({
    @required String data,
    WidgetConfig widgetConfig,
    StyleConfig styleConfig,
    EdgeInsetsGeometry childMargin,
  }) {
    final m.Document document = m.Document(
        extensionSet: m.ExtensionSet.gitHubFlavored,
        inlineSyntaxes: [TaskListSyntax()]
    );
    final List<String> lines = data.split(RegExp(r'\r?\n'));
    List<m.Node> nodes = document.parseLines(lines);
    _tocList = LinkedHashMap();
    _helper = MarkdownHelper(
      wConfig: widgetConfig,
    );
    _widgets = [];
    nodes.forEach((element) {
      _widgets.add(_generatorWidget(element, childMargin));
    });
  }

  List<Widget> _widgets;
  LinkedHashMap<int, Toc> _tocList;
  MarkdownHelper _helper;

  List<Widget> get widgets => _widgets;
  LinkedHashMap<int, Toc> get tocList => _tocList;

  Widget _generatorWidget(m.Node node, EdgeInsetsGeometry childMargin) {
    if(node is m.Text) return _helper.getPWidget(m.Element(p, [node]));
    final tag = (node as m.Element).tag;
    Widget result;
    switch (tag) {
      case h1:
        _tocList[_widgets.length] = Toc(node.textContent, tag, _widgets.length, _tocList.length, 0);
        result = _helper.getTitleWidget(node, h1);
        break;
      case h2:
        _tocList[_widgets.length] = Toc(node.textContent, tag, _widgets.length, _tocList.length, 1);
        result = _helper.getTitleWidget(node, h2);
        break;
      case h3:
        _tocList[_widgets.length] = Toc(node.textContent, tag, _widgets.length, _tocList.length, 2);
        result = _helper.getTitleWidget(node, h3);
        break;
      case h4:
        _tocList[_widgets.length] = Toc(node.textContent, tag, _widgets.length, _tocList.length, 3);
        result = _helper.getTitleWidget(node, h4);
        break;
      case h5:
        _tocList[_widgets.length] = Toc(node.textContent, tag, _widgets.length, _tocList.length, 4);
        result = _helper.getTitleWidget(node, h5);
        break;
      case h6:
        _tocList[_widgets.length] = Toc(node.textContent, tag, _widgets.length, _tocList.length, 5);
        result = _helper.getTitleWidget(node, h6);
        break;
      case p:
        result = _helper.getPWidget(node);
        break;
      case pre:
        result = _helper.getPreWidget(node);
        break;
      case ul:
        result = _helper.getUlWidget(node, 0);
        break;
      case ol:
        result = _helper.getOlWidget(node, 0);
        break;
      case hr:
        result = _helper.getHrWidget(node);
        break;
      case table:
        result = _helper.getTableWidget(node);
        break;
      case blockquote:
        result = _helper.getBlockQuote(node);
        break;
    }
    if(result == null) print('tag:$tag not catched!');
    return Container(
      child: result ?? Container(),
      margin: childMargin ?? EdgeInsets.only(top: 5, bottom: 5),
    );
  }
}

///Thanks for https://github.com/flutter/flutter_markdown/blob/4cc79569f6c0f150fc4e9496f594d1bfb3a3ff54/lib/src/widget.dart
class TaskListSyntax extends m.InlineSyntax {
  static final String _pattern = r'^ *\[([ xX])\] +';

  TaskListSyntax() : super(_pattern);

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    m.Element el = m.Element.withTag('input');
    el.attributes['type'] = 'checkbox';
    el.attributes['disabled'] = 'true';
    el.attributes['checked'] = '${match[1].trim().isNotEmpty}';
    parser.addNode(el);
    return true;
  }
}

class Toc{
  final String name;
  final String tag;
  final int tagLevel;
  final int index;
  final int selfIndex;

  Toc(this.name, this.tag, this.index, this.selfIndex, this.tagLevel);


  @override
  String toString() {
    return 'Toc{name: $name, tag: $tag, tagLevel: $tagLevel, index: $index, selfIndex: $selfIndex}';
  }

  @override
  bool operator ==(Object other) {
    if(other is Toc){
      return other.name == name && other.index == index && other.tag == tag && other.selfIndex == selfIndex && other.tagLevel == tagLevel;
    } else return false;
  }

  @override
  int get hashCode => super.hashCode;
}



