import 'package:flutter/material.dart';
import 'package:manager_flutter/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manager_flutter/commons/side_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ignore: prefer_typing_uninitialized_variables
  late int loginState;
  @override
  void initState() {
    super.initState();

    _validateLogin();
  }

  Future _validateLogin() async {
    Future future = Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      return prefs.getString("userToken");
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
