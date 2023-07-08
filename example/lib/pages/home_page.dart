import 'package:example/widget/menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../platform_detector/platform_detector.dart';
import '../state/root_state.dart';

class HomePage extends StatefulWidget {
  final Widget child;
  final GoRouterState state;

  const HomePage({Key? key, required this.child, required this.state})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool get isMobile => PlatformDetector.isAllMobile;

  int selectIndex = 0;
  double leftLayoutWidth = 220;
  bool isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(
                '${widget.state.location}',
              ),
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                    onPressed: () => rootStore.dispatch(new ChangeLanguage()),
                    icon: Text(rootStore.state.language == 'en' ? '中' : 'En')),
                IconButton(
                    onPressed: () => rootStore.dispatch(new ChangeThemeEvent()),
                    icon: Icon(
                      isDark
                          ? Icons.brightness_5_outlined
                          : Icons.brightness_2_outlined,
                      size: 15,
                    )),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) leftLayout(),
          buildDragLine(),
          Expanded(child: rightLayout()),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: leftLayout(),
            )
          : null,
    );
  }

  Widget leftLayout() {
    return SizedBox(
      width: isCollapsed ? 45 : leftLayoutWidth,
      child: Menu(
        router: widget.state.location,
        isCollapsed: isCollapsed && !isMobile,
        onUnCollapsed: () {
          isCollapsed = false;
          refresh();
        },
        onCollapsed: () {
          if (isMobile) {
            Navigator.of(context).pop();
            return;
          }
          isCollapsed = true;
          refresh();
        },
      ),
    );
  }

  Widget buildDragLine() {
    Widget line = VerticalDivider(width: 4);
    if (isCollapsed) return line;
    return GestureDetector(
      onHorizontalDragStart: (e) {},
      onHorizontalDragEnd: (e) {},
      onHorizontalDragUpdate: (e) {
        final delta = e.delta;
        final width = delta.dx + leftLayoutWidth;
        if (width >= 220 && width <= 400) {
          leftLayoutWidth = width;
          refresh();
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: line,
      ),
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  Widget rightLayout() => widget.child;
}
