import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';


///Tag: img
InlineSpan getImageSpan(m.Element node){
  String url = node.attributes['src'];
  return WidgetSpan(
    child: StyleConfig()?.imgBuilder?.call(url, node.attributes) ?? defaultImageWidget(node.attributes, url: url),
  );
}

Container defaultImageWidget(Map<String, String> attributes, {String url}) {

  double width;
  double height;
  if(attributes['width'] != null) width = double.parse(attributes['width']);
  if(attributes['height'] != null) height = double.parse(attributes['height']);
  return Container(
    padding: EdgeInsets.only(left: 4, right: 4),
    child: Image.network(url ?? attributes['src'],width: width, height: height,),
  );
}

class ImgConfig{
  final ImgWrapper imgWrapper;

  ImgConfig({this.imgWrapper});
}

typedef Widget ImgBuilder(String url, Map<String, String> attributes);
typedef Widget ImgWrapper(Widget img);


