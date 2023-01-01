import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager_flutter/commons/side_menu.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  ScanResult? scanResult;

  final _flashOnController = TextEditingController(text: '开启');
  final _flashOffController = TextEditingController(text: '关闭');
  final _cancelController = TextEditingController(text: '取消');

  final _aspectTolerance = 0.00;
  final _selectedCamera = -1;
  final _useAutoFocus = true; //自动对焦
  final _autoEnableFlash = false; // 默认开启闪光灯

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanResult = this.scanResult;
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描二维码'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Scan',
            onPressed: _scan,
          )
        ],
      ),
      drawer: const SideMenu(),
      body: ListView(
        scrollDirection:
            Axis.vertical, //设置滑动方向 Axis.horizontal 水平  默认 Axis.vertical 垂直
        shrinkWrap: true, //内容适配
        children: <Widget>[
          Card(
            color: const Color.fromARGB(255, 161, 136, 96),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('返回类型'),
                  // ignore: unnecessary_null_comparison
                  subtitle: Text(scanResult != null
                      ? scanResult.type.toString()
                      : '请扫描二维码或条形码'),
                ),
                ListTile(
                  title: const Text('扫描内容'),
                  subtitle: Text(scanResult != null
                      ? scanResult.rawContent
                      : '请扫描二维码或条形码'),
                ),
                ListTile(
                  title: const Text('扫描格式'),
                  subtitle: Text(scanResult != null
                      ? scanResult.format.toString()
                      : '请扫描二维码或条形码'),
                ),
                ListTile(
                  title: const Text('格式注释'),
                  subtitle: Text(scanResult != null
                      ? scanResult.formatNote
                      : '请扫描二维码或条形码'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scan() async {
    try {
      final result = await BarcodeScanner.scan(
        options: ScanOptions(
          strings: {
            'cancel': _cancelController.text,
            'flash_on': _flashOnController.text,
            'flash_off': _flashOffController.text,
          },
          restrictFormat: selectedFormats,
          useCamera: _selectedCamera,
          autoEnableFlash: _autoEnableFlash,
          android: AndroidOptions(
            aspectTolerance: _aspectTolerance,
            useAutoFocus: _useAutoFocus,
          ),
        ),
      );
      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      setState(() {
        scanResult = ScanResult(
          type: ResultType.Error,
          format: BarcodeFormat.unknown,
          rawContent: e.code == BarcodeScanner.cameraAccessDenied
              ? '用户没有授予相机权限,请前往设置为APP赋予相机权限！'
              : '未知错误: $e',
        );
      });
    }
  }
}
