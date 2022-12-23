import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manager_flutter/api/login.dart';
import 'package:manager_flutter/screens/login/login_screen.dart';
import 'package:manager_flutter/commons/side_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? loginState;
  @override
  void initState() {
    super.initState();

    _validateLogin();
  }

  Future _validateLogin() async {
    Future future = Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // 不止判断token还要判断token是否能正常获取用户信息
      var currentToken = prefs.getString("userToken");
      if (currentToken != null) {
        // 请求获取用户信息接口
        Map resData = await getUserInfo();
        if (resData['data'] != null) {
          return prefs.getString("userToken");
        } else {
          return null;
        }
      }
      return null;
    });

    future.then((val) {
      if (val == null) {
        setState(() {
          loginState = 0;
        });
      } else {
        setState(() {
          loginState = 1;
        });
      }
    }).catchError((_) {
      setState(() {
        loginState = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loginState == 0) {
      return const LoginPage();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('主页'),
        ),
        drawer: const SideMenu(),
        body: Image.asset(
          'assets/images/logo.png',
          // fit: BoxFit.cover,
        ),
      );
    }
  }
}
