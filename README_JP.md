言語：[簡体中文](https://github.com/asjqkkkk/markdown_widget/blob/master/README_ZH.md) | [英語](https://github.com/asjqkkkk/markdown_widget/blob/master/README.md) | [日本語](https://github.com/asjqkkkk/markdown_widget/blob/master/README_JP.md)

![画面](https://github.com/asjqkkkk/asjqkkkk.github.io/assets/30992818/4185bf1a-0be3-460d-ba12-9e4764f5c035)

# 📖markdown_widget

[![カバレッジステータス](https://coveralls.io/repos/github/asjqkkkk/markdown_widget/badge.svg?branch=dev)](https://coveralls.io/github/asjqkkkk/markdown_widget?branch=dev) [![pubパッケージ](https://img.shields.io/pub/v/markdown_widget.svg)](https://pub.dartlang.org/packages/markdown_widget) [![デモ](https://img.shields.io/badge/demo-online-brightgreen)](https://asjqkkkk.github.io/markdown_widget/)

シンプルで使いやすいマークダウンレンダリングコンポーネント。

- 見出しを通じてTOC（目次）機能をサポートし、迅速な位置決めが可能
- コードのハイライトをサポート
- すべてのプラットフォームをサポート

## 🚀使用方法

始める前に、[デモ](https://asjqkkkk.github.io/markdown_widget/)をクリックしてオンラインデモを試すことができます。

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
独自のColumnや他のリストウィジェットを使用したい場合は、`MarkdownGenerator`を使用できます。

```
  Widget buildMarkdown() =>
      Column(children: MarkdownGenerator().buildWidgets(data));
```

または`MarkdownBlock`を使用します。

```
  Widget buildMarkdown() =>
      SingleChildScrollView(child: MarkdownBlock(data: data));
```

## 🌠ナイトモード

`markdown_widget`はデフォルトでナイトモードをサポートしています。異なる`MarkdownConfig`を使用するだけで有効にできます。

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

デフォルトモード | ナイトモード
---|---
<img src="https://user-images.githubusercontent.com/30992818/211159089-ec4acd11-ee02-46f2-af4f-f8c47eb28410.png" width=400> | <img src="https://user-images.githubusercontent.com/30992818/211159108-4c20de2d-fb1d-4bcb-b23f-3ceb91291661.png" width=400>


## 🔗リンク

リンクのスタイルとクリックイベントをカスタマイズできます。例えば次のように

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

## 📜TOC（目次）機能

TOCの使用は非常に簡単です。

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

## 🎈コードのハイライト

コードのハイライトは複数のテーマをサポートしています。

```
import 'package:flutter_highlight/themes/a11y-light.dart';

  Widget buildMarkdown() => MarkdownWidget(
      data: data,
      config: MarkdownConfig(configs: [
        PreConfig(theme: a11yLightTheme),
      ]));
```

## 🧬全選択とコピー

全プラットフォームで全選択とコピー機能をサポートしています。

![image](https://user-images.githubusercontent.com/30992818/226107076-f32a919e-9a0c-4138-8a0b-266c6337e0af.png)

## 🌐Htmlタグ

現在のパッケージはMarkdownタグの変換のみを実装しているため、デフォルトではHTMLタグの変換をサポートしていません。ただし、この機能は拡張によってサポートできます。詳細については、[html_support.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/html_support.dart)の使用方法を参照してください。

こちらが[オンラインHTMLデモショーケース](https://asjqkkkk.github.io/markdown_widget/#/sample_html)です。

## 🧮Latexサポート

例にはLaTeXの簡単なサポートも含まれており、[latex.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/latex.dart)の実装を参照することで実装できます。

こちらが[オンラインlatexデモショーケース](https://asjqkkkk.github.io/markdown_widget/#/sample_latex)です。

## 🍑カスタムタグの実装

`MarkdownGeneratorConfig`に`SpanNodeGeneratorWithTag`を渡すことで、新しいタグとそのタグに対応する`SpanNode`を追加できます。また、既存のタグを使用して対応する`SpanNode`を上書きすることもできます。

また、`InlineSyntax`と`BlockSyntax`を使用してMarkdown文字列の解析ルールをカスタマイズし、新しいタグを生成することもできます。

カスタムタグの実装方法については、[このissue](https://github.com/asjqkkkk/markdown_widget/issues/79)を参照してください。

このパッケージを使用していて、良いアイデアや提案がある場合、または問題がある場合は、[プルリクエストやissueを開いてください](https://github.com/asjqkkkk/markdown_widget)。

# 🧾付録

`markdown_widget`で使用されている他のライブラリは次のとおりです。

パッケージ | 説明
---|---
[markdown](https://pub.dev/packages/markdown) | マークダウンデータの解析
[flutter_highlight](https://pub.dev/packages/flutter_highlight) | コードのハイライト
[highlight](https://pub.dev/packages/highlight) | コードのハイライト
[url_launcher](https://pub.dev/packages/url_launcher) | リンクのオープン
[visibility_detector](https://pub.dev/packages/visibility_detector) | ウィジェットの可視性のリスニング
[scroll_to_index](https://pub.dev/packages/scroll_to_index) | ListViewがインデックスにジャンプできるようにする
