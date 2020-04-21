import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../platform_dector/platform_dector.dart';

class MarkdownPage extends StatefulWidget {
  final String assetsPath;
  final String markdownData;

  const MarkdownPage({Key key, this.assetsPath, this.markdownData})
      : super(key: key);

  @override
  _MarkdownPageState createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  ///key: [isEnglish] , value: data
  Map<bool, String> dataMap = {};
  String data;
  final TocController controller = TocController();
  bool isEnglish = true;

  @override
  void initState() {
    if (widget.assetsPath != null) {
      loadData(widget.assetsPath);
    } else {
      this.data = widget.markdownData;
    }
    super.initState();
  }

  void loadData(String assetsPath) {
    if (dataMap[isEnglish] != null) {
      data = dataMap[isEnglish];
      refresh();
      return;
    }
    rootBundle.loadString(assetsPath).then((data) {
      dataMap[isEnglish] = data;
      this.data = data;
      refresh();
    });
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = PlatformDetector.isMobile || PlatformDetector.isWebMobile;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text('Markdown Page'),
              elevation: 0.0,
              backgroundColor: Colors.black,
            )
          : null,
      drawer: (isMobile && widget.assetsPath != null)
          ? Drawer(child: buildTocList())
          : null,
      body: data == null
          ? Center(child: CircularProgressIndicator())
          : (isMobile ? buildMobileBody() : buildWebBody()),
      floatingActionButton: widget.assetsPath != null
          ? FloatingActionButton(
              onPressed: () {
                isEnglish = !isEnglish;
                loadData(isEnglish ? 'assets/demo_en.md' : 'assets/demo_zh.md');
              },
              child: Text(isEnglish ? '简中' : 'EN'),
            )
          : null,
    );
  }

  Widget buildTocList() => TocListWidget(controller: controller);

  Widget buildMarkdown() {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: MarkdownWidget(
        data: data,
        controller: controller,
        styleConfig: StyleConfig(
          pConfig: PConfig(linkGesture: (linkChild, url) {
            return GestureDetector(
              child: linkChild,
              onTap: () => _launchURL(url),
            );
          }),
        ),
      ),
    );
  }

  Widget buildMobileBody() {
    return buildMarkdown();
  }

  Widget buildWebBody() {
    return Row(
      children: <Widget>[
        Expanded(child: buildTocList()),
        Expanded(
          child: buildMarkdown(),
          flex: 3,
        )
      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
