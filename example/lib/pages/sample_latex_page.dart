import 'package:example/platform_detector/platform_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../markdown_custom/latex.dart';

class LatexPage extends StatefulWidget {
  const LatexPage({Key? key}) : super(key: key);

  @override
  State<LatexPage> createState() => _LatexPageState();
}

class _LatexPageState extends State<LatexPage> {
  String _text = '';
  bool isMobileDisplaying = false;

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/latex.md').then((data) {
      _text = data;
      refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: PlatformDetector.isAllMobile
          ? TextButton.icon(
              onPressed: () {
                isMobileDisplaying = !isMobileDisplaying;
                refresh();
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Colors.lightBlue.withOpacity(0.2))),
              icon: Icon(isMobileDisplaying
                  ? Icons.arrow_back_ios
                  : Icons.document_scanner),
              label: Text(isMobileDisplaying ? 'source' : 'explain'),
            )
          : null,
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isMobileDisplaying) return descriptionWidget();
    return PlatformDetector.isAllMobile ? buildMobileBody() : buildWebBody();
  }

  Widget buildWebBody() {
    return Row(
      children: [
        Expanded(child: displayMarkdown()),
        VerticalDivider(
          width: 3,
        ),
        Expanded(child: descriptionWidget()),
      ],
    );
  }

  Widget buildMobileBody() {
    return displayMarkdown();
  }

  Widget displayMarkdown() {
    return MarkdownWidget(
      data: _text,
      markdownGeneratorConfig: MarkdownGeneratorConfig(
          generators: [latexGenerator], inlineSyntaxList: [LatexSyntax()]),
    );
  }

  Widget descriptionWidget() {
    return Center(child: Text('To be continued...'));
  }
}
