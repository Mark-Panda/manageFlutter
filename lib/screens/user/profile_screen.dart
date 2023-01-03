import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_flutter/commons/custom_toast/error_custom.toast.dart';
import 'package:manager_flutter/api/restful_api.dart';
import 'package:manager_flutter/commons/side_menu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = "_",
      _personname = "",
      _department = "_",
      _teamname = "_",
      _workCenter = "_";

  _load() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userInfo');
    String? stationInfo = prefs.getString('stationInfo');
    if (userInfo != null) {
      print('info' + userInfo);

      Map info = jsonDecode(userInfo.toString());
      _username = info['person']['user']['name'];
      _personname = info['person']['name'];
      _department = info['person']['organize'][0]['name'];
      _teamname =
          info['person']['team'] != null ? info['person']['team']['name'] : '_';
      if (stationInfo != null) {
        print('info1111' + stationInfo);
        Map stationMap = jsonDecode(stationInfo);
        _workCenter = stationMap['centerName'];
      }
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
          // const Padding(padding: EdgeInsets.only(top: 30)),
          ClipOval(
            //圆形头像
            child: Image.asset('assets/images/profile_pic.png',
                width: 100.0, height: 100.0, fit: BoxFit.contain),
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          const SizedBox(
            // width: 14,
            height: 4,
            child: Scaffold(
              backgroundColor: Colors.black,
            ),
          ),
          ListTile(
            title: const Text('昵称'),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: <Widget>[
                Text(_username), // icon-1
              ],
            ),
          ),
          ListTile(
            title: const Text('姓名'),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: <Widget>[
                Text(_personname), // icon-1
              ],
            ),
          ),
          ListTile(
            title: const Text('岗位'),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: <Widget>[
                Text(_department), // icon-1
              ],
            ),
          ),
          ListTile(
            title: const Text('班组'),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: <Widget>[
                Text(_teamname), // icon-1
              ],
            ),
          ),
          ListTile(
            title: const Text('工作中心'),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: <Widget>[
                Text(_workCenter), // icon-1
              ],
            ),
          ),
          const SizedBox(
            height: 4,
            child: Scaffold(
              backgroundColor: Colors.black,
            ),
          ),
          // const Padding(padding: EdgeInsets.only(top: 160)),
          const SizedBox(
            height: 4,
            child: Scaffold(
              backgroundColor: Colors.black,
            ),
          ),
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
          const SizedBox(
            // width: 14,
            height: 4,
            child: Scaffold(
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
