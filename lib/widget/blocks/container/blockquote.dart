import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../config/configs.dart';
import '../../span_node.dart';

///Tag: [MarkdownTag.blockquote]
///
/// A block quote marker, optionally preceded by up to three spaces of indentation
class BlockquoteNode extends ElementNode {
  final BlockquoteConfig config;

  BlockquoteNode(this.config);

  @override
  InlineSpan build() {
    return WidgetSpan(
        child: Container(
      decoration: BoxDecoration(
          border: Border(
        left: BorderSide(color: config.sideColor, width: config.sideWith),
      )),
      padding: EdgeInsets.only(left: config.sideSpace),
      margin: config.margin,
      child: Text.rich(childrenSpan),
    ));
  }

  @override
  TextStyle? get style => TextStyle(color: config.textColor).merge(parentStyle);
}

///config class for Block quotes, tag: blockquote
class BlockquoteConfig implements ContainerConfig {
  final Color sideColor;
  final Color textColor;
  final double sideWith;
  final double sideSpace;
  final EdgeInsets margin;

  const BlockquoteConfig(
      {this.sideColor = const Color(0xffd0d7de),
      this.textColor = const Color(0xff57606a),
      this.sideWith = 4.0,
      this.sideSpace = 16.0,
      this.margin = const EdgeInsets.symmetric(vertical: 16.0)});

  @nonVirtual
  @override
  String get tag => MarkdownTag.blockquote.name;
}
