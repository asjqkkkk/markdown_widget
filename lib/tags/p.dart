import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import 'input.dart';
import 'a.dart';
import 'img.dart';
import 'code.dart';
import 'video.dart';
import 'markdown_tags.dart';
import '../config/html_support.dart';
import '../config/style_config.dart';

class P {
  P._internal();

  static P? _instance;

  factory P() {
    _instance ??= P._internal();
    return _instance!;
  }

  ///Tag:  p
  Widget getPWidget(
    List<m.Node>? children,
    m.Node parentNode, {
    TextStyle? textStyle,
    bool? selectable,
    TextConfig? textConfig,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.center,
  }) {
    final configSelectable =
        selectable ?? StyleConfig().pConfig?.selectable ?? true;
    return buildRichText(
        children, parentNode, textStyle, configSelectable, textConfig);
  }


  RichText buildRichText(List<m.Node>? children, m.Node parentNode,
      TextStyle? textStyle, bool selectable, TextConfig? textConfig) {
    final config = StyleConfig().pConfig;
    return RichText(
      softWrap: true,
      text: getBlockSpan(
        children,
        parentNode,
        textStyle ?? config?.textStyle ?? defaultPStyle,
        selectable: selectable,
      ),
      textAlign: textConfig?.textAlign ??
          config?.textConfig?.textAlign ??
          TextAlign.start,
      textDirection:
          textConfig?.textDirection ?? config?.textConfig?.textDirection,
    );
  }

  InlineSpan getBlockSpan(
      List<m.Node>? nodes, m.Node parentNode, TextStyle? parentStyle,
      {bool selectable = true}) {
    if (nodes == null || nodes.isEmpty) return TextSpan();
    return TextSpan(
      children: List.generate(
        nodes.length,
        (index) {
          bool shouldParseHtml = needParseHtml(parentNode);
          final node = nodes[index];
          if (node is m.Text)
            return buildTextSpan(
                node, parentStyle, shouldParseHtml, selectable);
          else if (node is m.Element) {
            if (node.tag == code) return getCodeSpan(node);
            if (node.tag == img) return getImageSpan(node);
            if (node.tag == video) return getVideoSpan(node);
            if (node.tag == a) return getLinkSpan(node);
            if (node.tag == input) return getInputSpan(node);
            if (node.tag == other) return getOtherWidgetSpan(node);
            return getBlockSpan(
              node.children,
              node,
              parentStyle!.merge(getTextStyle(node.tag)),
              selectable: selectable,
            );
          }
          return TextSpan();
        },
      ),
    );
  }

  InlineSpan buildTextSpan(m.Text node, TextStyle? parentStyle,
      bool shouldParseHtml, bool selectable) {
    final nodes = shouldParseHtml ? parseHtml(node) : [];
    if (nodes.isEmpty) {
      return selectable
          ? WidgetSpan(child: SelectableText(node.text, style: parentStyle))
          : TextSpan(text: node.text, style: parentStyle);
    } else {
      return getBlockSpan(nodes as List<m.Node>?, node, parentStyle, selectable: selectable);
    }
  }
}

class PConfig {
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final TextStyle? delStyle;
  final TextStyle? emStyle;
  final TextStyle? strongStyle;
  final TextConfig? textConfig;
  final bool? selectable;
  final OnLinkTap? onLinkTap;
  final LinkGesture? linkGesture;
  final Custom? custom;

  PConfig({
    this.textStyle,
    this.linkStyle,
    this.delStyle,
    this.emStyle,
    this.strongStyle,
    this.textConfig,
    this.onLinkTap,
    this.selectable,
    this.linkGesture,
    this.custom,
  });
}

class TextConfig {
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  TextConfig({this.textAlign, this.textDirection});
}

typedef void OnLinkTap(String? url);
typedef GestureRecognizer LinkGesture(String? url);
typedef Widget Custom(m.Element element);
