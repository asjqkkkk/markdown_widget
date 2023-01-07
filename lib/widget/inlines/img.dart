import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

///Tag: [MarkdownTag.img]
class ImageNode extends SpanNode {
  final Map<String, String> attributes;
  final MarkdownConfig config;

  ImgConfig get imgConfig => config.img;

  ImageNode(this.attributes, this.config);

  @override
  InlineSpan build() {
    double? width;
    double? height;
    if (attributes['width'] != null) width = double.parse(attributes['width']!);
    if (attributes['height'] != null)
      height = double.parse(attributes['height']!);
    final imageUrl = attributes['src'] ?? '';
    final alt = attributes['alt'] ?? '';
    final imgWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (ctx, error, stacktrace) {
        return Text.rich(TextSpan(children: [
          WidgetSpan(
              child: Icon(Icons.broken_image,
                  color: Colors.redAccent,
                  size: (parentStyle?.fontSize ??
                          config.p.textStyle.fontSize ??
                          16) *
                      (parentStyle?.height ??
                          config.p.textStyle.height ??
                          1.2))),
          TextSpan(text: alt, style: parentStyle ?? config.p.textStyle),
        ]));
      },
    );
    final result = (parent != null && parent is LinkNode)
        ? imgWidget
        : InkWell(
            child: imgWidget,
            onTap: () => launchUrl(Uri.parse(imageUrl)),
          );
    return WidgetSpan(
        child: imgConfig.builder?.call(imageUrl, attributes) ?? result);
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
