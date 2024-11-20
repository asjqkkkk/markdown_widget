import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:runtime_client/particle.dart';
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
  final Future<void> Function(String)? onCopy;

  LinkNode(this.attributes, this.linkConfig, this.onCopy);

  @override
  InlineSpan build() {
    final url = attributes['href'] ?? '';
    return TextSpan(
      children: [
        for (final child in children)
          _toLinkInlineSpan(
            child.build(),
            () => _onLinkTap(linkConfig, url),
            url,
            onCopy,
          ),
        if (children.isNotEmpty)
          // FIXME: this is a workaround, maybe need fixed by flutter framework.
          // add a space to avoid the space area of line end can be tapped.
          TextSpan(text: ' '),
      ],
    );
  }

  void _onLinkTap(LinkConfig linkConfig, String url) {
    if (linkConfig.onTap != null) {
      linkConfig.onTap?.call(url);
    } else {
      launchUrl(Uri.parse(url));
    }
  }

  @override
  TextStyle get style => parentStyle?.merge(linkConfig.style) ?? linkConfig.style;
}

///config class for link, tag: a
class LinkConfig implements LeafConfig {
  final TextStyle style;
  final ValueCallback<String>? onTap;

  const LinkConfig({
    this.style = const TextStyle(color: Color(0xff0969da), decoration: TextDecoration.underline),
    this.onTap,
  });

  @nonVirtual
  @override
  String get tag => MarkdownTag.a.name;
}

InlineSpan _toRawSpan(InlineSpan span, VoidCallback onTap) {
  if (span is TextSpan) {
    return TextSpan(
      text: span.text,
      children: span.children?.map((e) => _toRawSpan(e, onTap)).toList(),
      style: span.style,
      recognizer: TapGestureRecognizer()..onTap = onTap,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  } else if (span is WidgetSpan) {
    return WidgetSpan(
      child: InkWell(
        child: span.child,
        onTap: onTap,
      ),
      alignment: span.alignment,
      baseline: span.baseline,
      style: span.style,
    );
  }

  return TextSpan();
}

// add a tap gesture recognizer to the span.
InlineSpan _toLinkInlineSpan(InlineSpan span, VoidCallback onTap, String url, [Future<void> Function(String)? onCopy]) {
  if (span is TextSpan) {
    span = WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                text: span.text,
                children: span.children?.map((e) => _toRawSpan(e, onTap)).toList(),
                style: span.style,
                recognizer: TapGestureRecognizer()..onTap = onTap,
                onEnter: span.onEnter,
                onExit: span.onExit,
                semanticsLabel: span.semanticsLabel,
                locale: span.locale,
                spellOut: span.spellOut,
              ),
            ),
          ),
          if (onCopy != null) ...[
            SizedBox(width: 2),
            CopyActionButton(
              content: url,
              micro: true,
              tooltip: 'Copy URL: $url',
              copyCallback: onCopy,
            ),
          ],
        ],
      ),
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
