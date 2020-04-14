import 'package:flutter/material.dart';
import '../config/style_config.dart';
import 'package:markdown/markdown.dart' as m;

import 'markdown_tags.dart';
import 'p.dart';

class Ol {
  Ol._internal();

  static Ol _instance;

  factory Ol() {
    _instance ??= Ol._internal();
    return _instance;
  }

  Widget getOlWidget(
    m.Element rootNode,
    int deep,
  ) {
    final children = rootNode?.children;
    if (children == null) return Container();
    return Column(
      children: List.generate(
        children.length,
        (index) {
          final node = children[index];
          if (node is m.Element) {
            if (node.tag == li)
              return _getLiWidget(
                node,
                deep,
                index,
              );
            if (node.tag == ol) return getOlWidget(node, deep + 1);
          }
          return Container();
        },
      ),
    );
  }

  Widget _getLiWidget(
    m.Element rootNode,
    int deep,
    int index,
  ) {
    final children = rootNode?.children;
    final List<m.Node> otherTagNodes = [];
    Widget olWidget;
    for (var node in children) {
      if (node is m.Element && node.tag == ol) {
        olWidget = getOlWidget(node, deep + 1);
      } else
        otherTagNodes.add(node);
    }
    final config = StyleConfig().olConfig;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: deep * (config?.leftSpacing ?? 10.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment:
                config?.crossAxisAlignment ?? CrossAxisAlignment.start,
            children: <Widget>[
              _getOlDot(deep, index),
              Expanded(
                child: P().getPWidget(otherTagNodes, rootNode,
                    textStyle: config?.textStyle ?? defaultPStyle,
                    crossAxisAlignment: WrapCrossAlignment.start),
              ),
            ],
          ),
        ),
        olWidget ?? Container(),
      ],
    );
  }

  Widget _getOlDot(int deep, int index) {
    final Widget configWidget =
        StyleConfig()?.olConfig?.indexWidget?.call(deep, index);

    return configWidget ??
        Container(
          margin: EdgeInsets.only(left: 5, right: 5),
          child: Text(
            '$index.',
          ),
        );
  }
}

class OlConfig {
  final TextStyle textStyle;
  final IndexWidget indexWidget;
  final double leftSpacing;
  final CrossAxisAlignment crossAxisAlignment;

  OlConfig(
      {this.textStyle,
      this.indexWidget,
      this.leftSpacing,
      this.crossAxisAlignment});
}

typedef Widget IndexWidget(int deep, int index);
