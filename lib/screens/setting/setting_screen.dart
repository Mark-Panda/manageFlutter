import 'package:flutter/material.dart';
import 'package:manager_flutter/commons/side_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
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
      appBar: AppBar(
        title: const Text('网络配置'),
      ),
      drawer: const SideMenu(),
      body: Form(
        key: _formKey, // 设置globalKey，用于后面获取FormStat
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            const SizedBox(height: 60),
            buildIpTextField(), // 输入IP
            const SizedBox(height: 30),
            buildPortTextField(context), // 输入端口
            const SizedBox(height: 60),
            buildResetButton(context), // 重置按钮
            const SizedBox(height: 40),
          ],
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
          onPressed: () {
            // 表单校验通过才会继续执行
            if ((_formKey.currentState as FormState).validate()) {
              (_formKey.currentState as FormState).save();
              _reset(_ip, _port);
              Fluttertoast.showToast(
                msg: "网络重置成功",
                backgroundColor: Colors.green, //背景颜色
                gravity: ToastGravity.CENTER, // 弹窗位置
                timeInSecForIosWeb: 1, //停留时间3秒
                fontSize: 22.0, // 字体大小
              );
            }
          },
        ),
      ),
    );
  }
}
