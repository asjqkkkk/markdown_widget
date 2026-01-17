import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../markdown_custom/mermaid.dart';
import '../platform_detector/platform_detector.dart';
import '../state/root_state.dart';

class MermaidPage extends StatefulWidget {
  const MermaidPage({Key? key}) : super(key: key);

  @override
  State<MermaidPage> createState() => _MermaidPageState();
}

class _MermaidPageState extends State<MermaidPage> {
  String _text = '';
  bool isMobileDisplaying = false;

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/mermaid.md').then((data) {
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
        VerticalDivider(width: 3),
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
          final isDark = state.brightness == Brightness.dark;
          final config =
              isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
          var preConfig = isDark ? PreConfig.darkConfig : PreConfig();
          preConfig = preConfig.copy(
            contentWrapper: (child, code, language) {
              final mermaidWrapper = createMermaidWrapper(
                config: const MermaidConfig(),
                isDark: isDark,
                preConfig: preConfig,
              );
              return mermaidWrapper(child, code, language);
            },
          );
          return MarkdownWidget(
            data: _text,
            config: config.copy(configs: [preConfig]),
          );
        });
  }

  Widget descriptionWidget() {
    return StoreConnector<RootState, String>(
      builder: (ctx, state) {
        final asset = state == 'zh'
            ? 'assets/mermaid_description_zh.md'
            : 'assets/mermaid_description_en.md';
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
