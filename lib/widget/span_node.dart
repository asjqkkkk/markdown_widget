import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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

  TextSpan get childrenSpan => TextSpan(
      children:
          List.generate(children.length, (index) => children[index].build()));
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
  InlineSpan build() => TextSpan(text: text, style: style?.merge(parentStyle));
}

///text node that supports word-level tap detection
class TappableTextNode extends SpanNode {
  final String text;
  final void Function(String)? onTapWord;
  final TextStyle? highlightStyle;
  final String? highlightedWord;

  TappableTextNode({
    this.text = '',
    TextStyle? style,
    this.onTapWord,
    this.highlightStyle,
    this.highlightedWord,
  }) {
    this.style = style ?? const TextStyle();
  }

  @override
  InlineSpan build() {
    if (onTapWord == null) {
      return TextSpan(text: text, style: style?.merge(parentStyle));
    }

    // Split text into words and spaces, preserving whitespace
    final parts = splitTextWithSpaces(text);
    final List<InlineSpan> spans = [];

    for (final part in parts) {
      if (part.trim().isEmpty) {
        // This is whitespace, add as non-tappable
        spans.add(TextSpan(text: part, style: style?.merge(parentStyle)));
      } else {
        // This is a word, make it tappable
        spans.add(_createTappableWordSpan(part));
      }
    }

    return TextSpan(children: spans);
  }

  /// Splits text into words and spaces, preserving all whitespace
  List<String> splitTextWithSpaces(String text) {
    final List<String> parts = [];
    final RegExp wordPattern = RegExp(r'\S+|\s+');
    final matches = wordPattern.allMatches(text);

    for (final match in matches) {
      parts.add(match.group(0)!);
    }

    return parts;
  }

  /// Creates a tappable TextSpan for a word
  TextSpan _createTappableWordSpan(String word) {
    // Check if this word should be highlighted
    final isHighlighted = highlightedWord != null &&
                         word.toLowerCase().trim() == highlightedWord!.toLowerCase().trim();

    // Apply highlight style if word is highlighted
    final baseStyle = style?.merge(parentStyle);
    final effectiveStyle = isHighlighted && highlightStyle != null
        ? baseStyle?.merge(highlightStyle!)
        : baseStyle;

    return TextSpan(
      text: word,
      style: effectiveStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () => onTapWord?.call(word),
    );
  }
}
