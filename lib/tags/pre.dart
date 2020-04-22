import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/arduino-light.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:highlight/highlight.dart' as hi;
import '../config/style_config.dart';

class Pre {
  Pre._internal();

  static Pre _instance;

  factory Pre() {
    _instance ??= Pre._internal();
    return _instance;
  }

  ///Tag:  pre
  Widget getPreWidget(m.Node node) {
    final preConfig = StyleConfig().preConfig;

    return Container(
      decoration: preConfig?.decoration ??
          BoxDecoration(
            color: defaultPreBackground,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
      margin: preConfig?.margin,
      padding: preConfig?.padding ?? const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HighlightView(
          node.textContent,
          language: preConfig?.language ?? 'java',
          theme: preConfig?.theme ?? defaultHighLightCodeTheme,
          textStyle: preConfig?.textStyle ?? TextStyle(fontSize: 14),
          tabSize: preConfig?.tabSize ?? 8,
        ),
      ),
    );
  }
}

class PreConfig {
  final EdgeInsetsGeometry padding;
  final Decoration decoration;
  final EdgeInsetsGeometry margin;
  final TextStyle textStyle;

  ///see package:flutter_highlight/themes/
  final Map<String, TextStyle> theme;
  final String language;
  final int tabSize;

  PreConfig(
      {this.padding,
      this.decoration,
      this.margin,
      this.textStyle,
      this.theme,
      this.language,
      this.tabSize});
}

class HighlightView extends StatelessWidget {
  /// The original code to be highlighted
  final String source;

  final String language;

  /// Highlight theme
  ///
  /// [All available themes](https://github.com/pd4d10/highlight/blob/master/flutter_highlight/lib/themes)
  final Map<String, TextStyle> theme;

  /// Text styles
  ///
  /// Specify text styles such as font family and font size
  final TextStyle textStyle;

  HighlightView(
    String input, {
    this.language,
    this.theme = const {},
    this.textStyle,
    int tabSize = 8, // TODO: https://github.com/flutter/flutter/issues/50087
  }) : source = input.replaceAll('\t', ' ' * tabSize);

  List<TextSpan> _convert(List<hi.Node> nodes) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    List<List<TextSpan>> stack = [];

    _traverse(hi.Node node) {
      if (node.value != null) {
        currentSpans.add(node.className == null
            ? TextSpan(text: node.value)
            : TextSpan(text: node.value, style: theme[node.className]));
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans.add(TextSpan(children: tmp, style: theme[node.className]));
        stack.add(currentSpans);
        currentSpans = tmp;

        node.children.forEach((n) {
          _traverse(n);
          if (n == node.children.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        });
      }
    }

    for (var node in nodes) {
      _traverse(node);
    }
    return spans;
  }

  static const _rootKey = 'root';
  static const _defaultFontColor = Color(0xff000000);

  @override
  Widget build(BuildContext context) {
    var _textStyle = TextStyle(
      color: theme[_rootKey]?.color ?? _defaultFontColor,
    );
    if (textStyle != null) {
      _textStyle = _textStyle.merge(textStyle);
    }

    return SelectableText.rich(TextSpan(
      style: _textStyle,
      children: _convert(hi.highlight.parse(source, language: language).nodes),
    ));
  }
}
