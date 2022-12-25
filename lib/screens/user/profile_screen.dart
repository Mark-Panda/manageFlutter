import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_flutter/commons/custom_toast/error_custom.toast.dart';
import 'package:manager_flutter/api/login.dart';
import 'package:manager_flutter/commons/side_menu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = "_", _workCenter = "_";

  _load() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userInfo');
    if (userInfo != null) {
      Map info = jsonDecode(userInfo);
      _username = info['name'];
      _workCenter = info['name'];
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _load();
      });
    });
  }

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
              children: <Widget>[
                Text(_username), // icon-1
              ],
            ),
          ),
          // ListTile(
          //   title: const Text('部门'),
          //   trailing: Wrap(
          //     spacing: 12, // space between two icons
          //     children: <Widget>[
          //       Text(_workCenter), // icon-1
          //     ],
          //   ),
          // ),
          ListTile(
            // leading: const Icon(
            //   Icons.article_outlined,
            //   size: 30,
            // ),
            title: const Text('当前工作中心'),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: <Widget>[
                Text(_workCenter), // icon-1
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 60)),
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
            onTap: () async {
              Map resData = await logout();
              if (resData['data'] != null) {
                // ignore: use_build_context_synchronously
                context.go('/login');
              } else {
                SmartDialog.showToast('',
                    builder: (_) => const ErrorCustomToast('网络异常'));
              }
            },
          ),
        ],
      ),
    );
  }
}
