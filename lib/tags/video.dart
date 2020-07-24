import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: video(this is not markdown's tag)
InlineSpan getVideoSpan(m.Element node) {
  String url = node.attributes['src'];
  return WidgetSpan(
    child: StyleConfig()?.videoBuilder?.call(url, node.attributes) ??
        defaultVideoWidget(node.attributes, url: url),
  );
}

///the video widget
Widget defaultVideoWidget(Map<String, String> attributes, {String url}) {
  double width;
  double height;
  if (attributes['width'] != null) width = double.parse(attributes['width']);
  if (attributes['height'] != null) height = double.parse(attributes['height']);
  final config = StyleConfig()?.videoConfig;
  final video = Container(
    width: width,
    height: height,
    child: CheWieVideoWidget(
      url: url ?? attributes['src'],
      config: config,
    ),
  );
  return config?.wrapperBuilder?.call(video) ?? video;
}

typedef Widget VideoBuilder(String url, Map<String, String> attributes);
typedef Widget VideoWrapper(Widget video);

class VideoConfig {
  final double aspectRatio;
  final bool autoPlay;
  final bool autoInitialize;
  final bool looping;
  final bool allowMuting;
  final VideoWrapper wrapperBuilder;

  VideoConfig(this.wrapperBuilder,
      {this.aspectRatio,
      this.autoPlay,
      this.autoInitialize,
      this.looping,
      this.allowMuting});
}

class CheWieVideoWidget extends StatefulWidget {
  final String url;
  final VideoConfig config;

  const CheWieVideoWidget({Key key, @required this.url, this.config})
      : super(key: key);

  @override
  _CheWieVideoWidgetState createState() => _CheWieVideoWidgetState();
}

class _CheWieVideoWidgetState extends State<CheWieVideoWidget> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    final config = widget.config;
    _videoPlayerController = VideoPlayerController.network(widget.url);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: config?.aspectRatio ?? 3 / 2,
        autoPlay: config?.autoPlay ?? false,
        autoInitialize: config?.autoInitialize ?? true,
        looping: config?.looping ?? false,
        allowMuting: config?.allowMuting ?? false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
