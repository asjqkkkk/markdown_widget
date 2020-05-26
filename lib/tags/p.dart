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
import 'package:flutter/foundation.dart' show kIsWeb;

class P {
  P._internal();

  static P _instance;

  factory P() {
    _instance ??= P._internal();
    return _instance;
  }

  ///Tag:  p
  Widget getPWidget(
    List<m.Node> children,
    m.Node parentNode, {
    TextStyle textStyle,
    bool selectable,
    TextConfig textConfig,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.center,
  }) {
    final configSelectable =
        selectable ?? StyleConfig().pConfig?.selectable ?? true;
    return isWeb()
        ? buildWebRichText(children, parentNode, textStyle, configSelectable,
            crossAxisAlignment, textConfig)
        : buildRichText(
            children, parentNode, textStyle, configSelectable, textConfig);
  }

  bool isWeb() => kIsWeb;

  ///see this issue:https://github.com/flutter/flutter/issues/42086
  ///flutter web can't use WidgetSpan now.so this is another solution
  ///you can also use this in mobile，but it will finally be replaced by [buildRichText]
  Widget buildWebRichText(
      List<m.Node> nodes,
      m.Node parentNode,
      TextStyle style,
      bool selectable,
      WrapCrossAlignment crossAxisAlignment,
      TextConfig textConfig) {
    if (nodes == null) return Container();
    List<Widget> children = [];
    final config = StyleConfig()?.pConfig;
    buildBlockWidgets(
        nodes,
        parentNode,
        style ?? config?.textStyle ?? defaultPStyle,
        children,
        selectable,
        textConfig);
    return Wrap(
      children: children,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  RichText buildRichText(List<m.Node> children, m.Node parentNode,
      TextStyle textStyle, bool selectable, TextConfig textConfig) {
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
      List<m.Node> nodes, m.Node parentNode, TextStyle parentStyle,
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
              parentStyle.merge(getTextStyle(node.tag)),
              selectable: selectable,
            );
          }
          return TextSpan();
        },
      ),
    );
  }

  InlineSpan buildTextSpan(m.Text node, TextStyle parentStyle,
      bool shouldParseHtml, bool selectable) {
    final nodes = shouldParseHtml ? parseHtml(node) : [];
    if (nodes.isEmpty) {
      return selectable
          ? WidgetSpan(child: SelectableText(node.text, style: parentStyle))
          : TextSpan(
              text: node.text,
              style: parentStyle,
            );
    } else {
      return getBlockSpan(nodes, node, parentStyle);
    }
  }

  void buildBlockWidgets(
      List<m.Node> nodes,
      m.Node parentNode,
      TextStyle parentStyle,
      List<Widget> widgets,
      bool selectable,
      TextConfig textConfig) {
    if (nodes == null || nodes.isEmpty) return;
    nodes.forEach((node) {
      bool shouldParseHtml = needParseHtml(parentNode);
      if (node is m.Text)
        buildWebTextWidget(widgets, node, selectable, shouldParseHtml,
            parentStyle, textConfig);
      else if (node is m.Element) {
        if (node.tag == code)
          widgets.add(defaultCodeWidget(node));
        else if (node.tag == img)
          widgets.add(defaultImageWidget(node.attributes));
        else if (node.tag == video)
          widgets.add(defaultVideoWidget(node.attributes));
        else if (node.tag == a)
          widgets.add(defaultAWidget(node));
        else if (node.tag == input)
          widgets.add(defaultCheckBox(node.attributes));
        else if (node.tag == other)
          widgets.add(getOtherWidget(node));
        else
          buildBlockWidgets(
              node.children,
              node,
              parentStyle.merge(getTextStyle(node.tag)),
              widgets,
              selectable,
              textConfig);
      }
    });
  }

  void buildWebTextWidget(
    List<Widget> widgets,
    m.Text node,
    bool selectable,
    bool shouldParseHtml,
    TextStyle parentStyle,
    TextConfig textConfig,
  ) {
    final nodes = shouldParseHtml ? parseHtml(node) : [];
    final config = StyleConfig()?.pConfig;
    if (nodes.isEmpty) {
      widgets.add(selectable
          ? SelectableText(
              node.text,
              style: parentStyle,
              textAlign: textConfig?.textAlign ?? config?.textConfig?.textAlign,
              textDirection: textConfig?.textDirection ??
                  config?.textConfig?.textDirection,
            )
          : Text(
              node.text,
              style: parentStyle,
              textAlign: textConfig?.textAlign ?? config?.textConfig?.textAlign,
              textDirection: textConfig?.textDirection ??
                  config?.textConfig?.textDirection,
            ));
    } else {
      widgets.add(getPWidget(nodes, node,
          textStyle: parentStyle,
          selectable: selectable,
          textConfig: textConfig));
    }
  }
}

class PConfig {
  final TextStyle textStyle;
  final TextStyle linkStyle;
  final TextStyle delStyle;
  final TextStyle emStyle;
  final TextStyle strongStyle;
  final TextConfig textConfig;
  final bool selectable;
  final OnLinkTap onLinkTap;
  final LinkGesture linkGesture;
  final Custom custom;

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
  final TextAlign textAlign;
  final TextDirection textDirection;

  TextConfig({this.textAlign, this.textDirection});
}

typedef void OnLinkTap(String url);
typedef Widget LinkGesture(Widget linkWidget, String url);
typedef Widget Custom(m.Element element);
