import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'test_markdowns/network_image_mock.dart';
import 'package:highlight/highlight.dart' as hi;

void main() {
  test('test img node', () {
    final imgNode =
        ImageNode({'width': '100', 'height': '200', 'src': ''}, ImgConfig());
    imgNode.build();
  });

  testWidgets('test for link node', (tester) async {
    final linkNode = LinkNode({'href': ''}, LinkConfig());
    linkNode.children.add(
        ImageNode({'width': '100', 'height': '100', 'src': ''}, ImgConfig()));
    linkNode.children.add(TextNode(text: 'test'));
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Directionality(
                textDirection: TextDirection.ltr,
                child: Text.rich(linkNode.build()))),
      ));
    });
    await (await tester.startGesture(Offset(0, 0))).up();
    await (await tester.startGesture(Offset(0, 100))).up();
  });

  testWidgets('test for link with custom taps', (tester) async{
    final linkNode = LinkNode({'href': ''}, LinkConfig(onTap: (url){
      print('on url taped:$url');
    }));
    linkNode.children.add(TextNode(text: 'test'));
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Directionality(
                textDirection: TextDirection.ltr,
                child: Text.rich(linkNode.build()))),
      ));
    });
    await (await tester.startGesture(Offset(0, 0))).up();
    await (await tester.startGesture(Offset(0, 100))).up();
  });

  test('convertHiNodes test', (){
    final nodes = [hi.Node(className: 'aaa', value: 'I\'m value')];
    convertHiNodes(nodes, {}, null);
  });
}
