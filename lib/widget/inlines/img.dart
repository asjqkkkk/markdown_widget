import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;

import '../../config/configs.dart';
import '../share_config_widget.dart';
import '../span_node.dart';

///Tag: [MarkdownTag.img]
InlineSpan getImageSpan(m.Element node) {
  String? url = node.attributes['src'];
  return WidgetSpan(
    child: ImgWidget(attributes: node.attributes, url: url),
  );
}

///the image widget
class ImgWidget extends StatelessWidget {
  final Map<String, String> attributes;
  final String? url;

  const ImgWidget({
    Key? key,
    required this.attributes,
    this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mdConfig =
        ShareConfigWidget.of(context)?.config ?? MarkdownConfig.defaultConfig;

    double? width;
    double? height;
    if (attributes['width'] != null) width = double.parse(attributes['width']!);
    if (attributes['height'] != null)
      height = double.parse(attributes['height']!);
    final imageUrl = url ?? attributes['src']!;
    return mdConfig.img.builder?.call(imageUrl, attributes) ??
        Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
  }
}

///config class for image, tag: img
class ImgConfig implements InlineConfig {
  final ImgBuilder? builder;

  const ImgConfig({this.builder});

  @nonVirtual
  @override
  String get tag => MarkdownTag.img.name;
}

typedef Widget ImgBuilder(String url, Map<String, String> attributes);

class ImageNode extends SpanNode {
  final Map<String, String> attributes;
  final ImgConfig imgConfig;

  ImageNode(this.attributes, this.imgConfig);

  @override
  InlineSpan build() {
    double? width;
    double? height;
    if (attributes['width'] != null) width = double.parse(attributes['width']!);
    if (attributes['height'] != null)
      height = double.parse(attributes['height']!);
    final imageUrl = attributes['src']!;
    return WidgetSpan(
        child: imgConfig.builder?.call(imageUrl, attributes) ??
            Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ));
  }
}
