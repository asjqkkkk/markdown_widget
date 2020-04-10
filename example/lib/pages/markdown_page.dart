import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:example/widgets/toc_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown_widget/config/platform.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownPage extends StatefulWidget {
  final String assetsPath;
  final String markdownData;

  const MarkdownPage({Key key, this.assetsPath, this.markdownData}) : super(key: key);

  @override
  _MarkdownPageState createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  String data;
  final TocController controller = TocController();
  LinkedHashMap<int, Toc> tocList;

  @override
  void initState() {
    if(widget.assetsPath != null) {
      rootBundle.loadString(widget.assetsPath).then((data) {
        this.data = data;
        refresh();
      });
    } else {
      this.data = widget.markdownData;
    }
    super.initState();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = PlatformDetector().isMobile();

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text('Markdown Page'),
              elevation: 0.0,
              backgroundColor: Colors.black,
            )
          : null,
      drawer: (isMobile && widget.assetsPath != null) ? Drawer(child: buildTocList()) : null,
      body: data == null
          ? Center(child: CircularProgressIndicator())
          : (isMobile ? buildMobileBody() : buildWebBody()),
    );
  }

  Widget buildTocList() => TocListWidget(
        tocList: tocList,
        controller: controller,
      );

  Widget buildMarkdown() {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: MarkdownWidget(
        data: data,
        controller: controller,
        lazyLoad: false,
        tocListBuilder: (list) {
          tocList = list;
          refresh();
        },
        styleConfig: StyleConfig(
          pConfig: PConfig(
            onLinkTap: (url) => _launchURL(url),
          ),
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
