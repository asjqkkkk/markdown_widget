import 'package:example/pages/edit_markdown_page.dart';
import 'package:example/pages/markdown_page.dart';
import 'package:example/pages/sample_latex_page.dart';
import 'package:example/state/root_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';

import 'home_page.dart';
import 'sample_html_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouterEnum.readme.path,
  routes: <RouteBase>[
    /// Application shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return HomePage(child: child, state: state);
      },
      observers: [_RouterObserver()],
      routes: <RouteBase>[
        _buildRoute(
            RouterEnum.readme,
            StoreConnector<RootState, String>(
              builder: (ctx, state) {
                final asset =
                    state == 'zh' ? 'assets/demo_zh.md' : 'assets/demo_en.md';
                return MarkdownPage(assetsPath: asset, key: Key(asset));
              },
              converter: ChangeLanguage.storeConverter,
            )),
        _buildRoute(RouterEnum.editor, EditMarkdownPage()),
        _buildRoute(RouterEnum.sample_latex, LatexPage()),
        _buildRoute(RouterEnum.sample_html, HtmlPage()),
      ],
    ),
  ],
);

GoRoute _buildRoute(RouterEnum path, Widget page) {
  return GoRoute(
    path: path.path,
    pageBuilder: (ctx, state) => _WebPage(
      key: state.pageKey,
      child: page,
      name: state.fullpath,
    ),
  );
}

class _RouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    print('didPush,  $name');
    if (name != null) {
      rootStore.dispatch(ChangeRouter(name));
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final name = newRoute?.settings.name;
    print('didReplace,  $name');
    if (name != null) {
      rootStore.dispatch(ChangeRouter(name));
    }
  }
}

class _WebPage extends CustomTransitionPage {
  _WebPage({
    required LocalKey key,
    required Widget child,
    String? name,
  }) : super(
          key: key,
          transitionsBuilder: (_, __, ___, child) {
            return FadeTransition(opacity: __, child: child);
          },
          child: child,
          name: name,
        );
}

enum RouterEnum {
  readme,
  editor,
  sample_latex,
  sample_html,
}

extension RoutePath on RouterEnum {
  String get path => '/$name';
}
