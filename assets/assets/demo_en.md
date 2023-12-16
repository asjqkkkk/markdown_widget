Language：[简体中文](https://github.com/asjqkkkk/markdown_widget/blob/master/README_ZH.md) | [English](https://github.com/asjqkkkk/markdown_widget/blob/master/README.md)

# 📖markdown_widget

![screenshot](assets/script_medias/1676100926803.png)


[![Coverage Status](assets/script_medias/1675527914508.png)](https://coveralls.io/github/asjqkkkk/markdown_widget?branch=dev) [![pub package](assets/script_medias/1675527915217.png)](https://pub.dartlang.org/packages/markdown_widget) [![demo](assets/script_medias/1675527916292.png)](https://asjqkkkk.github.io/markdown_widget/)

A simple and easy-to-use markdown rendering component.

- Supports TOC (Table of Contents) function for quick location through Headings
- Supports code highlighting
- Supports all platforms

## 🚀Usage

Before starting, you can try out the online demo by clicking [demo](https://asjqkkkk.github.io/markdown_widget/)

```dart
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

```dart
  Widget buildMarkdown() =>
      Column(children: MarkdownGenerator().buildWidgets(data));
```

Or use `MarkdownBlock`

```dart
  Widget buildMarkdown() =>
      SingleChildScrollView(child: MarkdownBlock(data: data));
```

## 🌠Night mode

`markdown_widget` supports night mode by default. Simply use a different `MarkdownConfig` to enable it.

```dart
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

Default mode | Night mode
---|---
<img src="assets/script_medias/1675527917554.png" width=400> | <img src="assets/script_medias/1675527923101.png" width=400>


## 🔗Link

You can customize the style and click events of links, like this

```dart
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

```dart
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

## 🎈Highlighting  code

Highlighting code supports multiple themes.

```dart
import 'package:flutter_highlight/themes/a11y-light.dart';

  Widget buildMarkdown() => MarkdownWidget(
      data: data,
      config: MarkdownConfig(configs: [
        PreConfig(theme: a11yLightTheme),
      ]));
```

## 🧬Select All and Copy

Cross-platform support for Select All and Copy function.

![image](assets/script_medias/1679144416355.png)

## 🌐Html tag

As the current package only implements the conversion of Markdown tags, it does not support the conversion of HTML tags by default. However, this functionality can be supported through extension. You can refer to the usage in [html_support.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/html_support.dart) for more details.

Here is the [online HTML demo showcase](https://asjqkkkk.github.io/markdown_widget/#/sample_html)

## 🧮Latex support

The example also includes simple support for LaTeX, which can be implemented by referring to the implementation in [latex.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/latex.dart)

Here is the [online latex demo showcase](https://asjqkkkk.github.io/markdown_widget/#/sample_latex)

## 🍑Custom tag implementation

By passing a `SpanNodeGeneratorWithTag` to `MarkdownGeneratorConfig`, you can add new tags and the corresponding `SpanNode`s for those tags. You can also use existing tags to override the corresponding `SpanNode`s.

You can also customize the parsing rules for Markdown strings using `InlineSyntax` and `BlockSyntax`, and generate new tags.

You can refer to [this issue](https://github.com/asjqkkkk/markdown_widget/issues/79) to learn how to implement a custom tag.

If you have any good ideas or suggestions, or have any issues using this package, please feel free to [open a pull request or issue](https://github.com/asjqkkkk/markdown_widget).

# 🧾Appendix

Here are the other libraries used in `markdown_widget`

Packages | Descriptions
---|---
[markdown](https://pub.dev/packages/markdown) | Parsing markdown data
[flutter_highlight](https://pub.dev/packages/flutter_highlight) | Code highlighting
[highlight](https://pub.dev/packages/highlight) | Code highlighting
[url_launcher](https://pub.dev/packages/url_launcher) | Opening links
[visibility_detector](https://pub.dev/packages/visibility_detector) | Listening for visibility of a widget;
[scroll_to_index](https://pub.dev/packages/scroll_to_index) | Enabling ListView to jump to an index.
