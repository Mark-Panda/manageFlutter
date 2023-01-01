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

  Future<String> _validateLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 不止判断token还要判断token是否能正常获取用户信息
    var currentToken = prefs.getString("userToken");
    if (currentToken != null) {
      // 请求获取用户信息接口
      Map resData = await getUserInfo();
      if (resData['data'] != null) {
        loginState = 1;
        return 'success';
      } else {
        loginState = 1;
        return 'false';
      }
    } else {
      loginState = 1;
      return 'false';
    }
  }

  @override
  Widget build(BuildContext context) {
    var profileBuilder = FutureBuilder(
      future: _validateLogin(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            // return const Text('Press button to start');
            return Image.asset(
              'assets/images/logo.png',
              // fit: BoxFit.cover,
            );
          case ConnectionState.waiting:
            // 初始化过度阶段
            // return const Text('Awaiting result...');
            return Image.asset(
              'assets/images/logo.png',
              // fit: BoxFit.cover,
            );
          default:
            if (snapshot.hasError) {
              // 报错时的页面
              return Image.asset('assets/images/404.jpeg');
            } else {
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
      },
    );
    return profileBuilder;
  }
}
