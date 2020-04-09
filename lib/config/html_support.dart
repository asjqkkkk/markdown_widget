import 'package:html/dom.dart' as h;
import 'package:markdown/markdown.dart' as m;
import 'package:html/parser.dart';
import '../tags/markdown_tags.dart';

///see this issue: https://github.com/dart-lang/markdown/issues/284#event-3216258013
///use [htmlToMarkdown] to convert HTML in [m.Text] to [m.Node]
void htmlToMarkdown(h.Node node, int deep, List<m.Node> mNodes) {
  if (node == null) return;
  if (node is h.Text) {
    mNodes.add(m.Text(node.text));
  } else if (node is h.Element) {
    final tag = node.localName;
    if(tag == img || tag == video){
      final element = m.Element(tag, null);
      element.attributes.addAll(node.attributes.cast());
      mNodes.add(element);
    }
    if (node.nodes == null || node.nodes.isEmpty) return;
    node.nodes.forEach((n) {
      htmlToMarkdown(n, deep + 1, mNodes);
    });
  }
}

final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);


List<m.Node> parseHtml(m.Node node,){
  final text = node.textContent;
  if(!text.contains(exp)) return [];
  h.Document document = parse(text);
  List<m.Node> nodes = [];
  document.nodes.forEach((element) {
    htmlToMarkdown(element, 0, nodes);
  });
  return nodes;
}