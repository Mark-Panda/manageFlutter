import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "仪表板",
            svgSrc: "assets/icons/side_dashboard.svg",
            press: () {
              context.go('/home');
            },
          ),
          DrawerListTile(
            title: "扫码",
            svgSrc: "assets/icons/side_scan_code.svg",
            press: () {
              context.go('/scanner');
            },
          ),
          DrawerListTile(
            title: "简介",
            svgSrc: "assets/icons/side_me.svg",
            press: () {
              context.go('/profile');
            },
          ),
          DrawerListTile(
            title: "网络设置",
            svgSrc: "assets/icons/side_wifi.svg",
            press: () {
              context.go('/setting');
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        color: Colors.white54,
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
