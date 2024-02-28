import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../config/configs.dart';
import '../../proxy_rich_text.dart';
import '../../span_node.dart';
import '../../widget_visitor.dart';

///Tag: [MarkdownTag.h1] ~ [MarkdownTag.h6]
///
///An ATX heading consists of a string of characters
///A setext heading consists of one or more lines of text
class HeadingNode extends ElementNode {
  final HeadingConfig headingConfig;
  final WidgetVisitor visitor;

  HeadingNode(this.headingConfig, this.visitor);

  @override
  InlineSpan build() {
    final divider = headingConfig.divider;
    if (divider == null) return childrenSpan;
    return WidgetSpan(
      child: Padding(
        padding: headingConfig.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ProxyRichText(
              childrenSpan,
              richTextBuilder: visitor.richTextBuilder,
            ),
            _Divider(divider: divider.copy(color: parentStyle?.color)),
          ],
        ),
      ),
    );
  }

  HeadingNode copy({HeadingConfig? headingConfig}) {
    final node = HeadingNode(headingConfig ?? this.headingConfig, visitor);
    for (var e in children) {
      node.accept(e);
    }
    return node;
  }

  @override
  TextStyle get style => headingConfig.style.merge(parentStyle);
}

///divider widget
class _Divider extends StatelessWidget {
  final HeadingDivider divider;

  const _Divider({Key? key, required this.divider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: divider.space),
        child: Divider(height: divider.height, color: divider.color));
  }
}

///only support h1 and h2
class HeadingDivider {
  ///the space between title and divider
  final double space;

  ///the color of divider
  final Color color;

  ///the height of divider
  final double height;

  HeadingDivider(
      {this.space = 4.8,
      this.color = const Color(0xFFd7dde3),
      this.height = 1.0});

  HeadingDivider copy({Color? color, double? space, double? height}) =>
      HeadingDivider(
          color: color ?? this.color,
          space: space ?? this.space,
          height: height ?? this.height);

  static HeadingDivider h1 = HeadingDivider();

  static HeadingDivider h2 = HeadingDivider(space: 3.6);

  static HeadingDivider h3 = HeadingDivider(space: 2.4);
}

///config class for heading
abstract class HeadingConfig implements LeafConfig {
  const HeadingConfig();

  TextStyle get style;

  HeadingDivider? get divider => null;

  EdgeInsets get padding => EdgeInsets.only(top: 8, bottom: 4);
}

///config class for h1
class H1Config extends HeadingConfig {
  @override
  final TextStyle style;

  const H1Config(
      {this.style = const TextStyle(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.bold,
      )});

  @nonVirtual
  @override
  String get tag => MarkdownTag.h1.name;

  static H1Config get darkConfig => const H1Config(
          style: TextStyle(
        fontSize: 32,
        height: 40 / 32,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ));

  @override
  HeadingDivider? get divider => HeadingDivider.h1;
}

///config class for h2
class H2Config extends HeadingConfig {
  @override
  final TextStyle style;

  const H2Config(
      {this.style = const TextStyle(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.bold,
      )});

  @nonVirtual
  @override
  String get tag => MarkdownTag.h2.name;

  static H2Config get darkConfig => const H2Config(
          style: TextStyle(
        fontSize: 24,
        height: 30 / 24,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ));

  @override
  HeadingDivider? get divider => HeadingDivider.h2;
}

///config class for h3
class H3Config extends HeadingConfig {
  @override
  final TextStyle style;

  const H3Config(
      {this.style = const TextStyle(
        fontSize: 20,
        height: 25 / 20,
        fontWeight: FontWeight.bold,
      )});

  @nonVirtual
  @override
  String get tag => MarkdownTag.h3.name;

  static H3Config get darkConfig => const H3Config(
          style: TextStyle(
        fontSize: 20,
        height: 25 / 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ));

  @override
  HeadingDivider? get divider => HeadingDivider.h3;
}

///config class for h4
class H4Config extends HeadingConfig {
  @override
  final TextStyle style;

  const H4Config(
      {this.style = const TextStyle(
        fontSize: 16,
        height: 20 / 16,
        fontWeight: FontWeight.bold,
      )});

  @nonVirtual
  @override
  String get tag => MarkdownTag.h4.name;

  static H4Config get darkConfig => const H4Config(
          style: TextStyle(
        fontSize: 16,
        height: 20 / 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ));
}

///config class for h5
class H5Config extends HeadingConfig {
  @override
  final TextStyle style;

  const H5Config(
      {this.style = const TextStyle(
        fontSize: 16,
        height: 20 / 16,
        fontWeight: FontWeight.bold,
      )});

  @nonVirtual
  @override
  String get tag => MarkdownTag.h5.name;

  static H5Config get darkConfig => const H5Config(
          style: TextStyle(
        fontSize: 16,
        height: 20 / 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ));
}

///config class for h6
class H6Config extends HeadingConfig {
  @override
  final TextStyle style;

  const H6Config(
      {this.style = const TextStyle(
        fontSize: 16,
        height: 20 / 16,
        fontWeight: FontWeight.bold,
      )});

  @nonVirtual
  @override
  String get tag => MarkdownTag.h6.name;

  static H6Config get darkConfig => const H6Config(
          style: TextStyle(
        fontSize: 16,
        height: 20 / 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ));
}
