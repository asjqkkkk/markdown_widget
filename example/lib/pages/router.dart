import 'package:example/pages/edit_markdown_page.dart';
import 'package:example/pages/markdown_page.dart';
import 'package:example/pages/sample_latex_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_page.dart';

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
      routes: <RouteBase>[
        _buildRoute(
            RouterEnum.readme, MarkdownPage(assetsPath: 'assets/demo_en.md')),
        _buildRoute(RouterEnum.editor, EditMarkdownPage()),
        _buildRoute(RouterEnum.sample_latex, LatexPage()),
        _buildRoute(RouterEnum.sample_html, LatexPage()),
      ],
    ),
  ],
);

GoRoute _buildRoute(RouterEnum path, Widget page) {
  return GoRoute(
    path: path.path,
    pageBuilder: (ctx, state) => _WebPage(key: state.pageKey, child: page),
  );
}

class _WebPage extends CustomTransitionPage {
  _WebPage({
    required LocalKey key,
    required Widget child,
  }) : super(
            key: key,
            transitionsBuilder: (_, __, ___, child) {
              return FadeTransition(opacity: __, child: child);
            },
            child: child);
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
