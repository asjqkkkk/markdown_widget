import 'package:example/pages/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../platform_detector/platform_detector.dart';
import '../state/root_state.dart';
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

  bool get isMobile => PlatformDetector.isAllMobile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2),
      child: Column(
        children: [
          Expanded(
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
                  isSelected: isSelected(RouterEnum.sample_latex),
                  isCollapsed: isCollapsed,
                  onTap: () {
                    GoRouter.of(context).go(RouterEnum.sample_latex.path);
                    if (isMobile) Navigator.of(context).pop();
                  },
                ),
                NavItem(
                  title: 'Sample: Html',
                  trailing: '🌐',
                  isSelected: isSelected(RouterEnum.sample_html),
                  isCollapsed: isCollapsed,
                  onTap: () {
                    GoRouter.of(context).go(RouterEnum.sample_html.path);
                    if (isMobile) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          if (!isMobile)
            Column(
              children: [
                buildThemeButton(context),
                buildLanguageButton(),
              ],
            )
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

  Widget buildThemeButton(BuildContext context) {
    if (!isCollapsed) {
      return TextButton.icon(
          onPressed: () => rootStore.dispatch(new ChangeThemeEvent()),
          icon: Icon(
            isDark ? Icons.brightness_5_outlined : Icons.brightness_2_outlined,
            size: 14,
          ),
          label: Text(isDark ? 'Light' : 'Dark'));
    }
    return TextButton(
        onPressed: () => rootStore.dispatch(new ChangeThemeEvent()),
        child: Icon(
          isDark ? Icons.brightness_5_outlined : Icons.brightness_2_outlined,
          size: 14,
        ));
  }

  Widget buildLanguageButton() {
    return StoreConnector<RootState, String>(
        converter: ChangeRouter.storeConverter,
        builder: (context, state) {
          if (state == RouterEnum.editor.path) return Container();
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: TextButton(
              onPressed: () {
                rootStore.dispatch(new ChangeLanguage());
              },
              child: isCollapsed
                  ? Text(rootStore.state.language == 'en' ? '中' : 'En')
                  : Text(rootStore.state.language == 'en' ? '简中' : 'English'),
            ),
          );
        });
  }

  bool isSelected(RouterEnum routerEnum) => router == routerEnum.path;
}
