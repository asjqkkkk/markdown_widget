import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final bool isSelected;
  final bool isCollapsed;
  final String title;
  final String trailing;
  final VoidCallback? onTap;

  const NavItem({
    Key? key,
    this.isSelected = false,
    this.isCollapsed = false,
    this.title = '',
    this.trailing = '',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        hoverColor: Color(0xffebebea),
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Color(0xffe2e2e1) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
          child: isCollapsed ? collapsedWidget() : unCollapsedWidget(),
        ),
      ),
    );
  }

  Widget unCollapsedWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$trailing $title', style: _buildTextStyle()),
        Spacer(),
        Icon(Icons.chevron_right, color: Color(0xffbbbab7))
      ],
    );
  }

  Widget collapsedWidget() => SizedBox(
        height: 24,
        child: Tooltip(
          message: title,
          child: Text(trailing, style: _buildTextStyle()),
        ),
      );

  TextStyle _buildTextStyle() {
    return TextStyle(
      fontSize: 14,
      height: 1.5,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );
  }
}
