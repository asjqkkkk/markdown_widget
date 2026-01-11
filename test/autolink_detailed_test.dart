import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/config/all.dart';

void main() {
  group('AutolinkNoLeadingSpaceSyntax detailed tests', () {
    test('should parse URL after letter with extensionSet', () {
      final customSyntax = AutolinkNoLeadingSpaceSyntax();
      
      final document = m.Document(
        extensionSet: m.ExtensionSet.gitHubFlavored,
        encodeHtml: false,
        inlineSyntaxes: [customSyntax],
      );
      
      final testCase = 'awww.baidu.com';
      print('\n=== Testing: "$testCase" ===');
      
      final lines = [testCase];
      final nodes = document.parseLines(lines);
      
      print('Nodes: $nodes');
      
      // Check if we have an Element with tag 'a'
      bool foundLink = false;
      void checkNodes(List<m.Node> nodes) {
        for (final node in nodes) {
          if (node is m.Element) {
            print('Element tag: ${node.tag}, children: ${node.children}');
            if (node.tag == 'a') {
              foundLink = true;
              print('Found link! href: ${node.attributes['href']}, text: ${node.textContent}');
            }
            if (node.children != null) {
              checkNodes(node.children!);
            }
          } else if (node is m.Text) {
            print('Text: "${node.textContent}"');
          }
        }
      }
      
      checkNodes(nodes);
      expect(foundLink, isTrue, reason: 'Should find a link element');
    });
    
    test('should work with text before URL', () {
      final customSyntax = AutolinkNoLeadingSpaceSyntax();
      
      final document = m.Document(
        extensionSet: m.ExtensionSet.gitHubFlavored,
        encodeHtml: false,
        inlineSyntaxes: [customSyntax],
      );
      
      final testCase = 'Visit www.example.com today';
      print('\n=== Testing: "$testCase" ===');
      
      final lines = [testCase];
      final nodes = document.parseLines(lines);
      
      final renderer = m.HtmlRenderer();
      final html = renderer.render(nodes);
      print('HTML: $html');
      
      // Should contain an <a> tag with www.example.com
      expect(html.contains('<a'), isTrue);
      expect(html.contains('www.example.com'), isTrue);
    });
  });
}
