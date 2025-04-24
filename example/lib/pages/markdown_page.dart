import 'package:example/markdown_custom/custom_toc_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown_widget/toc_widget.dart';

import '../markdown_custom/custom_node.dart';
import '../markdown_custom/latex.dart';
import '../markdown_custom/video.dart';
import '../platform_detector/platform_detector.dart';
import '../state/root_state.dart';
import '../widget/code_wrapper.dart';

class MarkdownPage extends StatefulWidget {
  final String? assetsPath;
  final String? markdownData;

  const MarkdownPage({Key? key, this.assetsPath, this.markdownData})
      : assert(assetsPath != null || markdownData != null),
        super(key: key);

  @override
  _MarkdownPageState createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  ///key: [isEnglish] , value: data
  Map<bool, String> dataMap = {};
  String? data;
  bool isEnglish = true;
  bool customToc = true;
  final TocController controller = TocController();

  bool get isMobile => PlatformDetector.isAllMobile;

  @override
  void initState() {
    if (widget.assetsPath != null) {
      loadData(widget.assetsPath!);
    } else {
      this.data = widget.markdownData!;
    }
    super.initState();
  }

  void loadData(String assetsPath) {
    if (dataMap[isEnglish] != null) {
      data = dataMap[isEnglish]!;
      refresh();
      return;
    }
    rootBundle.loadString(assetsPath).then((data) {
      dataMap[isEnglish] = data;
      this.data = data;
      refresh();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data == null
          ? Center(child: CircularProgressIndicator())
          : (isMobile ? buildMobileBody() : buildWebBody()),
      floatingActionButton: widget.assetsPath != null
          ? isMobile
              ? FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context, builder: (ctx) => buildTocList());
                  },
                  child: Icon(Icons.format_list_bulleted),
                  heroTag: 'list',
                )
              : SizedBox()
          : null,
    );
  }

  Widget buildTocList() {
    return TocWidget(controller: controller);
  }

  Widget buildMarkdown() {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: StoreConnector<RootState, ThemeState>(
          converter: ThemeState.storeConverter,
          builder: (context, snapshot) {
            final config = isDark
                ? MarkdownConfig.darkConfig
                : MarkdownConfig.defaultConfig;
            final codeWrapper = (child, text, language) =>
                CodeWrapperWidget(child, text, language);
            return MarkdownWidget(
                data: data!,
                config: config.copy(configs: [
                  isDark
                      ? PreConfig.darkConfig.copy(wrapper: codeWrapper)
                      : PreConfig().copy(wrapper: codeWrapper)
                ]),
                tocController: controller,
                markdownGenerator: MarkdownGenerator(
                  generators: [videoGeneratorWithTag, latexGenerator],
                  inlineSyntaxList: [LatexSyntax()],
                  textGenerator: (node, config, visitor) =>
                      CustomTextNode(node.textContent, config, visitor),
                  richTextBuilder: (span) => Text.rich(span),
                ));
          }),
    );
  }

  Widget buildCodeBlock(Widget child, String text, bool isEnglish) {
    return Stack(
      children: <Widget>[
        child,
        Container(
          margin: EdgeInsets.only(top: 5, right: 5),
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Widget toastWidget = Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 50),
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xff006EDF), width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(
                        4,
                      )),
                      color: Color(0xff007FFF)),
                  width: 150,
                  height: 40,
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        isEnglish ? 'Copy successful' : '复制成功',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
              ToastWidget().showToast(context, toastWidget, 500);
            },
            icon: Icon(
              Icons.content_copy,
              size: 10,
            ),
          ),
        )
      ],
    );
  }

  Widget buildMobileBody() {
    return buildMarkdown();
  }

  Widget buildWebBody() {
    return Row(
      children: <Widget>[
        if (!customToc) Expanded(child: buildTocList()),
        Expanded(
          child: buildMarkdown(),
          flex: 3,
        ),
        if (customToc) CustomTocWidget(controller: controller),
      ],
    );
  }
}

class ToastWidget {
  ToastWidget._internal();

  static ToastWidget? _instance;

  factory ToastWidget() {
    _instance ??= ToastWidget._internal();
    return _instance!;
  }

  bool isShowing = false;

  void showToast(BuildContext context, Widget widget, int milliseconds) {
    if (!isShowing) {
      isShowing = true;
      FullScreenDialog.getInstance().showDialog(
        context,
        widget,
      );
      Future.delayed(
          Duration(
            milliseconds: milliseconds,
          ), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          isShowing = false;
        } else {
          isShowing = false;
        }
      });
    }
  }
}

class FullScreenDialog {
  static FullScreenDialog? _instance;

  static FullScreenDialog getInstance() {
    if (_instance == null) {
      _instance = FullScreenDialog._internal();
    }
    return _instance!;
  }

  FullScreenDialog._internal();

  void showDialog(BuildContext context, Widget child) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (ctx, anm1, anm2) {
          return child;
        }));
  }
}
