import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager_flutter/constants.dart';
import 'package:manager_flutter/routers/router.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '管理面板',
      debugShowCheckedModeBanner: false,
      builder: FlutterSmartDialog.init(),
      theme: ThemeData.dark().copyWith(
        // Scaffold的默认颜色。典型Material应用程序或应用程序内页面的背景颜色
        scaffoldBackgroundColor: bgColor,
        // 统一ElevatedButton按钮风格
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
                Theme.of(context).primaryTextTheme.headline5),
            backgroundColor: MaterialStateProperty.all(buttonBGColor),
            // 设置圆角
            shape: MaterialStateProperty.all(
                const StadiumBorder(side: BorderSide(style: BorderStyle.none))),
          ),
        ),
        // appbar主题设置
        appBarTheme: const AppBarTheme(
          backgroundColor: secondaryColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        //画布颜色
        canvasColor: secondaryColor,
      ),
      routerConfig: routerList,
    );
  }
}
