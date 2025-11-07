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

  String get _url => attributes['href'] ?? '';

  @override
  InlineSpan build() {
    return TextSpan(children: [
      for (final child in children)
        _toLinkInlineSpan(
          child.build(),
          () => _onLinkTap(linkConfig, _url),
        ),
      if (children.isNotEmpty)
        // FIXME: this is a workaround, maybe need fixed by flutter framework.
        // add a space to avoid the space area of line end can be tapped.
        TextSpan(text: ' '),
    ]);
  }

  void _onLinkTap(LinkConfig linkConfig, String url) {
    if (linkConfig.onTap != null) {
      linkConfig.onTap?.call(url);
    } else {
      launchUrl(Uri.parse(url));
    }
  }

  @override
  TextStyle get style {
    final style = linkConfig.styleBuilder?.call(_url) ?? linkConfig.style;
    return parentStyle?.merge(style) ?? style;
  }
}

///config class for link, tag: a
class LinkConfig implements LeafConfig {
  final TextStyle Function(String url)? styleBuilder;
  final TextStyle style;
  final ValueCallback<String>? onTap;

  const LinkConfig(
      {this.style = const TextStyle(
          color: Color(0xff0969da), decoration: TextDecoration.underline),
      this.styleBuilder,
      this.onTap});

  @nonVirtual
  @override
  String get tag => MarkdownTag.a.name;
}

// add a tap gesture recognizer to the span.
InlineSpan _toLinkInlineSpan(InlineSpan span, VoidCallback onTap) {
  if (span is TextSpan) {
    span = TextSpan(
      text: span.text,
      children: span.children?.map((e) => _toLinkInlineSpan(e, onTap)).toList(),
      style: span.style,
      recognizer: TapGestureRecognizer()..onTap = onTap,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  } else if (span is WidgetSpan) {
    span = WidgetSpan(
      child: InkWell(
        child: span.child,
        onTap: onTap,
      ),
      alignment: span.alignment,
      baseline: span.baseline,
      style: span.style,
    );
  }
  return span;
}
