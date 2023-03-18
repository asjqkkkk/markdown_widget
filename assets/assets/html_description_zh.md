# 介绍

`markdown_widget`是基于`markdown`组件来进行渲染的，`markdown`本身并不支持`html`文本的渲染，所以这里需要用到 `html`组件来完成这项工作

在`markdown`组件中，会将`html`文本进行过滤，最终被放入到普通的`Text`中，所以我们需要对 `Text`中的内容进行转换

完整代码请见：[html_support.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/html_support.dart)

# 1. 自定义TextNodeGenerator

首先自定义一个SpanNode来转换Text内容：

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



# 2. 自定义SpanNode

通过 `parseHtml` 可以将包含 `html` 文本的内容，转换为对应 `tag` 的 `Element` ，如果想解析某个指定的tag，则需要实现对应的 `SpanNode`，这里可以参考 [img.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/lib/widget/inlines/img.dart) 和 [video.dart](https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/video.dart)


# 3. 使用

将上面自定义的内容加入到Markdown的解析中：

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

