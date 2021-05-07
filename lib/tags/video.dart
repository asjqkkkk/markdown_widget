import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:markdown/markdown.dart' as m;
import '../config/style_config.dart';

///Tag: video(this is not markdown's tag)
InlineSpan getVideoSpan(m.Element node) {
  String? url = node.attributes['src'];
  return WidgetSpan(
    child: StyleConfig().videoBuilder?.call(url, node.attributes) ??
        defaultVideoWidget(node.attributes, url: url),
  );
}

///the video widget
Widget defaultVideoWidget(Map<String, String> attributes, {String? url}) {
  double? width;
  double? height;
  if (attributes['width'] != null) width = double.parse(attributes['width']!);
  if (attributes['height'] != null)
    height = double.parse(attributes['height']!);
  final config = StyleConfig().videoConfig;
  final video = Container(
    width: width,
    height: height,
    child: VideoWidget(
      url: url ?? attributes['src'],
      config: config,
    ),
  );
  return config?.wrapperBuilder?.call(video) ?? video;
}

typedef Widget VideoBuilder(String? url, Map<String, String> attributes);
typedef Widget VideoWrapper(Widget video);

class VideoConfig {
  final double? aspectRatio;
  final bool? autoPlay;
  final bool? autoInitialize;
  final bool? looping;

//  final bool allowMuting;
  final VideoWrapper? wrapperBuilder;

  VideoConfig({
    this.aspectRatio,
    this.wrapperBuilder,
    this.autoPlay,
    this.autoInitialize,
    this.looping,
//    this.allowMuting,
  });
}

class VideoWidget extends StatefulWidget {
  final String? url;
  final VideoConfig? config;

  const VideoWidget({Key? key, required this.url, this.config})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _videoPlayerController;

  bool isButtonHiding = false;

  @override
  void initState() {
    final config = widget.config;
    _videoPlayerController = VideoPlayerController.network(widget.url!);
    if (config?.autoInitialize ?? false) {
      _videoPlayerController.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        refresh();
      });
    }
    if (config?.autoPlay ?? false) _videoPlayerController.play();
    _videoPlayerController.addListener(onListen);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final initialized = _videoPlayerController.value.isInitialized;
    final isPlaying = _videoPlayerController.value.isPlaying;
    final aspectRatio =
        config?.aspectRatio ?? _videoPlayerController.value.aspectRatio;

    return initialized
        ? AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              children: [
                GestureDetector(
                  child: VideoPlayer(_videoPlayerController),
                  onPanDown: (detail) {
                    if (isButtonHiding) {
                      isButtonHiding = false;
                      refresh();
                      hideButton();
                    }
                  },
                ),
                buildPlayButton(isPlaying)
              ],
            ),
          )
        : Container();
  }

  Widget buildPlayButton(bool isPlaying) {
    if (isButtonHiding && isPlaying) return Container();
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.grey.withOpacity(0.3)),
        child: IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            isPlaying
                ? _videoPlayerController.pause()
                : _videoPlayerController.play();
            refresh();
            hideButton();
          },
        ),
      ),
    );
  }

  void hideButton() {
    if (!isButtonHiding) {
      Future.delayed(Duration(seconds: 1), () {
        if (isButtonHiding) return;
        isButtonHiding = true;
        refresh();
      });
    }
  }

  void onListen() {
    if (_videoPlayerController.value.position ==
        _videoPlayerController.value.duration) {
      if (widget.config?.looping ?? false) _videoPlayerController.play();
    }
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(onListen);
    _videoPlayerController.dispose();
    super.dispose();
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
