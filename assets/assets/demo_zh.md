> 🚀 The markdown_widget 2.0 has now been released. The entire code has been completely redesigned according to the [CommonMark Spec 3.0](https://spec.commonmark.org/0.30/) compared to the 1.x versions. This brings a lot of breaking changes, but also more standardized markdown rendering logic and more robust and scalable code

Language：[简体中文](https://github.com/asjqkkkk/markdown_widget/blob/master/README_ZH.md) | [English](https://github.com/asjqkkkk/markdown_widget/blob/master/README.md)

# 📖markdown_widget

[![Coverage Status](https://coveralls.io/repos/github/asjqkkkk/markdown_widget/badge.png?branch=dev)](https://coveralls.io/github/asjqkkkk/markdown_widget?branch=dev) [![pub package](https://img.shields.io/pub/v/markdown_widget.png)](https://pub.dartlang.org/packages/markdown_widget) [![demo](https://img.shields.io/badge/demo-online-brightgreen.png)](http://oldben.gitee.io/markdown_widget)

A simple and easy-to-use markdown rendering component.

- Supports TOC (Table of Contents) function for quick location through Headings
- Supports code highlighting
- Supports all platforms

## 🚀Usage

Before starting, you can try out the online demo by clicking [demo](http://oldben.gitee.io/markdown_widget)

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
If you want to use your own Column or other list widget, you can use `MarkdownGenerator`

```
  Widget buildMarkdown() =>
      Column(children: MarkdownGenerator().buildWidgets(data));
```

## 🌠Night mode

`markdown_widget` supports night mode by default. Simply use a different `MarkdownConfig` to enable it.

```
  Widget buildMarkdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MarkdownWidget(
        data: data,
        config:
            isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig);
  }
```

Default mode | Night mode
---|---
<img src="https://user-images.githubusercontent.com/30992818/79996396-02f4cc80-84eb-11ea-9c17-cf14979708a1.png" width=400> | <img src="https://user-images.githubusercontent.com/30992818/79996326-ece70c00-84ea-11ea-811c-9ad7d1e81a19.png" width=400>


## 🔗Link

You can customize the style and click events of links, like this

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

## 📜TOC (Table of Contents) feature

Using the TOC is very simple

```
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

## 🎈Highlighting  code

Highlighting code supports multiple themes.

```
import 'package:flutter_highlight/themes/a11y-light.dart';

  Widget buildMarkdown() => MarkdownWidget(
      data: data,
      config: MarkdownConfig(configs: [
        PreConfig(theme: a11yLightTheme, language: 'dart'),
      ]));
```

## 🌐HTML tags

The current package only implements the conversion of Markdown tags, so it does not support the conversion of HTML tags by default. However, you can extend the package to support this feature by using the [html_support](https://github.com/asjqkkkk/markdown_widget/blob/1d549fd5c2d6b0172281d8bb66e367654b9d60f0/example/lib/markdown_custom/html_support.dart)

## 🍑Custom tag implementation

By passing a `SpanNodeGeneratorWithTag` to `MarkdownGeneratorConfig`, you can add new tags and the corresponding `SpanNode`s for those tags. You can also use existing tags to override the corresponding `SpanNode`s.

You can also customize the parsing rules for Markdown strings using `InlineSyntax` and `BlockSyntax`, and generate new tags.

You can refer to the usage of `SpanNodeGeneratorWithTag` in [video.dart](https://github.com/asjqkkkk/markdown_widget/blob/1d549fd5c2d6b0172281d8bb66e367654b9d60f0/example/lib/markdown_custom/video.dart) for an example.

If you have any good ideas or suggestions, or have any issues using this package, please feel free to [open a pull request or issue](https://github.com/asjqkkkk/markdown_widget).

# 🧾Appendix

Here are the other libraries used in `markdown_widget`

Packages | Descriptions
---|---
[markdown](https://pub.flutter-io.cn/packages/markdown) | Parsing markdown data
[flutter_highlight](https://pub.flutter-io.cn/packages/flutter_highlight) | Code highlighting
[highlight](https://pub.flutter-io.cn/packages/highlight) | Code highlighting
[url_launcher](https://pub.flutter-io.cn/packages/url_launcher) | Opening links
[visibility_detector](https://pub.flutter-io.cn/packages/visibility_detector) | Listening for visibility of a widget;
[scroll_to_index](https://pub.flutter-io.cn/packages/scroll_to_index) | Enabling ListView to jump to an index.
