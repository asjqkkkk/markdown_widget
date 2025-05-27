import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:runtime_client/foundation.dart';
import 'package:runtime_flutter_code_highlighter/runtime_flutter_code_highlighter.dart';

///Tag: [MarkdownTag.pre]
///
///An indented code block is composed of one or more indented chunks separated by blank lines
///A code fence is a sequence of at least three consecutive backtick characters (`) or tildes (~)
class CodeBlockNode extends ElementNode {
  CodeBlockNode(
    this.element,
    this.preConfig,
    this.visitor, {
    this.onSelectionChanged,
  });

  String get content => element.textContent;
  final PreConfig preConfig;
  final m.Element element;
  final WidgetVisitor visitor;
  final void Function(SelectedContent? content)? onSelectionChanged;

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

    // Use a StatefulWidget to properly manage the ScrollController lifecycle
    final widget = WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: preConfig.wrapper?.call(
            _CodeBlockWidget(
              text: text,
              language: language,
              preConfig: preConfig,
              onSelectionChanged: onSelectionChanged,
              highlight: (context, text, language) => highlight(context, text, language),
              style: style,
            ),
            text,
            language ?? '',
            assetId,
          ) ??
          _CodeBlockWidget(
            text: text,
            language: language,
            preConfig: preConfig,
            onSelectionChanged: onSelectionChanged,
            highlight: (context, text, language) => highlight(context, text, language),
            style: style,
          ),
    );

    return widget;
  }

  TextSpan highlight(BuildContext context, String text, String? language) {
    String? query = MarkdownRenderingState().query;

    return RuntimeFlutterCodeHighlighter.highlightedWidgetTree(
      text,
      RuntimeCodeHighlighterLanguages.fromExtension(language ?? 'txt').classification(),
      preConfig.theme.name,
      style,
      query != null ? MapEntry(query, TextStyle(color: Colors.black, backgroundColor: Colors.yellow)) : null,
    );
  }

  @override
  TextStyle get style => preConfig.textStyle.merge(parentStyle);
}

// Separate StatefulWidget to properly manage ScrollController lifecycle
class _CodeBlockWidget extends StatefulWidget {
  final String text;
  final String? language;
  final PreConfig preConfig;
  final void Function(SelectedContent? content)? onSelectionChanged;
  final TextSpan Function(BuildContext, String, String?) highlight;
  final TextStyle style;

  const _CodeBlockWidget({
    required this.text,
    required this.language,
    required this.preConfig,
    required this.highlight,
    required this.style,
    this.onSelectionChanged,
  });

  @override
  State<_CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<_CodeBlockWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      onSelectionChanged: widget.onSelectionChanged,
      child: Container(
        decoration: widget.preConfig.decoration,
        margin: widget.preConfig.margin,
        padding: widget.preConfig.padding,
        width: double.infinity,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            interactive: true,
            thumbVisibility: WidgetStatePropertyAll(true),
            thumbColor: WidgetStatePropertyAll(context.scaffoldColor),
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Builder(
                  builder: (context) {
                    return Text.rich(
                      widget.highlight(context, widget.text, widget.language),
                      style: widget.style,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
