语言：[简体中文](https://github.com/asjqkkkk/markdown_widget/blob/master/README_ZH.md) | [English](https://github.com/asjqkkkk/markdown_widget/blob/master/README.md)

![screen](https://github.com/asjqkkkk/asjqkkkk.github.io/assets/30992818/4185bf1a-0be3-460d-ba12-9e4764f5c035)

# 📖markdown_widget

[![Coverage Status](https://coveralls.io/repos/github/asjqkkkk/markdown_widget/badge.svg?branch=dev)](https://coveralls.io/github/asjqkkkk/markdown_widget?branch=dev) [![pub package](https://img.shields.io/pub/v/markdown_widget.svg)](https://pub.dartlang.org/packages/markdown_widget) [![demo](https://img.shields.io/badge/demo-online-brightgreen)](https://asjqkkkk.github.io/markdown_widget/)

一个简单易用的markdown渲染组件

- 支持TOC功能，可以通过Heading快速定位
- 支持代码高亮
- 支持全平台

## 🚀使用

在开始之前,你可以先体验一下在线 demo [点击体验](https://asjqkkkk.github.io/markdown_widget/)

```
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownPage extends StatelessWidget {
  final String data;

  MarkdownPage(this.data);

  @override
  Widget build(BuildContext context) => Scaffold(body: buildMarkdown());

  Widget buildMarkdown() => MarkdownWidget(data: data);
}
```

如果你想使用自己的 Column 或者其他列表 Widget, 你可以使用 `MarkdownGenerator`

```
  Widget buildMarkdown() =>
      Column(children: MarkdownGenerator().buildWidgets(data));
```

或者直接使用 `MarkdownBlock`

```
  Widget buildMarkdown() =>
      SingleChildScrollView(child: MarkdownBlock(data: data));
```

## 🌠夜间模式

`markdown_widget` 默认支持夜间模式，只需要使用不同的 `MarkdownConfig` 即可
```
  Widget buildMarkdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;
    final codeWrapper = (child, text, language) =>
        CodeWrapperWidget(child, text, language);
    return MarkdownWidget(
        data: data,
        config: config.copy(configs: [
        isDark
        ? PreConfig.darkConfig.copy(wrapper: codeWrapper)
        : PreConfig().copy(wrapper: codeWrapper)
    ]));
  }
```

默认模式 | 夜间模式
---|---
<img src="https://user-images.githubusercontent.com/30992818/211159232-92efbbb0-dd01-4970-8ff1-33a47c133b1f.png" width=400> | <img src="https://user-images.githubusercontent.com/30992818/211159236-570fca93-a5f4-403f-94ba-986272d1207e.png" width=400>


## 🔗链接

你可以自定义链接样式和点击事件，比如下面这样

```
  Widget buildMarkdown() => MarkdownWidget(
      data: data,
      config: MarkdownConfig(configs: [
        LinkConfig(
          style: TextStyle(
            color: Colors.red,
            decoration: TextDecoration.underline,
          ),
          onTap: (url) {
            ///TODO:on tap
          },
        )
      ]));
      
```

## 📜TOC功能

使用TOC非常的简单

```
  final tocController = TocController();

  Widget buildTocWidget() => TocWidget(controller: tocController);

  Widget buildMarkdown() => MarkdownWidget(data: data, tocController: tocController);

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
import 'package:flutter_highlight/themes/a11y-light.dart';

  Widget buildMarkdown() => MarkdownWidget(
      data: data,
      config: MarkdownConfig(configs: [
        PreConfig(theme: a11yLightTheme),
      ]));
```

## 🧬全选与复制

支持全平台的全选和复制功能

![image](https://user-images.githubusercontent.com/30992818/226107076-f32a919e-9a0c-4138-8a0b-266c6337e0af.png)

## 🌐html 标签

由于当前 package 只实现了对于 Markdown tag 的转换，所以默认不支持转换 html 标签。但可以通过扩展的方式来支持这个功能，具体可以参考这里的使用 [html_support.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/html_support.dart)

以及 [在线html demo展示](https://asjqkkkk.github.io/markdown_widget/#/sample_html)

## 🧮Latex 支持

在例子中实现了对于Latex的简单支持，具体可以参考这里的实现 [latex.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/latex.dart) 

以及 [在线latex demo展示](https://asjqkkkk.github.io/markdown_widget/#/sample_latex)


## 🍑自定义tag与实现

通过向 `MarkdownGeneratorConfig` 传递 `SpanNodeGeneratorWithTag` ，可以增加新的 tag，以及这个 tag 所对应的 `SpanNode`；也可以使用已有的 tag 来对它所对应的 `SpanNode` 进行覆盖

同时也可以通过 `InlineSyntax` 与 `BlockSyntax` 自定义 markdown 字符串的解析规则，并生成新的 tag

可以参考 [这个issue](https://github.com/asjqkkkk/markdown_widget/issues/79) 是如何去实现一个自定义tag的

如果你由什么好的想法或者建议,以及使用上的问题, [欢迎来提pr或issue](https://github.com/asjqkkkk/markdown_widget)

# 🧾附录

这里是 markdown_widget 中使用到的其他库

库 | 描述
---|---
[markdown](https://pub.dev/packages/markdown) | 解析markdown数据
[flutter_highlight](https://pub.dev/packages/flutter_highlight) | 代码高亮
[highlight](https://pub.dev/packages/highlight) | 代码高亮
[url_launcher](https://pub.dev/packages/url_launcher) | 用于打开链接
[visibility_detector](https://pub.dev/packages/visibility_detector) | 监听Widget是否可见
[scroll_to_index](https://pub.dev/packages/scroll_to_index) | 让Listview可以根据index来跳转
