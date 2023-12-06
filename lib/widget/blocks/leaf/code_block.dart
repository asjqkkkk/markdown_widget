import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:highlight/highlight.dart' as hi;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown_widget/widget/selection_transformer.dart';

///Tag: [MarkdownTag.pre]
///
///An indented code block is composed of one or more indented chunks separated by blank lines
///A code fence is a sequence of at least three consecutive backtick characters (`) or tildes (~)
class CodeBlockNode extends ElementNode {
  CodeBlockNode(this.content, this.preConfig);

  final String content;
  final PreConfig preConfig;

  @override
  InlineSpan build() {
    final splitContents = content.trim().split(RegExp(r'(\r?\n)|(\r?\t)|(\r)'));
    if (splitContents.last.isEmpty) splitContents.removeLast();
    final widget = Container(
      decoration: preConfig.decoration,
      margin: preConfig.margin,
      padding: preConfig.padding,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectionTransformer.separated(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(splitContents.length, (index) {
              final currentContent = splitContents[index];
              return ProxyRichText(TextSpan(
                children: highLightSpans(
                  currentContent,
                  language: preConfig.language,
                  theme: preConfig.theme,
                  textStyle: style,
                  styleNotMatched: preConfig.styleNotMatched,
                ),
              ));
            }),
          ),
        ),
      ),
    );
    return WidgetSpan(
        child: preConfig.wrapper?.call(widget, content) ?? widget);
  }

  @override
  TextStyle get style => preConfig.textStyle.merge(parentStyle);
}

///transform code to highlight code
List<InlineSpan> highLightSpans(
  String input, {
  String? language,
  bool autoDetectionLanguage = false,
  Map<String, TextStyle> theme = const {},
  TextStyle? textStyle,
  TextStyle? styleNotMatched,
  int tabSize = 8,
}) {
  return convertHiNodes(
      hi.highlight
          .parse(input.trimRight(),
              language: autoDetectionLanguage ? null : language,
              autoDetection: autoDetectionLanguage)
          .nodes!,
      theme,
      textStyle,
      styleNotMatched);
}

List<TextSpan> convertHiNodes(
  List<hi.Node> nodes,
  Map<String, TextStyle> theme,
  TextStyle? style,
  TextStyle? styleNotMatched,
) {
  List<TextSpan> spans = [];
  var currentSpans = spans;
  List<List<TextSpan>> stack = [];

  _traverse(hi.Node node, TextStyle? parentStyle) {
    final nodeStyle = parentStyle ?? theme[node.className ?? ''];
    final finallyStyle = (nodeStyle ?? styleNotMatched)?.merge(style);
    if (node.value != null) {
      currentSpans.add(node.className == null
          ? TextSpan(text: node.value, style: finallyStyle)
          : TextSpan(text: node.value, style: finallyStyle));
    } else if (node.children != null) {
      List<TextSpan> tmp = [];
      currentSpans.add(TextSpan(children: tmp, style: finallyStyle));
      stack.add(currentSpans);
      currentSpans = tmp;

      node.children!.forEach((n) {
        _traverse(n, nodeStyle);
        if (n == node.children!.last) {
          currentSpans = stack.isEmpty ? spans : stack.removeLast();
        }
      });
    }
  }

  for (var node in nodes) {
    _traverse(node, null);
  }
  return spans;
}

///config class for pre
class PreConfig implements LeafConfig {
  final EdgeInsetsGeometry padding;
  final Decoration decoration;
  final EdgeInsetsGeometry margin;
  final TextStyle textStyle;

  /// the [styleNotMatched] is used to set a default TextStyle for code that does not match any theme.
  final TextStyle? styleNotMatched;
  final CodeWrapper? wrapper;

  ///see package:flutter_highlight/themes/
  final Map<String, TextStyle> theme;
  final String language;

  const PreConfig({
    this.padding = const EdgeInsets.all(16.0),
    this.decoration = const BoxDecoration(
      color: Color(0xffeff1f3),
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.textStyle = const TextStyle(fontSize: 16),
    this.styleNotMatched,
    this.theme = a11yLightTheme,
    this.language = 'dart',
    this.wrapper,
  });

  static PreConfig get darkConfig => PreConfig(
        decoration: const BoxDecoration(
          color: Color(0xff555555),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        theme: a11yDarkTheme,
      );

  ///copy by other params
  PreConfig copy({
    EdgeInsetsGeometry? padding,
    Decoration? decoration,
    EdgeInsetsGeometry? margin,
    TextStyle? textStyle,
    TextStyle? styleNotMatched,
    CodeWrapper? wrapper,
    Map<String, TextStyle>? theme,
    String? language,
  }) {
    return PreConfig(
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      margin: margin ?? this.margin,
      textStyle: textStyle ?? this.textStyle,
      styleNotMatched: styleNotMatched ?? this.styleNotMatched,
      wrapper: wrapper ?? this.wrapper,
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }

  @nonVirtual
  @override
  String get tag => MarkdownTag.pre.name;
}

typedef CodeWrapper = Widget Function(Widget child, String code);
