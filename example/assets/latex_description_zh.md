# 介绍

如果想要将被 `$$`和 `$`所包裹的内容解析为基于 **Latex** 的数学表达式，首先需要准备以下内容：
- 自定义的 `tag` ：对应被解析的Latex标签
- 自定义的 `SpanNode`：将被解析的内容，转换成可以插入富文本展示的 `InlineSpan`
- 自定义的 `Syntax`：用于在markdown文本中筛选出Latex内容，并解析

完整代码请见：[latex.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/latex.dart)

# 1. 自定义tag

自定义一个tag：

```
const _latexTag = 'latex';
```

同时将该tag与接下来将要自定义的SpanNode相关联

```
SpanNodeGeneratorWithTag latexGenerator = SpanNodeGeneratorWithTag(  
    tag: _latexTag,  
    generator: (e, config, visitor) =>  
        LatexNode(e.attributes, e.textContent, config));
```

# 2. 自定义SpanNode

自定义SpanNode，并通过插件 `flutter_math_fork` 来展示被筛选出的 Latex内容

```
class LatexNode extends SpanNode {  
  final Map<String, String> attributes;  
  final String textContent;  
  final MarkdownConfig config;  
  
  LatexNode(this.attributes, this.textContent, this.config);  
  
  @override  
  InlineSpan build() {  
    final content = attributes['content'] ?? '';  
    final isInline = attributes['isInline'] == 'true';  
    final style = parentStyle ?? config.p.textStyle;  
    if (content.isEmpty) return TextSpan(style: style, text: textContent);  
    final latex = Math.tex(  
      content,  
      mathStyle: MathStyle.text,  
      textStyle: style,  
      textScaleFactor: 1,  
      onErrorFallback: (error) {  
        return Text(  
          '$textContent',  
          style: style.copyWith(color: Colors.red),  
        );  
      },  
    );  
    return WidgetSpan(  
        child: !isInline  
            ? Container(  
                width: double.infinity,  
                child: Center(child: latex),  
                margin: EdgeInsets.symmetric(vertical: 16),  
              )  
            : latex);  
  }  
}
```

# 3. 自定义Syntax

通过自定义的Syntax去筛选被 `$$`和 `$`所包裹的内容，这里需要使用到正则表达式(作为例子，这个表达式也许不够准确)

```
class LatexSyntax extends m.InlineSyntax {  
  LatexSyntax() : super(r'(\$\$[\s\S]+\$\$)|(\$.+\$)');  
  
  @override  
  bool onMatch(m.InlineParser parser, Match match) {  
    final input = match.input;  
    final matchValue = input.substring(match.start, match.end);  
    String content = '';  
    bool isInline = true;  
    const blockSyntax = '\$\$';  
    const inlineSyntax = '\$';  
    if (matchValue.startsWith(blockSyntax) &&  
        matchValue.endsWith(blockSyntax) &&  
        (matchValue != blockSyntax)) {  
      content = matchValue.substring(2, matchValue.length - 2);  
      isInline = false;  
    } else if (matchValue.startsWith(inlineSyntax) &&  
        matchValue.endsWith(inlineSyntax) &&  
        matchValue != inlineSyntax) {  
      content = matchValue.substring(1, matchValue.length - 1);  
    }  
    m.Element el = m.Element.text(_latexTag, matchValue);  
    el.attributes['content'] = content;  
    el.attributes['isInline'] = '$isInline';  
    parser.addNode(el);  
    return true;  
  }  
}
```


# 4. 使用

将上面自定义的内容加入到Markdown的解析中：

```
Widget buildMarkdown() {  
  ...
  return MarkdownWidget(  
    data: _text,  
    markdownGeneratorConfig: MarkdownGeneratorConfig(  
        generators: [latexGenerator], inlineSyntaxList: [LatexSyntax()]),  
  );  
}
```

