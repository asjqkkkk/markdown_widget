import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:runtime_client/particle.dart';
import 'package:runtime_flutter_code_highlighter/runtime_flutter_code_highlighter.dart';

import '../../../state/state.dart';

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
      final languageValue = (element.children?.first as m.Element).attributes['class']!;
      language = languageValue.split('-').last;
    } catch (e) {
      language = null;
      debugPrint('get language error:$e');
    }

    /// We're going to attempt to parse out an ID in the inbound code block to see if there's an Asset ID
    /// contained within.
    RegExp regex = RegExp(r'[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}');
    RegExpMatch? idMatch = regex.firstMatch(content);
    String? assetId = idMatch?.group(0);

    String text = content;
    if (assetId != null) {
      text = content.replaceAll(assetId, '');
    }

    final splitContents = text.trim().split(visitor.splitRegExp ?? WidgetVisitor.defaultSplitRegExp);
    if (splitContents.last.isEmpty) splitContents.removeLast();
    final codeBuilder = preConfig.builder;
    if (codeBuilder != null) {
      return WidgetSpan(child: codeBuilder.call(text, language ?? '', assetId));
    }

    TextSpan highlighted;

    /// Light & Dark Mode Caches for highlighting
    if (ParticleAesthetics().darkMode) {
      TextSpan? cached = MarkdownRenderingState().darkThemeCache[text];
      if (cached != null) {
        highlighted = cached;
      } else {
        highlighted = RuntimeFlutterCodeHighlighter.highlightedWidgetTree(
          text,
          RuntimeCodeHighlighterLanguages.fromExtension(language ?? 'txt').classification(),
          preConfig.theme.name,
          preConfig.textStyle,
        );
        MarkdownRenderingState().darkThemeCache[text] = highlighted;
      }
    } else {
      TextSpan? cached = MarkdownRenderingState().lightThemeCache[text];
      if (cached != null) {
        highlighted = cached;
      } else {
        highlighted = RuntimeFlutterCodeHighlighter.highlightedWidgetTree(
          text,
          RuntimeCodeHighlighterLanguages.fromExtension(language ?? 'txt').classification(),
          preConfig.theme.name,
          preConfig.textStyle,
        );
        MarkdownRenderingState().lightThemeCache[text] = highlighted;
      }
    }

    ScrollController controller = ScrollController();

    final widget = Container(
      decoration: preConfig.decoration,
      margin: preConfig.margin,
      padding: preConfig.padding,
      width: double.infinity,
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thickness: WidgetStatePropertyAll(8),
          interactive: true,
        ),
        child: Scrollbar(
          controller: controller,
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            physics: ClampingScrollPhysics(),
            child: Text.rich(highlighted),
          ),
        ),
      ),
    );

    return WidgetSpan(child: preConfig.wrapper?.call(widget, text, language ?? '', assetId) ?? widget);
  }

  @override
  TextStyle get style => preConfig.textStyle.merge(parentStyle);
}

///transform code to highlight code
// List<InlineSpan> highLightSpans(
//   String input, {
//   String? language,
//   bool autoDetectionLanguage = false,
//   Map<String, TextStyle> theme = const {},
//   TextStyle? textStyle,
//   TextStyle? styleNotMatched,
//   int tabSize = 8,
// }) {
//   return convertHiNodes(
//       hi.highlight
//           .parse(input.trimRight(),
//               language: autoDetectionLanguage ? null : language, autoDetection: autoDetectionLanguage)
//           .nodes!,
//       theme,
//       textStyle,
//       styleNotMatched);
// }
//
// List<TextSpan> convertHiNodes(
//   List<hi.Node> nodes,
//   Map<String, TextStyle> theme,
//   TextStyle? style,
//   TextStyle? styleNotMatched,
// ) {
//   List<TextSpan> spans = [];
//   var currentSpans = spans;
//   List<List<TextSpan>> stack = [];
//
//   void traverse(hi.Node node, TextStyle? parentStyle) {
//     final nodeStyle = parentStyle ?? theme[node.className ?? ''];
//     final finallyStyle = (nodeStyle ?? styleNotMatched)?.merge(style);
//     if (node.value != null) {
//       currentSpans.add(node.className == null
//           ? TextSpan(text: node.value, style: finallyStyle)
//           : TextSpan(text: node.value, style: finallyStyle));
//     } else if (node.children != null) {
//       List<TextSpan> tmp = [];
//       currentSpans.add(TextSpan(children: tmp, style: finallyStyle));
//       stack.add(currentSpans);
//       currentSpans = tmp;
//
//       for (var n in node.children!) {
//         traverse(n, nodeStyle);
//         if (n == node.children!.last) {
//           currentSpans = stack.isEmpty ? spans : stack.removeLast();
//         }
//       }
//     }
//   }
//
//   for (var node in nodes) {
//     traverse(node, null);
//   }
//   return spans;
// }

///config class for pre
class PreConfig implements LeafConfig {
  final EdgeInsetsGeometry padding;
  final Decoration decoration;
  final EdgeInsetsGeometry margin;
  final TextStyle textStyle;

  /// the [styleNotMatched] is used to set a default TextStyle for code that does not match any theme.
  final TextStyle? styleNotMatched;
  final CodeWrapper? wrapper;
  final CodeBuilder? builder;

  ///see package:flutter_highlight/themes/
  final RuntimeCodeHighlighterThemes theme;
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
    this.theme = RuntimeCodeHighlighterThemes.ONE_HALF_DARK,
    this.language = 'dart',
    this.wrapper,
    this.builder,
  }) : assert(builder == null || wrapper == null);

  static PreConfig get darkConfig => const PreConfig(
        decoration: BoxDecoration(
          color: Color(0xff555555),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        theme: RuntimeCodeHighlighterThemes.ONE_HALF_DARK,
      );

  ///copy by other params
  PreConfig copy({
    EdgeInsetsGeometry? padding,
    Decoration? decoration,
    EdgeInsetsGeometry? margin,
    TextStyle? textStyle,
    TextStyle? styleNotMatched,
    CodeWrapper? wrapper,
    RuntimeCodeHighlighterThemes? theme,
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

typedef CodeWrapper = Widget Function(Widget child, String code, String language, [String? asset]);

typedef CodeBuilder = Widget Function(String code, String language, [String? asset]);
