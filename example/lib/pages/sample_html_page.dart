import 'package:example/markdown_custom/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../markdown_custom/custom_node.dart';
import '../platform_detector/platform_detector.dart';
import '../state/root_state.dart';
import '../widget/code_wrapper.dart';

class HtmlPage extends StatefulWidget {
  const HtmlPage({Key? key}) : super(key: key);

  @override
  State<HtmlPage> createState() => _HtmlPageState();
}

class _HtmlPageState extends State<HtmlPage> {
  String _text = '';
  bool isMobileDisplaying = false;

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/html.md').then((data) {
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
                  backgroundColor:
                      WidgetStateProperty.all(Colors.lightBlue.toOpacity(0.2))),
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
    return PlatformDetector.isAllMobile ? displayMarkdown() : buildWebBody();
  }

  Widget buildWebBody() {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: displayMarkdown(),
        )),
        VerticalDivider(
          width: 3,
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: descriptionWidget(),
        )),
      ],
    );
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
              generators: [videoGeneratorWithTag],
              textGenerator: (node, config, visitor) =>
                  CustomTextNode(node.textContent, config, visitor),
              richTextBuilder: (span) => Text.rich(span),
            ),
          );
        });
  }

  Widget descriptionWidget() {
    return StoreConnector<RootState, String>(
      builder: (ctx, state) {
        final asset = state == 'zh'
            ? 'assets/html_description_zh.md'
            : 'assets/html_description_en.md';
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
