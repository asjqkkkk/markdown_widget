import 'package:html/dom.dart' as h;
import 'package:markdown/markdown.dart' as m;
import 'package:html/parser.dart';
import '../tags/markdown_tags.dart';

///see this issue: https://github.com/dart-lang/markdown/issues/284#event-3216258013
///use [htmlToMarkdown] to convert HTML in [m.Text] to [m.Node]

///if [deep]>1 , parent will always not be null
void htmlToMarkdown(h.Node node, int deep, List<m.Node> mNodes,
    {m.Element parent}) {
  if (node == null) return;
  if (node is h.Text) {
    if (deep == 0) {
      mNodes.add(m.Text(node.text));
    } else {
      parent.children.add(m.Text(node.text));
    }
  } else if (node is h.Element) {

    final tag = node.localName;
    if (tag == img || tag == video) {
      final element = m.Element(tag, null);
      element.attributes.addAll(node.attributes.cast());
      mNodes.add(element);
    } else {
      final element = m.Element(tag, null);
      element.attributes.addAll(node.attributes.cast());
      final customElement = m.Element(other, [element]);

      if (deep == 0) {
        mNodes.add(customElement);
        if (node.nodes == null || node.nodes.isEmpty) return;
        node.nodes.forEach((child) {
          htmlToMarkdown(child, deep + 1, mNodes, parent: customElement);
        });
      } else {
        parent.children.add(customElement);
        if (node.nodes == null || node.nodes.isEmpty) return;
        node.nodes.forEach((child) {
          htmlToMarkdown(child, deep + 1, mNodes, parent: customElement);
        });
      }
    }
  }
}

final RegExp htmlRep = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

///return [true] if need parse [m.Node] to [h.Node]
bool needParseHtml(m.Node parentNode) =>
    (parentNode is m.Element && parentNode.tag != code);

///parse [m.Node] to [h.Node]
List<m.Node> parseHtml(
  m.Node node,
) {
  final text = node.textContent;
  if (!text.contains(htmlRep)) return [];
  h.DocumentFragment document = parseFragment(text);
  List<m.Node> nodes = [];
  document.nodes.forEach((element) {
    htmlToMarkdown(element, 0, nodes);
  });
  return nodes;
}
