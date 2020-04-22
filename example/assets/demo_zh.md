Language:[简体中文](https://github.com/asjqkkkk/markdown_widget/blob/master/README_ZH.md)|[English](https://github.com/asjqkkkk/markdown_widget/blob/master/README.md)

# 📖markdown_widget

[![support](https://img.shields.io/badge/platform-flutter%7Cdart%20vm-ff69b4.svg?style=flat-square)](https://github.com/asjqkkkk/markdown_widget)
[![Flutter Web](https://github.com/asjqkkkk/markdown_widget/workflows/Flutter%20Web/badge.svg)](https://github.com/asjqkkkk/markdown_widget/actions)
[![pub package](https://img.shields.io/pub/v/markdown_widget.svg)](https://pub.dartlang.org/packages/markdown_widget)
[![demo](https://img.shields.io/badge/demo-online-brightgreen)](http://oldben.gitee.io/markdown_widget)

完全由flutter创建,一个简单好用,支持mobile与flutter web的markdown插件

- 支持TOC功能
- 支持html格式的 `img` 和 `video` 标签
- 支持代码高亮


## 🚀开始

在开始之前,你可以先体验一下在线 demo [点击体验](http://oldben.gitee.io/markdown_widget)

### 🔑简单使用


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

如果你想使用自己的 Column 或者其他列表 Widget, 你可以使用 `MarkdownGenerator`


```
  Widget buildMarkdown() => Column(children: MarkdownGenerator(data: data).widgets,);
```

## 🌠夜间模式

`markdown_widget` 默认支持夜间模式，你只需要对 `StyleConfig` 的 `markdownTheme` 属性进行配置即可


```
  Widget buildMarkdown() => MarkdownWidget(
        data: data,
        controller: controller,
        styleConfig: StyleConfig(
          markdownTheme: MarkdownTheme.lightTheme
        ),
      );
```
<img src="https://user-images.githubusercontent.com/30992818/79996396-02f4cc80-84eb-11ea-9c17-cf14979708a1.png" width=400> <img src="https://user-images.githubusercontent.com/30992818/79996326-ece70c00-84ea-11ea-811c-9ad7d1e81a19.png" width=400>

这里你也可以自定义 `markdownTheme`


## 🏞图片和视频

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

## 🔗链接

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

## 🍑自定义标签

你可以使用自定义标签

例如添加以下内容在你的markdown文件中

```markdown
<avatar size="12" name="tom" />
```

然后添加配置以下 `custom` 配置

```dart
      MarkdownWidget(
        data: data,
            styleConfig: StyleConfig(
              pConfig: PConfig(
                custom: (m.Element node) {
                  ...
                  return YourCustomWidget();
                },
              ),
            ),
          ),
```

## 📜TOC功能

使用TOC非常的简单

```
  final TocController tocController = TocController();

  Widget buildTocWidget() => TocListWidget(controller: controller);

  Widget buildMarkdown() => MarkdownWidget(data: data, controller: controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: <Widget>[
        Expanded(child: buildTocWidget()),
        Expanded(child: buildMarkdown(), flex: 3)
      ],
    ));
  }
```

## 🎈代码高亮

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

## 为什么我要创建这个库

既然已经有了 [flutter_markdown](https://pub.flutter-io.cn/packages/flutter_markdown) ，为什么我还要费时费力去写一个与之类似的新库呢？

这是因为在我用flutter web创建我的[个人博客](http://oldben.gitee.io/flutter-blog/#/)的过程中，发现flutter_markdown有很多功能都不支持，比如TOC功能、HTML tag的图片等

提了3个issue也没有回音，在这个前提下也就没打算去提pr了，并且flutter_markdown的源码并没有那么容易修改，可读性不高

最后索性自己重新创建一个啦！