import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_flutter/screens/home/home_screen.dart';
import 'package:manager_flutter/screens/login/login_screen.dart';
import 'package:manager_flutter/screens/scanner/scanner_feed_screen.dart';
import 'package:manager_flutter/screens/scanner/scanner_screen.dart';
import 'package:manager_flutter/screens/setting/setting_screen.dart';
import 'package:manager_flutter/screens/user/profile_screen.dart';

/// The route configuration.
final GoRouter routerList = GoRouter(
  debugLogDiagnostics: true, // 调试日志诊断
  observers: [FlutterSmartDialog.observer],
  initialLocation: '/', //初始加载路由
  routes: <RouteBase>[
    GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'home',
            builder: (BuildContext context, GoRouterState state) {
              return const HomePage();
            },
          ),
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return const LoginPage();
            },
          ),
          GoRoute(
            path: 'setting',
            builder: (BuildContext context, GoRouterState state) {
              return const SettingPage();
            },
          ),
          GoRoute(
            path: 'profile',
            builder: (BuildContext context, GoRouterState state) {
              return const ProfilePage();
            },
          ),
          GoRoute(
            path: 'scanner',
            builder: (BuildContext context, GoRouterState state) {
              // return const ScannerPage();
              return const ScannerFeedPage();
            },
          ),
        ]
        // routes: <RouteBase>[
        //   GoRoute(
        //     path: 'details',
        //     builder: (BuildContext context, GoRouterState state) {
        //       return const DetailsScreen();
        //     },
        //   ),
        // ],
        ),
  ],
);
