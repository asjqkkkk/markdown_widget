import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../config/configs.dart';
import '../../span_node.dart';
import '../../widget_visitor.dart';
import '../leaf/paragraph.dart';

///Tag: [MarkdownTag.blockquote]
///
/// A block quote marker, optionally preceded by up to three spaces of indentation
class BlockquoteNode extends ElementNode {
  final BlockquoteConfig config;
  final WidgetVisitor visitor;

  BlockquoteNode(this.config, this.visitor);

  @override
  InlineSpan build() {
    final List<Widget> widgets = [];
    for (int i = 0; i < children.length; i++) {
      final span = children[i];
      final textSpan = span.build();
      final richText =
          visitor.richTextBuilder?.call(textSpan) ?? Text.rich(textSpan);
      final padding = span is ParagraphNode &&
              i + 1 < children.length &&
              children[i + 1] is ParagraphNode
          ? const EdgeInsets.only(bottom: 16)
          : null;
      widgets.add(padding == null
          ? richText
          : Padding(padding: padding, child: richText));
    }

    return WidgetSpan(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: config.sideColor, width: config.sideWith),
          ),
        ),
        padding: config.padding,
        margin: config.margin,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widgets.length,
          itemBuilder: (context, index) => widgets[index],
        ),
      ),
    );
  }

  @override
  TextStyle? get style => TextStyle(color: config.textColor).merge(parentStyle);
}

///config class for Block quotes, tag: blockquote
class BlockquoteConfig implements ContainerConfig {
  final Color sideColor;
  final Color textColor;
  final double sideWith;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const BlockquoteConfig({
    this.sideColor = const Color(0xffd0d7de),
    this.textColor = const Color(0xff57606a),
    this.sideWith = 4.0,
    this.padding = const EdgeInsets.fromLTRB(16, 2, 0, 2),
    this.margin = const EdgeInsets.fromLTRB(0, 8, 0, 8),
  });

  static BlockquoteConfig get darkConfig =>
      BlockquoteConfig(textColor: const Color(0xffd0d7de));

  @nonVirtual
  @override
  String get tag => MarkdownTag.blockquote.name;
}
