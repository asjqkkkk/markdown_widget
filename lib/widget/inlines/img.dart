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
    final isNetImage = imageUrl.startsWith('http');
    final imgWidget = isNetImage
        ? Image.network(imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover, errorBuilder: (ctx, error, stacktrace) {
            return buildErrorImage(imageUrl, alt, error);
          })
        : Image.asset(imageUrl, width: width, height: height, fit: BoxFit.cover,
            errorBuilder: (ctx, error, stacktrace) {
            return buildErrorImage(imageUrl, alt, error);
          });
    final result = (parent != null && parent is LinkNode)
        ? imgWidget
        : Builder(builder: (context) {
            return InkWell(
              child: imgWidget,
              onTap: () => _showImage(context, imgWidget),
            );
          });
    return WidgetSpan(
        child: imgConfig.builder?.call(imageUrl, attributes) ?? result);
  }

  Widget buildErrorImage(String url, String alt, Object? error) {
    return Text.rich(TextSpan(children: [
      WidgetSpan(
          child: Icon(Icons.broken_image,
              color: Colors.redAccent,
              size: (parentStyle?.fontSize ??
                      config.p.textStyle.fontSize ??
                      16) *
                  (parentStyle?.height ?? config.p.textStyle.height ?? 1.2))),
      TextSpan(text: alt, style: parentStyle ?? config.p.textStyle),
    ]));
  }

  void _showImage(BuildContext context, Widget child) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (ctx, anm1, anm2) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.1),
            body: Stack(
              fit: StackFit.expand,
              children: [
                InteractiveViewer(child: Center(child: child)),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.cancel_outlined),
                    ),
                  ),
                )
              ],
            ),
          );
        }));
  }
}

///config class for image, tag: img
class ImgConfig implements InlineConfig {
  ///use [builder] to return a custom image
  final ImgBuilder? builder;

  ///use [errorBuilder] to return a custom error image
  final ErrorImgBuilder? errorBuilder;

  const ImgConfig({this.builder, this.errorBuilder});

  @nonVirtual
  @override
  String get tag => MarkdownTag.img.name;
}

typedef Widget ImgBuilder(String url, Map<String, String> attributes);
typedef Widget ErrorImgBuilder(String url, String alt, Object error);
