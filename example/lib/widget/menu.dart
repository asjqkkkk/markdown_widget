import 'package:example/pages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../platform_detector/platform_detector.dart';
import 'navigation_item.dart';

class Menu extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback? onCollapsed;
  final VoidCallback? onUnCollapsed;
  final String router;

  const Menu({
    Key? key,
    this.isCollapsed = false,
    this.onCollapsed,
    this.onUnCollapsed,
    this.router = '',
  }) : super(key: key);

  bool get isMobile =>
      PlatformDetector.isAllMobile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2),
      child: ListView(
        children: [
          buildMenuButton(),
          NavItem(
            title: 'README.md',
            trailing: '📚',
            isCollapsed: isCollapsed,
            isSelected: isSelected(RouterEnum.readme),
            onTap: () {
              GoRouter.of(context).go(RouterEnum.readme.path);
              if (isMobile) Navigator.of(context).pop();
            },
          ),
          NavItem(
            title: 'Markdown Editor',
            trailing: '📝',
            isCollapsed: isCollapsed,
            isSelected: isSelected(RouterEnum.editor),
            onTap: () {
              GoRouter.of(context).go(RouterEnum.editor.path);
              if (isMobile) Navigator.of(context).pop();
            },
          ),
          NavItem(
            title: 'Sample: Latex',
            trailing: '🧮',
            isCollapsed: isCollapsed,
            onTap: () {
              GoRouter.of(context).go(RouterEnum.sample_latex.path);
              if (isMobile) Navigator.of(context).pop();
            },
          ),
          NavItem(
            title: 'Sample: Html',
            trailing: '🌐',
            isCollapsed: isCollapsed,
            onTap: () {
              GoRouter.of(context).go(RouterEnum.sample_html.path);
              if (isMobile) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget buildMenuButton() {
    if (isCollapsed) {
      return SizedBox(
        height: 48,
        child: InkWell(
            onTap: onUnCollapsed,
            child: Icon(Icons.keyboard_double_arrow_right)),
      );
    }
    return ListTile(
      leading: FlutterLogo(),
      title: Text('Markdown', style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: InkWell(
        child: Icon(Icons.keyboard_double_arrow_left),
        onTap: onCollapsed,
      ),
      onTap: () {
        launchUrl(Uri.parse('https://github.com/asjqkkkk/markdown_widget'));
      },
      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    );
  }

  bool isSelected(RouterEnum routerEnum) => router == routerEnum.path;
}
