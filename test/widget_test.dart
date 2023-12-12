import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'test_markdowns/network_image_mock.dart';
import 'widget_visitor_test.dart';
import 'package:path/path.dart' as p;

void main() {
  const testMarkdown = '''
| align left | centered | align right |
| :-- | :-: | --: |
| a | b | c | 
# a
## askdljakl
### akslfjkl
### akslfjkl
### akslfjkl
## askdljakl
### akslfjkl
### akslfjkl
### akslfjkl
## askdljakl
### akslfjkl
### akslfjkl
### akslfjkl
## askdljakl
### akslfjkl
### akslfjkl
### akslfjkl
## askdljakl
### akslfjkl
### akslfjkl
### akslfjkl
### akslfjklasjf22
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf
### akslfjklasjf33
- asdasd
- asdasda
- asdasdas
1. asdasdasd
2. asdasdasd
3. asdasdasd''';

  testWidgets('test toc widget', (tester) async {
    final tocController = TocController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Directionality(
            textDirection: TextDirection.ltr,
            child: TocWidget(
              controller: tocController,
              itemBuilder: (data) {
                if (data.index == 0) return Container();
                return null;
              },
            )),
      ),
    ));
    final list = List.generate(10, (index) {
      final heading = HeadingNode(H1Config(), WidgetVisitor());
      heading.accept(TextNode(text: "$index"));
      return Toc(
        node: heading,
        widgetIndex: index,
        selfIndex: index,
      );
    });
    tocController.setTocList(list);
    print(tocController.tocList);
    tocController.jumpToIndexCallback = (i) {
      print('jumpToIndexCallback:$i');
    };
    tocController.onIndexChanged(5);
    tocController.jumpToIndex(2);
    await tester.scrollUntilVisible(
        find.text('8'), // what you want to find // widget you want to scroll
        200);
    final gesture = await tester.startGesture(Offset(0, 300));
    gesture.up();
    tocController.setTocList([list.removeLast()]);
    tocController.dispose();
  });

  testWidgets('test markdown widget', (tester) async {
    final tocController = TocController();
    tocController.jumpToIndexCallback = (i) {
      print('jumpToIndexCallback  :$i');
    };
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    String text = '';
    late StateSetter setter;
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Directionality(
            textDirection: TextDirection.ltr,
            child: StatefulBuilder(builder: (context, callback) {
              ctx = context;
              setter = callback;
              return MarkdownWidget(
                data: text,
                tocController: tocController,
                config: MarkdownConfig(configs: [
                  TableConfig(wrapper: (child) => Container(child: child))
                ]),
              );
            })),
      ),
    ));
    tocController.jumpToIndex(0);
    setter(() {
      text = testMarkdown;
    });
    await tester.scrollUntilVisible(find.text('akslfjklasjf22'), 50);
    tocController.jumpToIndex(0);
    await tester.scrollUntilVisible(find.text('akslfjklasjf33'), 50);
    final widget = tester.firstWidget(find.byWidgetPredicate(
            (widget) => widget is NotificationListener<UserScrollNotification>))
        as NotificationListener<UserScrollNotification>;
    widget.onNotification?.call(UserScrollNotification(
        metrics: FixedScrollMetrics(
            minScrollExtent: 0,
            maxScrollExtent: 1,
            pixels: 1,
            viewportDimension: 1,
            axisDirection: AxisDirection.down,
            devicePixelRatio: 1),
        context: ctx,
        direction: ScrollDirection.forward));
  });

  testWidgets('test markdown block', (tester) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (context, callback) {
          return SingleChildScrollView(
            child: MarkdownBlock(data: testMarkdown),
          );
        }),
      ),
    ));
  });

  testWidgets('test other widgets', (tester) async {
    final jsonList = getTestJsonList();
    for (var json in jsonList) {
      final content = json['markdown'];
      final widgets = testMarkdownGenerator(content);
      for (var widget in widgets) {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: Directionality(
                    textDirection: TextDirection.ltr, child: widget)),
          ));
        });
      }
    }
  });

  testWidgets('test for asset file', (tester) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    final current = Directory.current;
    final jsonPath = p.join(current.path, 'example', 'assets', 'editor.md');
    File jsonFile = File(jsonPath);
    final content = jsonFile.readAsStringSync();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Directionality(
                textDirection: TextDirection.ltr,
                child: MarkdownWidget(
                  data: content,
                  config: MarkdownConfig.defaultConfig.copy(configs: [
                    BlockquoteConfig(),
                    ListConfig(),
                    TableConfig(),
                    LinkConfig(),
                    ImgConfig(),
                    CheckBoxConfig(),
                  ]),
                  markdownGenerator: MarkdownGenerator(generators: [
                    SpanNodeGeneratorWithTag(
                        tag: 'test',
                        generator: (e, config, visitor) {
                          return TextNode(text: e.textContent);
                        })
                  ]),
                ))),
      ));
    });
  });

  testWidgets('MCheckBox test', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: Directionality(
              textDirection: TextDirection.ltr,
              child: ListView(
                children: [
                  MCheckBox(checked: false),
                  MCheckBox(checked: true),
                ],
              ))),
    ));
  });

  testWidgets('test ImageViewer iconButton pressed', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
          home: ImageViewer(child: Container(width: 100, height: 100))));
    });
    final buttons = tester
        .widgetList(find.byWidgetPredicate((widget) => widget is IconButton));
    for (var button in buttons) {
      (button as IconButton).onPressed?.call();
    }
  });

  testWidgets('test ImageViewer gesture taped', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
          home: ImageViewer(child: Container(width: 100, height: 100))));
    });
    await (await tester.startGesture(Offset(50, 50))).up();
  });
}
