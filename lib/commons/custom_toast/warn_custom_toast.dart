import 'package:flutter/material.dart';

// 警告提示弹窗
class WarnCustomToast extends StatelessWidget {
  const WarnCustomToast(this.msg, {Key? key}) : super(key: key);

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: const Color.fromARGB(222, 231, 196, 38),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          //icon
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: const Icon(Icons.error_outline),
          ),

          //msg
          Text(msg, style: const TextStyle(color: Colors.white)),
        ]),
      ),
    );
  }
}
