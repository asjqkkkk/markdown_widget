import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../state/root_state.dart';

class TocItemWidget extends StatelessWidget {
  const TocItemWidget({
    Key? key,
    this.isCurrent = false,
    required this.toc,
    this.onTap,
    this.fontSize = 14.0,
  }) : super(key: key);

  final bool isCurrent;
  final Toc toc;
  final VoidCallback? onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return getNodeWidget(toc, context);
  }

  Widget getNodeWidget(Toc toc, BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final tag = toc.node.headingConfig.tag;
    final level = _tag2Level[tag] ?? 1;
    final node = toc.node.copy(
        headingConfig: _TocHeadingConfig(
            isCurrent
                ? TextStyle(
                    color: color,
                    fontSize: fontSize,
                  )
                : TextStyle(
                    fontSize: fontSize,
                    color: isDark ? Colors.grey : null,
                  ),
            tag));
    return InkWell(
      child: Container(
        margin: EdgeInsets.fromLTRB(10.0 * level, 4, 4, 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ProxyRichText(node.build()),
      ),
      onTap: () {
        if (!isCurrent) {
          onTap?.call();
        }
      },
    );
  }
}

///every heading tag has a special level
final _tag2Level = <String, int>{
  'h1': 1,
  'h2': 2,
  'h3': 3,
  'h4': 5,
  'h5': 5,
  'h6': 6,
};

class _TocHeadingConfig extends HeadingConfig {
  final TextStyle style;
  final String tag;

  _TocHeadingConfig(this.style, this.tag);
}
