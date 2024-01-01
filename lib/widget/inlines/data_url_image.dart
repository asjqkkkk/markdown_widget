import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64DataUrlImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final Color? color;
  final Animation<double>? opacity;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final bool isAntiAlias;
  final FilterQuality filterQuality;
  final int? cacheWidth;
  final int? cacheHeight;

  const Base64DataUrlImage(
    this.imageUrl, {
    Key? key,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    this.cacheWidth,
    this.cacheHeight,
  }) : super(key: key);

  @override
  _Base64DataUrlImageState createState() => _Base64DataUrlImageState();

  static Uint8List _dataUrlToBytes(String dataUrl) =>
      base64.decode(dataUrl.split(',').last);
}

class _Base64DataUrlImageState extends State<Base64DataUrlImage> {
  late Uint8List imageBytes;

  @override
  void initState() {
    super.initState();
    imageBytes = Base64DataUrlImage._dataUrlToBytes(widget.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      imageBytes,
      key: widget.key,
      scale: 1.0,
      frameBuilder: null,
      errorBuilder: widget.errorBuilder,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      width: widget.width,
      height: widget.height,
      color: widget.color,
      opacity: widget.opacity,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: widget.gaplessPlayback,
      isAntiAlias: widget.isAntiAlias,
      filterQuality: widget.filterQuality,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
    );
  }
}
