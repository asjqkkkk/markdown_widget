import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

///the basic node
abstract class SpanNode {
  InlineSpan build();

  SpanNode? _parent;

  TextStyle? style;

  TextStyle? get parentStyle => _parent?.style;

  SpanNode? get parent => _parent;

  ///use [_acceptParent] to accept a parent
  void _acceptParent(SpanNode node) {
    _parent = node;
    onAccepted(node);
  }

  ///when this node was accepted by it's parent, [onAccepted] will be triggered
  void onAccepted(SpanNode parent) {}
}

///this node will accept other SpanNode as children
abstract class ElementNode extends SpanNode {
  final List<SpanNode> children = [];

  ///use [accept] to add a child
  void accept(SpanNode? node) {
    if (node != null) children.add(node);
    node?._acceptParent(this);
  }

  @override
  InlineSpan build() => childrenSpan;

  TextSpan get childrenSpan => TextSpan(children: List.generate(children.length, (index) => children[index].build()));
}

///the default concrete node for ElementNode
class ConcreteElementNode extends ElementNode {
  final String tag;

  ConcreteElementNode({this.tag = '', TextStyle? style}) {
    this.style = style ?? const TextStyle();
  }

  @override
  InlineSpan build() => childrenSpan;
}

///text node only displays text
class TextNode extends SpanNode {
  final String text;

  TextNode({this.text = '', TextStyle? style}) {
    this.style = style ?? const TextStyle();
  }

  @override
  InlineSpan build() {
    List<InlineSpan> children = [];
    String? query = MarkdownRenderingState().query;

    if (query == null) {
      return TextSpan(
        text: text,
        style: style?.merge(parentStyle),
      );
    }

    text.splitMapJoin(
      RegExp(RegExp.escape(query), caseSensitive: false),
      onMatch: (Match match) {
        children.add(TextSpan(
          text: match.group(0),
          style: style?.merge(parentStyle).copyWith(color: Colors.black, backgroundColor: Colors.yellow),
        ));

        return '';
      },
      onNonMatch: (value) {
        children.add(TextSpan(
          text: value,
          style: style?.merge(parentStyle),
        ));

        return '';
      },
    );

    return TextSpan(
      children: children,
    );
  }
}
