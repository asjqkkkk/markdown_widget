import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;

import 'config/widget_config.dart';
import 'tags/blockquote.dart';
import 'tags/hr.dart';
import 'tags/ol.dart';
import 'tags/p.dart';
import 'tags/pre.dart';
import 'tags/table.dart';
import 'tags/title.dart';
import 'tags/ul.dart';

export 'tags/markdown_tags.dart';

class MarkdownHelper {
  WidgetConfig? wConfig;

  MarkdownHelper({this.wConfig});

  ///h1~h6
  Widget? getTitleWidget(m.Node node, String tag) =>
      TitleWidget(node: node as m.Element, tag: tag);

  ///p
  Widget getPWidget(m.Element node) =>
      wConfig?.p?.call(node) ??
      PWidget(children: node.children, parentNode: node);

  ///pre
  Widget getPreWidget(m.Node node) =>
      wConfig?.pre?.call(node as m.Element) ?? PreWidget(node: node);

  ///ul
  Widget getUlWidget(m.Element node, int deep) =>
      wConfig?.ul?.call(node) ?? ULWidget(rootNode: node, deep: deep);

  ///ol
  Widget getOlWidget(m.Element node, int deep) =>
      wConfig?.ol?.call(node) ?? OLWidget(rootNode: node, deep: deep);

  ///blockquote
  Widget getBlockQuote(m.Element node) =>
      wConfig?.block?.call(node) ?? BlockQuoteWidget(node: node);

  ///hr
  Widget getHrWidget(m.Element node) =>
      wConfig?.hr?.call(node) ?? HrWidget(node: node);

  ///table
  Widget getTableWidget(m.Element node) =>
      wConfig?.table?.call(node) ?? TableWidget(node: node);
}
