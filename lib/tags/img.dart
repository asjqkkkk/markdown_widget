import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: img
InlineSpan getImageSpan(m.Element node) {
  String? url = node.attributes['src'];
  return WidgetSpan(
    child: ImageTagWidget(attributes: node.attributes, url: url),
  );
}

///the image widget
class ImageTagWidget extends StatelessWidget {
  final Map<String, String> attributes;
  final String? url;

  const ImageTagWidget({
    Key? key,
    required this.attributes,
    this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? width;
    double? height;
    if (attributes['width'] != null) width = double.parse(attributes['width']!);
    if (attributes['height'] != null)
      height = double.parse(attributes['height']!);
    final imageUrl = url ?? attributes['src']!;
    final image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
    final config = StyleConfig().imgConfig;
    return StyleConfig().imgBuilder?.call(imageUrl, attributes) ??
        config?.imgWrapper?.call(image) ??
        image;
  }
}

///config class for [ImageTagWidget]
class ImgConfig {
  final ImgWrapper? imgWrapper;

  ImgConfig({this.imgWrapper});
}

typedef Widget ImgBuilder(String url, Map<String, String> attributes);
typedef Widget ImgWrapper(Widget img);
