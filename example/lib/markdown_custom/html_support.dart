import 'package:html/dom.dart' as h;
import 'package:markdown/markdown.dart' as m;
import 'package:html/parser.dart';
import 'package:markdown_widget/config/configs.dart';

///see this issue: https://github.com/dart-lang/markdown/issues/284#event-3216258013
///use [htmlToMarkdown] to convert HTML in [m.Text] to [m.Node]
void htmlToMarkdown(h.Node? node, int deep, List<m.Node> mNodes) {
  if (node == null) return;
  if (node is h.Text) {
    mNodes.add(m.Text(node.text));
  } else if (node is h.Element) {
    final tag = node.localName;
    List<m.Node> children = [];
    node.children.forEach((e) {
      htmlToMarkdown(e, deep + 1, children);
    });
    if (tag == MarkdownTag.img.name || tag == 'video') {
      final element = m.Element(tag!, children);
      element.attributes.addAll(node.attributes.cast());
      mNodes.add(element);
    } else {
      final element = m.Element(tag!, children);
      element.attributes.addAll(node.attributes.cast());
      mNodes.add(element);
    }
    if (node.nodes.isEmpty) return;
    node.nodes.forEach((n) {
      htmlToMarkdown(n, deep + 1, mNodes);
    });
  }
}

final RegExp htmlRep = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

///parse [m.Node] to [h.Node]
List<m.Node> parseHtml(m.Text node) {
  final text = node.textContent;
  if (!text.contains(htmlRep)) return [node];
  h.DocumentFragment document = parseFragment(text);
  List<m.Node> nodes = [];
  document.nodes.forEach((element) {
    htmlToMarkdown(element, 0, nodes);
  });
  return nodes;
}
