import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/span_node.dart';
import 'package:markdown_widget/widget/widget_visitor.dart';
import 'package:video_player/video_player.dart';

class VideoNode extends SpanNode {
  final Map<String, String> attribute;

  VideoNode(this.attribute);

  @override
  InlineSpan build() {
    double? width;
    double? height;
    if (attribute['width'] != null) width = double.parse(attribute['width']!);
    if (attribute['height'] != null)
      height = double.parse(attribute['height']!);
    final link = attribute['src'] ?? '';
    return WidgetSpan(
        child: Container(
      width: width,
      height: height,
      child: VideoWidget(url: link),
    ));
  }
}

SpanNodeGeneratorWithTag videoGeneratorWithTag = SpanNodeGeneratorWithTag(
    tag: _videoTag, generator: (e, config, visitor) => VideoNode(e.attributes));

const _videoTag = 'video';

typedef Widget VideoBuilder(String? url, Map<String, String> attributes);
typedef Widget VideoWrapper(Widget video);

class VideoConfig implements InlineConfig {
  final double? aspectRatio;
  final bool autoPlay;
  final bool autoInitialize;
  final bool looping;

  final VideoBuilder? builder;

  const VideoConfig({
    this.aspectRatio,
    this.builder,
    this.autoPlay = false,
    this.autoInitialize = true,
    this.looping = false,
  });

  @nonVirtual
  @override
  String get tag => _videoTag;
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
    if (config?.autoInitialize ?? true) {
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
        : SizedBox(
            height: 50, child: Center(child: CircularProgressIndicator()));
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
