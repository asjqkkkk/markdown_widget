Language:[简体中文](https://github.com/asjqkkkk/markdown_widget/blob/master/README_ZH.md)|[English](https://github.com/asjqkkkk/markdown_widget/blob/master/README.md)

# markdown_widget

[![support](https://img.shields.io/badge/platform-flutter%7Cdart%20vm-ff69b4.svg?style=flat-square)](https://github.com/asjqkkkk/markdown_widget)
[![Flutter Web](https://github.com/asjqkkkk/markdown_widget/workflows/Flutter%20Web/badge.svg)](https://github.com/asjqkkkk/markdown_widget/actions)
[![pub package](https://img.shields.io/pub/v/markdown_widget.svg)](https://pub.dartlang.org/packages/markdown_widget)
[![demo](https://img.shields.io/badge/demo-online-brightgreen)](http://oldben.gitee.io/markdown_widget)

完全由flutter创建,一个简单好用,支持mobile与flutter web的markdown插件

- 支持TOC功能
- 支持html格式的 `img` 和 `video` 标签
- 支持代码高亮


## 开始

在开始之前,你可以先体验一下在线 demo [点击体验](http://oldben.gitee.io/markdown_widget)

### 简单使用


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

## 图片和视频

如果你想要自定义 **img** 和 **video** 这两个标签的 Widget

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

图片与视频标签支持的markdown格式

```
<video src="https://xxx.mp4" controls="controls"/>

<img width="150" alt="018" src="https://xxx.png"/>

![demo](https://xxx)

```

如果你想自定义其他标签的Widget,请使用 `WidgetConfig`

## 链接

你可以自定义链接样式和点击事件


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

## TOC功能

当你想使用TOC功能的时候

```
  final TocController tocController = TocController();

  Widget buildMarkdown() => MarkdownWidget(
        data: data,
        tocListBuilder: (LinkedHashMap<int, Toc> tocList){
          ///这里获取TOC目录列表
        },
        controller: tocController..addListener(() {
          final currentTocNode = tocController.toc;
          if(currentTocNode != null){
            ///可以在这里做TOC列表index刷新之类的操作
          }
        }),
      );
```

## 代码高亮

代码高亮支持多种主题

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

如果你由什么好的想法或者建议,以及使用上的问题, [欢迎来提pr或issue](https://github.com/asjqkkkk/markdown_widget)


# 附录

这里是 markdown_widget 中使用到的其他库

库 | 描述
---|---
[markdown](https://pub.flutter-io.cn/packages/markdown) | 解析markdown数据
[flutter_highlight](https://pub.flutter-io.cn/packages/flutter_highlight) | 代码高亮
[html](https://pub.flutter-io.cn/packages/html) | 解析markdown没有解析的html标签
[video_player_web](https://pub.flutter-io.cn/packages/video_player_web) | 在flutter web上播放视频
[video_player](https://pub.flutter-io.cn/packages/video_player) | 视频接口
[chewie](https://pub.flutter-io.cn/packages/chewie) | 一个简单漂亮的视频播放器
[scrollable_positioned_list](https://pub.flutter-io.cn/packages/scrollable_positioned_list) | 用于实现TOC功能
