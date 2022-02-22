import 'package:flutter/material.dart';
import '../config/style_config.dart';
import 'package:markdown/markdown.dart' as m;

import 'markdown_tags.dart';

///the orderly list widget
class OLWidget extends StatelessWidget {
  final m.Element rootNode;
  final int deep;

  const OLWidget({
    Key? key,
    required this.rootNode,
    required this.deep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = rootNode.children;
    if (children == null) return Container();
    return Column(
      children: List.generate(
        children.length,
        (index) {
          final node = children[index];
          if (node is m.Element) {
            if (node.tag == li)
              return _LiWidget(rootNode: node, deep: deep, index: index);
            if (node.tag == ol) return OLWidget(rootNode: node, deep: deep + 1);
          }
          return Container();
        },
      ),
    );
  }
}

///the orderly or unOrderly list inside [ULWidget]
class _LiWidget extends StatelessWidget {
  final m.Element rootNode;
  final int deep;
  final int index;

  const _LiWidget({
    Key? key,
    required this.rootNode,
    required this.deep,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = rootNode.children ?? [];
    final List<m.Node> otherTagNodes = [];
    List<Widget> listChildren = [];
    for (var node in children) {
      if (node is m.Element && node.tag == ol) {
        final child = OLWidget(rootNode: node, deep: deep + 1);
        listChildren.add(child);
      } else if (node is m.Element && node.tag == ul) {
        final child = ULWidget(rootNode: node, deep: deep + 1);
        listChildren.add(child);
      } else
        otherTagNodes.add(node);
    }
    final config = StyleConfig().olConfig;
    final olChild = Container(
      margin: EdgeInsets.only(
        left: config?.textConfig?.textDirection == TextDirection.rtl
            ? 0.0
            : deep * (config?.leftSpacing ?? 10.0),
        right: config?.textConfig?.textDirection == TextDirection.rtl
            ? deep * (config?.leftSpacing ?? 10.0)
            : 0.0,
      ),
      child: Row(
        textDirection: config?.textConfig?.textDirection,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            config?.crossAxisAlignment ?? CrossAxisAlignment.start,
        children: <Widget>[
          _OlDot(deep: deep, index: index),
          Expanded(
            child: PWidget(
              children: otherTagNodes,
              parentNode: rootNode,
              textStyle: config?.textStyle ?? defaultPStyle,
              crossAxisAlignment: WrapCrossAlignment.start,
              textConfig: config?.textConfig,
              selectable: config?.selectable,
            ),
          ),
        ],
      ),
    );
    listChildren.insert(0, config?.olWrapper?.call(olChild) ?? olChild);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listChildren,
    );
  }
}

///the index widget of orderly list
class _OlDot extends StatelessWidget {
  final int deep;
  final int index;

  const _OlDot({
    Key? key,
    required this.deep,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = StyleConfig().olConfig;
    final Widget? configWidget =
        StyleConfig().olConfig?.indexWidget?.call(deep, index);

    return configWidget ??
        Container(
          margin: EdgeInsets.only(left: 5, right: 5),
          child: config?.textConfig?.textDirection == TextDirection.rtl
              ? Text('.${index + 1}')
              : Text('${index + 1}.'),
        );
  }
}

///Config class for orderly list
class OlConfig {
  final TextStyle? textStyle;
  final TextConfig? textConfig;
  final IndexWidget? indexWidget;
  final OlWrapper? olWrapper;
  final double? leftSpacing;
  final bool? selectable;
  final CrossAxisAlignment? crossAxisAlignment;

  OlConfig(
      {this.textStyle,
      this.textConfig,
      this.olWrapper,
      this.indexWidget,
      this.leftSpacing,
      this.selectable,
      this.crossAxisAlignment});
}

typedef Widget IndexWidget(int deep, int index);
typedef Widget OlWrapper(Widget child);
