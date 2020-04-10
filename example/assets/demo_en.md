Language:[简体中文](https://github.com/asjqkkkk/markdown_widget/blob/master/README_ZH.md)|[English](https://github.com/asjqkkkk/markdown_widget/blob/master/README.md)

# markdown_widget

[![support](https://img.shields.io/badge/platform-flutter%7Cdart%20vm-ff69b4.svg?style=flat-square)](https://github.com/asjqkkkk/markdown_widget)
[![Flutter Web](https://github.com/asjqkkkk/markdown_widget/workflows/Flutter%20Web/badge.svg)](https://github.com/asjqkkkk/markdown_widget/actions)
[![pub package](https://img.shields.io/pub/v/markdown_widget.svg)](https://pub.dartlang.org/packages/markdown_widget)
[![demo](https://img.shields.io/badge/demo-online-brightgreen)](https://oldchen.top/markdown_widget/#/)

A simple and easy-to-use markdown package created by flutter.

- Support TOC
- Support img and Video Tags of HTML
- Support highlight code


## Getting Started

Before the introduction,  you can have a try for [Online Demo](https://oldchen.top/markdown_widget/#/)

### Useage


```
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownPage extends StatelessWidget {
  final String data;

  MarkdownPage(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        child: buildMarkdown(),
      ),
    );
  }

  Widget buildMarkdown() => MarkdownWidget(data: data);
}
```

## Image and Video

if you want to custom a widget, such as **Image** and **Video**:

```
  Widget buildMarkdown() => MarkdownWidget(
        data: data,
        styleConfig: StyleConfig(
          imgBuilder: (String url,attributes) {
            return Image.network(url);
          },
          videoBuilder: (String url,attributes) {
            return YourVideoWidget();
          }
        ),
      );
```

supported markdown samples:

```
<video src="https://xxx.mp4" controls="controls"/>

<img width="150" alt="018" src="https://xxx.png"/>

![demo](https://xxx)

```

if you want to custom other tag widgets, you need use `WidgetConfig`

## Links

you can custom link style


```
  Widget buildMarkdown() => MarkdownWidget(
        data: data,
        styleConfig: StyleConfig(
          pConfig: PConfig(
            linkStyle: TextStyle(...),
            onLinkTap: (url){
              _launchUrl(url);
            }
          )
        ),
      );
```

## TOC

if you want to get a TOC function

```
  final TocController tocController = TocController();

  Widget buildMarkdown() => MarkdownWidget(
        data: data,
        tocListBuilder: (LinkedHashMap<int, Toc> tocList){
          ///here you can get markdown toc list
        },
        controller: tocController..addListener(() {
          final currentTocNode = tocController.toc;
          if(currentTocNode != null){
            ///do what you want to do
          }
        }),
      );
```

## hightlight code

you can config lots of theme for code

```
import 'package:markdown_widget/config/highlight_themes.dart' as theme;

  Widget buildMarkdown() => MarkdownWidget(
        data: data,
        styleConfig: StyleConfig(
          preConfig: PreConfig(
            language: 'java',
            theme: theme.a11yLightTheme
          )
        ),
      );
```

if you have any good idea or sugesstion, [welcome for PR and issue](https://github.com/asjqkkkk/markdown_widget)


# appendix

Here are the other packages used in markdown_widget


package | explain
---|---
[markdown](https://pub.flutter-io.cn/packages/markdown) | parse markdown data
[flutter_highlight](https://pub.flutter-io.cn/packages/flutter_highlight) | make code highlight
[html](https://pub.flutter-io.cn/packages/html) | parse html data
[video_player_web](https://pub.flutter-io.cn/packages/video_player_web) | play video in flutter web
[video_player](https://pub.flutter-io.cn/packages/video_player) | video interface
[chewie](https://pub.flutter-io.cn/packages/chewie) | a simple and beautiful video player
[scrollable_positioned_list](https://pub.flutter-io.cn/packages/scrollable_positioned_list) | for TOC function
