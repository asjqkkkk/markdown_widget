import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/configs.dart';
import '../../span_node.dart';

///Tag: [MarkdownTag.a]
///
///Link reference definitions, A link reference definition consists of a link label
///link will always be wrapped by other tags, such as [MarkdownTag.p]

class LinkNode extends ElementNode {
  final Map<String, String> attributes;
  final LinkConfig linkConfig;

  LinkNode(this.attributes, this.linkConfig);

  @override
  InlineSpan build() {
    final url = attributes['href'] ?? '';
    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        _onLinkTap(linkConfig, url);
      };
    final spans =
        List.generate(children.length, (index) => children[index].build());
    final List<InlineSpan> formatSpans = [];
    _formatChildren(spans, formatSpans);
    final List<InlineSpan> result = [];
    String text = '';
    for (final span in formatSpans) {
      if (span is WidgetSpan) {
        _addTextSpan(text, result, recognizer);
        _addWidgetSpan(result, span, url);
        text = '';
      } else if (span is TextSpan) {
        text += span.text ?? '';
      }
    }
    if (text.isNotEmpty) _addTextSpan(text, result, recognizer);
    return TextSpan(children: result);
  }

  ///if text is not empty, add textSpan to [result]
  void _addTextSpan(
      String text, List<InlineSpan> result, TapGestureRecognizer recognizer) {
    if (text.isNotEmpty)
      result.add(TextSpan(text: text, style: style, recognizer: recognizer));
  }

  ///add widgetSpan to [result]
  void _addWidgetSpan(List<InlineSpan> result, WidgetSpan span, String url) {
    result.add(WidgetSpan(
        child: InkWell(
          child: span.child,
          onTap: () => _onLinkTap(linkConfig, url),
        ),
        alignment: span.alignment,
        baseline: span.baseline,
        style: span.style?.merge(style) ?? style));
  }

  ///visit children, and put them in the [result]
  void _formatChildren(List<InlineSpan> spans, List<InlineSpan> result) {
    for (final span in spans) {
      if (span is! TextSpan) {
        result.add(span);
        return;
      }
      if (span.children == null || (span.children?.isEmpty ?? true)) {
        result.add(span);
        return;
      }
      _formatChildren(span.children!, result);
    }
  }

  void _onLinkTap(LinkConfig linkConfig, String url) {
    if (linkConfig.onTap != null) {
      linkConfig.onTap?.call(url);
    } else {
      launchUrl(Uri.parse(url));
    }
  }

  @override
  TextStyle get style =>
      parentStyle?.merge(linkConfig.style) ?? linkConfig.style;
}

///config class for link, tag: a
class LinkConfig implements LeafConfig {
  final TextStyle style;
  final ValueCallback<String>? onTap;

  const LinkConfig(
      {this.style = const TextStyle(
          color: Color(0xff0969da), decoration: TextDecoration.underline),
      this.onTap});

  @nonVirtual
  @override
  String get tag => MarkdownTag.a.name;
}
