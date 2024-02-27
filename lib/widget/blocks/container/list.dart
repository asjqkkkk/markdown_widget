import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../config/configs.dart';
import '../../inlines/input.dart';
import '../../proxy_rich_text.dart';
import '../../span_node.dart';
import '../../widget_visitor.dart';
import '../leaf/paragraph.dart';

///Tag [MarkdownTag.ol]、[MarkdownTag.ul]
///
/// ordered list and unordered widget
class UlOrOLNode extends ElementNode {
  final String tag;
  final ListConfig config;
  final Map<String, String> attribute;
  late int start;
  final WidgetVisitor visitor;

  UlOrOLNode(this.tag, this.attribute, this.config, this.visitor) {
    start = (int.tryParse(attribute['start'] ?? '') ?? 1) - 1;
  }

  @override
  void accept(SpanNode? node) {
    super.accept(node);
    if (node != null && node is ListNode) {
      node._index = start;
      start++;
    }
  }

  @override
  InlineSpan build() {
    return WidgetSpan(
      child: Padding(
        padding: EdgeInsets.only(top: parent == null ? 0 : config.marginBottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            children.length,
            (index) {
              final childNode = children[index];
              return ProxyRichText(childNode.build(),
                  richTextBuilder: visitor.richTextBuilder);
            },
          ),
        ),
      ),
    );
  }

  @override
  TextStyle? get style => parentStyle;
}

///Tag [MarkdownTag.li]
///
/// A list is a sequence of one or more list items of the same type.
/// The list items may be separated by any number of blank lines.
class ListNode extends ElementNode {
  final MarkdownConfig config;
  final WidgetVisitor visitor;

  ListNode(this.config, this.visitor);

  int _index = 0;

  int get index => _index;

  bool get isOrdered {
    final p = parent;
    return p != null && p is UlOrOLNode && p.tag == MarkdownTag.ol.name;
  }

  int get depth {
    int d = 0;
    SpanNode? p = parent;
    while (p != null) {
      p = p.parent;
      if (p != null && p is UlOrOLNode && _listTag.contains(p.tag)) d += 1;
    }
    return d;
  }

  @override
  InlineSpan build() {
    final space = config.li.marginLeft;
    final marginBottom = config.li.marginBottom;
    final parentStyleHeight =
        (parentStyle?.fontSize ?? config.p.textStyle.fontSize ?? 16.0) *
            (parentStyle?.height ?? config.p.textStyle.height ?? 1.2);
    Widget marker;
    if (isCheckbox) {
      marker = ProxyRichText(
        children.removeAt(0).build(),
        richTextBuilder: visitor.richTextBuilder,
      );
    } else {
      marker = config.li.marker?.call(isOrdered, depth, index) ??
          getDefaultMarker(isOrdered, depth, parentStyle?.color, index,
              parentStyleHeight / 2, config);
    }
    return WidgetSpan(
      child: Padding(
        padding: EdgeInsets.only(bottom: marginBottom),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: space,
              child: marker,
            ),
            Flexible(
              child: ProxyRichText(
                TextSpan(
                  children: [
                    if (children.isNotEmpty) children.first.build(),
                    for (final child in children.skip(1)) ...[
                      // Introducing a new line before the next list item.
                      // Otherwise, it might be rendered on the same line, disrupting the layout.
                      if (child is UlOrOLNode) const TextSpan(text: '\n'),
                      child.build(),
                    ],
                  ],
                ),
                richTextBuilder: visitor.richTextBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isCheckbox {
    return children.isNotEmpty && children.first is InputNode;
  }

  @override
  TextStyle? get style => parentStyle;
}

///config class for list, tag: li
class ListConfig implements ContainerConfig {
  ///the value margin left for list children
  final double marginLeft;

  ///the value margin left bottom list children
  final double marginBottom;

  ///the marker widget for list
  final ListMarker? marker;

  const ListConfig({
    this.marginLeft = 32.0,
    this.marginBottom = 4.0,
    this.marker,
  });

  @nonVirtual
  @override
  String get tag => MarkdownTag.li.name;
}

///the function to get marker widget
typedef ListMarker = Widget? Function(bool isOrdered, int depth, int index);

///the default marker widget for unordered list
class _UlMarker extends StatelessWidget {
  final int depth;
  final Color? color;

  const _UlMarker({Key? key, this.depth = 0, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.textTheme.titleLarge?.color ?? Colors.black;
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 6,
        height: 6,
        decoration: get(depth % 3, c),
      ),
    );
  }

  BoxDecoration get(int depth, Color color) {
    if (depth == 0) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      );
    } else if (depth == 1) {
      return BoxDecoration(
        border: Border.all(color: color),
        shape: BoxShape.circle,
      );
    }
    return BoxDecoration(color: color);
  }
}

///the default marker widget for ordered list
class _OlMarker extends StatelessWidget {
  final int depth;
  final int index;
  final Color? color;
  final PConfig config;

  const _OlMarker(
      {Key? key,
      this.depth = 0,
      this.color,
      this.index = 1,
      required this.config})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionContainer.disabled(
        child: Text('${index + 1}.',
            style: config.textStyle.copyWith(color: color)));
  }
}

///get default marker for list
Widget getDefaultMarker(bool isOrdered, int depth, Color? color, int index,
    double paddingTop, MarkdownConfig config) {
  Widget marker;
  if (isOrdered) {
    marker = Container(
        alignment: Alignment.topRight,
        padding: EdgeInsets.only(right: 1),
        child: _OlMarker(
            depth: depth, index: index, color: color, config: config.p));
  } else {
    marker = Padding(
        padding: EdgeInsets.only(top: paddingTop - 3),
        child: _UlMarker(depth: depth, color: color));
  }
  return marker;
}

const _listTag = {'ul', 'ol'};
