# Introduction:

`markdown_widget` is based on the `markdown` component for rendering. `markdown` itself does not support rendering `html` text, so we need to use the `html` component to accomplish this task.

In the `markdown` component, `html` text will be filtered and finally put into a normal `Text` component, so we need to convert the content in the `Text`.

For the complete code, please see : [html_support.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/html_support.dart)

# 1. Customizing the TextNodeGenerator

First, customize a `SpanNode` to convert the content of `Text`:

```
class CustomTextNode extends ElementNode {  
  final String text;  
  final MarkdownConfig config;  
  final WidgetVisitor visitor;  
  
  CustomTextNode(this.text, this.config, this.visitor);  
  
  @override  
  void onAccepted(SpanNode parent) {  
    final textStyle = config.p.textStyle.merge(parentStyle);  
    children.clear();  
    if (!text.contains(htmlRep)) {  
      accept(TextNode(text: text, style: textStyle));  
      return;  
    }  
    final spans = parseHtml(  
      m.Text(text),  
      visitor:  
          WidgetVisitor(config: visitor.config, generators: visitor.generators),  
      parentStyle: parentStyle,  
    );  
    spans.forEach((element) {  
      accept(element);  
    });  
  }  
}
```

# 2. Customizing the SpanNode

You can use `parseHtml` to convert content containing `html` text into corresponding `Element` of `tag`. If you want to parse a specific tag, you need to implement the corresponding `SpanNode`. You can refer to [img.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/lib/widget/inlines/img.dart) and [video.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/video.dart) for more information.

# 3. Usage

To incorporate the custom content above into Markdown parsing:

```
Widget buildMarkdown() {  
  ...
  return MarkdownWidget(  
    data: _text,  
    markdownGeneratorConfig: MarkdownGeneratorConfig(  
        generators: [videoGeneratorWithTag]), 
        textGenerator: (node, config, visitor) =>  
		    CustomTextNode(node.textContent, config, visitor) 
  );  
}
```