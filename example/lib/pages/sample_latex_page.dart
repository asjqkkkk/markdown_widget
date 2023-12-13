import 'package:example/platform_detector/platform_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../markdown_custom/latex.dart';
import '../state/root_state.dart';
import '../widget/code_wrapper.dart';

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
    return StoreConnector<RootState, ThemeState>(
        converter: ThemeState.storeConverter,
        builder: (context, state) {
          final config =
              isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
          final codeWrapper = (child, text, language) =>
              CodeWrapperWidget(child, text, language);
          return MarkdownWidget(
            data: _text,
            config: config.copy(configs: [
              isDark
                  ? PreConfig.darkConfig.copy(wrapper: codeWrapper)
                  : PreConfig().copy(wrapper: codeWrapper)
            ]),
            markdownGenerator: MarkdownGenerator(
              generators: [latexGenerator],
              inlineSyntaxList: [LatexSyntax()],
              richTextBuilder: (span) => Text.rich(span, textScaleFactor: 1),
            ),
          );
        });
  }

  Widget descriptionWidget() {
    return StoreConnector<RootState, String>(
      builder: (ctx, state) {
        final asset = state == 'zh'
            ? 'assets/latex_description_zh.md'
            : 'assets/latex_description_en.md';
        return FutureBuilder<String>(
            future: rootBundle.loadString(asset),
            builder: (context, snapshot) {
              return MarkdownWidget(
                data: snapshot.data ?? '',
                config: isDark
                    ? MarkdownConfig.darkConfig
                    : MarkdownConfig.defaultConfig,
              );
            });
      },
      converter: ChangeLanguage.storeConverter,
    );
  }
}
