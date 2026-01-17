import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:highlight/highlight.dart' as hi;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

///Tag: [MarkdownTag.pre]
///
///An indented code block is composed of one or more indented chunks separated by blank lines
///A code fence is a sequence of at least three consecutive backtick characters (`) or tildes (~)
class CodeBlockNode extends ElementNode {
  CodeBlockNode(this.element, this.preConfig, this.visitor);

  String get content => element.textContent;
  final PreConfig preConfig;
  final m.Element element;
  final WidgetVisitor visitor;

  @override
  InlineSpan build() {
    String? language = preConfig.language;
    try {
      final languageValue =
          (element.children?.first as m.Element).attributes['class'];
      if (languageValue != null) {
        language = languageValue.split('-').last;
      }
    } catch (e) {
      language = null;
      debugPrint('get language error:$e');
    }
    final splitContents = content
        .trim()
        .split(visitor.splitRegExp ?? WidgetVisitor.defaultSplitRegExp);
    if (splitContents.last.isEmpty) splitContents.removeLast();
    final codeBuilder = preConfig.builder;
    if (codeBuilder != null) {
      return WidgetSpan(child: codeBuilder.call(content, language ?? ''));
    }

    Widget codeContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(splitContents.length, (index) {
        final currentContent = splitContents[index];
        return ProxyRichText(
          TextSpan(
            children: highLightSpans(
              currentContent,
              language: language ?? preConfig.language,
              theme: preConfig.theme,
              textStyle: style,
              styleNotMatched: preConfig.styleNotMatched,
            ),
          ),
          richTextBuilder: preConfig.richTextBuilder ?? visitor.richTextBuilder,
        );
      }),
    );

    codeContent = preConfig.wrapCode
        ? codeContent
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: codeContent,
          );
    final contentWrapper = preConfig.contentWrapper;

    Widget widget;
    if (contentWrapper != null) {
      widget = contentWrapper.call(codeContent, content, language ?? '');
    } else {
      widget = Container(
        decoration: preConfig.decoration,
        margin: preConfig.margin,
        padding: preConfig.padding,
        width: double.infinity,
        child: codeContent,
      );
    }

    return WidgetSpan(
        child:
            preConfig.wrapper?.call(widget, content, language ?? '') ?? widget);
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

  void traverse(hi.Node node, TextStyle? parentStyle) {
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

      for (var n in node.children!) {
        traverse(n, nodeStyle);
        if (n == node.children!.last) {
          currentSpans = stack.isEmpty ? spans : stack.removeLast();
        }
      }
    }
  }

  for (var node in nodes) {
    traverse(node, null);
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
  final CodeContentWrapper? contentWrapper;
  final CodeBuilder? builder;
  final RichTextBuilder? richTextBuilder;

  ///see package:flutter_highlight/themes/
  final Map<String, TextStyle> theme;
  final String language;

  ///Whether to wrap the code when it exceeds the width of the code block.
  ///If false (default), the code will be horizontally scrollable.
  ///If true, the code will wrap to fit the width.
  final bool wrapCode;

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
    this.contentWrapper,
    this.builder,
    this.richTextBuilder,
    this.wrapCode = false,
  }) : assert(
          (builder != null ? 1 : 0) +
                  (wrapper != null ? 1 : 0) +
                  (contentWrapper != null ? 1 : 0) <=
              1,
          'At most one of builder, wrapper, or contentWrapper can be non-null',
        );

  static PreConfig get darkConfig => const PreConfig(
        decoration: BoxDecoration(
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
    CodeContentWrapper? contentWrapper,
    CodeBuilder? builder,
    Map<String, TextStyle>? theme,
    String? language,
    RichTextBuilder? richTextBuilder,
    bool? wrapCode,
  }) {
    return PreConfig(
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      margin: margin ?? this.margin,
      textStyle: textStyle ?? this.textStyle,
      styleNotMatched: styleNotMatched ?? this.styleNotMatched,
      wrapper: wrapper ?? this.wrapper,
      contentWrapper: contentWrapper ?? this.contentWrapper,
      builder: builder ?? this.builder,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      richTextBuilder: richTextBuilder ?? this.richTextBuilder,
      wrapCode: wrapCode ?? this.wrapCode,
    );
  }

  @nonVirtual
  @override
  String get tag => MarkdownTag.pre.name;
}

/// used to wrap code block widget
typedef CodeWrapper = Widget Function(
  Widget codeBlock,
  String code,
  String language,
);

/// used to wrap code content widget
typedef CodeContentWrapper = Widget Function(
  Widget codeContent,
  String code,
  String language,
);

typedef CodeBuilder = Widget Function(String code, String language);
