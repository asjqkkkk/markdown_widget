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
  bool get isMobile =>
      PlatformDetector.isMobile || PlatformDetector.isWebMobile;

  int selectIndex = 0;
  double leftLayoutWidth = 220;
  bool isCollapsed = false;

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
                buildThemeButton(),
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
        isCollapsed: isCollapsed,
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

  IconButton buildThemeButton() {
    Brightness brightness = rootStore.state.themeState.brightness;
    bool isDarkNow = brightness == Brightness.dark;
    return IconButton(
        icon: Icon(isDarkNow ? Icons.brightness_7 : Icons.brightness_2),
        onPressed: () {
          rootStore.dispatch(new ChangeThemeEvent());
        });
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  Widget rightLayout() => widget.child;
}
