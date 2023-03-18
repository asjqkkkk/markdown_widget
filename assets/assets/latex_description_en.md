# Introduction

To parse the content wrapped in `$$` and `$` as mathematical expressions based on **Latex**, the following steps need to be taken:

-   Custom `tag`: corresponds to the Latex tag to be parsed.
-   Custom `SpanNode`: converts the content to be parsed into an `InlineSpan` that can be inserted into rich text.
-   Custom `Syntax`: used to filter out Latex content in markdown text and parse it.

The complete code can be found in : [latex.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/latex.dart)

# 1. Custom tag

Customize a tag:

```
const _latexTag = 'latex';
```

Associate this tag with the SpanNode to be defined below:

```
SpanNodeGeneratorWithTag latexGenerator = SpanNodeGeneratorWithTag(  
    tag: _latexTag,  
    generator: (e, config, visitor) =>  
        LatexNode(e.attributes, e.textContent, config));
```
# 2. Custom SpanNode

Customize a SpanNode and display the filtered Latex content using the `flutter_math_fork` plugin.

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

# 3. Custom Syntax

By customizing Syntax to filter content wrapped by `$$` and `$`, regular expressions need to be used here. (As an example, this expression may not be accurate enough.)

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

# 4. Usage

To incorporate the custom content above into Markdown parsing:

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