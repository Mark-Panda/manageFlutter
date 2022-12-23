import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_flutter/api/login.dart';

import 'package:manager_flutter/commons/side_menu.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户简介'),
      ),
      drawer: const SideMenu(),
      body: ListView(
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 30)),
          ClipOval(
            //圆形头像
            child: Image.asset('assets/images/profile_pic.png',
                width: 100.0, height: 100.0, fit: BoxFit.contain),
          ),
          const Padding(padding: EdgeInsets.only(top: 30)),
          ListTile(
            title: const Text('昵称'),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: const <Widget>[
                Text('wang'), // icon-1
              ],
            ),
          ),
          ListTile(
            title: const Text('部门'),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: const <Widget>[
                Text('wang'), // icon-1
              ],
            ),
          ),
          ListTile(
            // leading: const Icon(
            //   Icons.article_outlined,
            //   size: 30,
            // ),
            title: const Text('当前工作中心'),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: const <Widget>[
                Text('wang'), // icon-1
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 30)),
          // const Divider(
          //   indent: 40,
          //   endIndent: 40,
          //   thickness: 2,
          //   color: Color.fromARGB(255, 4, 4, 19),
          // ),
          ListTile(
            title: const Text(
              '退出登录',
              textAlign: TextAlign.center,
            ),
            onTap: () {
              logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
