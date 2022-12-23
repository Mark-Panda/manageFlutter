import 'package:flutter/material.dart';
import 'package:manager_flutter/commons/side_menu.dart';
import 'package:manager_flutter/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主页'),
        // backgroundColor: secondaryColor,
      ),
      drawer: const SideMenu(),
      body: Image.asset(
        'assets/images/logo.png',
        // fit: BoxFit.cover,
      ),
    );
  }
}
