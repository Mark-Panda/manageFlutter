import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:manager_flutter/api/login.dart';
import 'package:manager_flutter/commons/custom_toast/error_custom.toast.dart';
import 'package:manager_flutter/commons/custom_toast/success_custom_toast.dart';
import 'package:manager_flutter/commons/expansion_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  final GlobalKey _listKey = GlobalKey<FormState>();
  late String _username, _password;
  bool _isObscure = true;
  Color _eyeColor = Colors.grey;
  late String _ip, _port;

  _load() async {
    final prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString('requestIp') ?? '172.21.75.37';
    _port = prefs.getString('requestPort') ?? '3000';
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
      body: Form(
        key: _formKey, // 设置globalKey，用于后面获取FormStat
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildTitle(), // Login
            // buildTitleLine(), // Login下面的下划线
            const SizedBox(height: 60),
            buildEmailTextField(), // 输入邮箱
            const SizedBox(height: 30),
            buildPasswordTextField(context), // 输入密码
            buildResetNetworkText(context), // 重置网络
            const SizedBox(height: 60),
            // buildStationTextField(context),
            // const SizedBox(height: 30),
            buildLoginButton(context), // 登录按钮
            const SizedBox(height: 40),
            // buildRegisterText(context), // 注册
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Hi登录',
          style: TextStyle(fontSize: 42),
        ));
  }

  Widget buildTitleLine() {
    return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.black,
            width: 40,
            height: 2,
          ),
        ));
  }

  Widget buildEmailTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '用户名'),
      validator: (v) {
        var userNameReg = RegExp(r"^[\d\w-_]{4,16}$");
        if (!userNameReg.hasMatch(v!)) {
          return '请输入正确的用户名(4-16位、字母、数字、下划线、减号)';
        }
      },
      onSaved: (v) => _username = v!,
    );
  }

  Widget buildPasswordTextField(BuildContext context) {
    return TextFormField(
        obscureText: _isObscure, // 是否显示文字
        onSaved: (v) => _password = v!,
        validator: (v) {
          var pwdReg = RegExp(r"^[\d\w-_]{1,16}$");
          if (!pwdReg.hasMatch(v!)) {
            return '请输入正确的密码(1-16位、字母、数字、下划线、减号)';
          }
        },
        decoration: InputDecoration(
            labelText: "密码",
            suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = (_isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color)!;
                });
              },
            )));
  }

  // 重置网络设置 底部弹出框
  Widget buildResetNetworkText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Form(
                    key: _listKey, // 设置globalKey，用于后面获取FormStat
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
                        // const SizedBox(height: 60),
                        buildIpTextField(),
                        const SizedBox(height: 30),
                        buildPortTextField(context), // 输入端口
                        const SizedBox(height: 60),
                        buildResetButton(context),
                      ],
                    ),
                  );
                });
          },
          child: const Text("网络设置",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),
      ),
    );
  }

  // 选择登录框
  Widget buildStationTextField(BuildContext context) {
    return const SingleChildScrollView(
      child: ExpansionPanelPage(),
    );
  }

  //登录按钮
  Widget buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 250,
        child: ElevatedButton(
          style: ButtonStyle(
              // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child:
              Text('去登录', style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () async {
            // 表单校验通过才会继续执行
            if ((_formKey.currentState as FormState).validate()) {
              (_formKey.currentState as FormState).save();
              Map resData = await login(_username, _password);
              if (resData['data'] != null) {
                await getUserInfo();
                // ignore: use_build_context_synchronously
                context.go('/home');
              } else {
                SmartDialog.showToast('',
                    builder: (_) => const ErrorCustomToast('网络异常'));
              }
            }
          },
        ),
      ),
    );
  }

  Widget buildIpTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'IP地址'),
      initialValue: _ip,
      validator: (v) {
        var ipReg = RegExp(
            r"([1-9]?\d|1\d{2}|2[0-4]\d|25[0-5])(\.([1-9]?\d|1\d{2}|2[0-4]\d|25[0-5])){3}$");
        if (!ipReg.hasMatch(v!)) {
          return '请输入正确的IP地址';
        }
        return null;
      },
      onSaved: (v) => _ip = v!,
    );
  }

  Widget buildPortTextField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: '端口号'),
      initialValue: _port,
      validator: (v) {
        var ipReg = RegExp(
            r"^((6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])|[0-5]?\d{0,4})$");
        if (!ipReg.hasMatch(v!)) {
          return '请输入正确的端口号';
        }
        return null;
      },
      onSaved: (v) => _port = v!,
    );
  }

  _reset(String resetIp, resetPort) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('requestIp', resetIp);
    prefs.setString('requestPort', resetPort);
  }

  Widget buildResetButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 200,
        child: ElevatedButton(
          style: ButtonStyle(
              // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child:
              Text('重置', style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () async {
            // 表单校验通过才会继续执行
            if ((_listKey.currentState as FormState).validate()) {
              (_listKey.currentState as FormState).save();
              _reset(_ip, _port);
              SmartDialog.showToast('',
                  builder: (_) => const SuccessCustomToast('网络重置成功'));
              // Navigator.pop(context); //返回上一页面
            }
          },
        ),
      ),
    );
  }
}
