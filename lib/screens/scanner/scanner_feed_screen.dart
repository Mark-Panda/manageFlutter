import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_flutter/api/restful_api.dart';
import 'package:manager_flutter/api/util.dart';
import 'package:manager_flutter/commons/custom_toast/error_custom.toast.dart';
import 'package:manager_flutter/commons/custom_toast/success_custom_toast.dart';
import 'package:manager_flutter/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manager_flutter/commons/side_menu.dart';

class ScannerFeedPage extends StatefulWidget {
  const ScannerFeedPage({Key? key}) : super(key: key);
  @override
  _ScannerFeedPageState createState() => _ScannerFeedPageState();
}

class _ScannerFeedPageState extends State<ScannerFeedPage> {
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

  String _feedTeamCode = "", _operator = "", _station = "", _center = "";
  String _materialCode = "",
      _materialName = "",
      _amount = "",
      _unit = "",
      _lot = "",
      _workOrderNo = "",
      _equipmentNo = "",
      _feedPortNo = "";

  _load() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userInfo');
    String? stationInfo = prefs.getString('stationInfo');
    if (userInfo != null) {
      Map userMap = jsonDecode(userInfo.toString());
      _operator = userMap['person']['user']['name'];
      //判断控制弹窗提示
      _feedTeamCode = userMap['person']['team'] != null
          ? userMap['person']['team']['name']
          : '';
    }
    if (stationInfo != null) {
      Map stationMap = jsonDecode(stationInfo);
      _station = stationMap['stationCode'];
      _center = stationMap['centerCode'];
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      setState(() {
        _load();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanResult = this.scanResult;
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描二维码'),
        centerTitle: true,
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
            color: bgColor,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('物料编码'),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: [
                      Text(_materialCode != "" ? _materialCode : ''), // icon-1
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('物料名称'),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: [
                      Text(_materialName != "" ? _materialName : ''),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('规格单位'),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: [
                      Text(_unit != "" ? _unit : ''),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('数量'),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: [
                      Text(_amount != "" ? _amount : ''),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('批次号'),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: [
                      Text(_lot != "" ? _lot : ''),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('工单编号'),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: [
                      Text(_workOrderNo != "" ? _workOrderNo : ''),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('设备编号'),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: [
                      Text(_equipmentNo != "" ? _equipmentNo : ''),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('投料口'),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: [
                      Text(_feedPortNo != "" ? _feedPortNo : ''),
                    ],
                  ),
                ),

                // ListTile(
                //   title: const Text('扫描内容'),
                //   subtitle:
                //       Text(scanResult != null ? scanResult.rawContent : ''),
                // ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 30)),
          Align(
            child: SizedBox(
              height: 45,
              width: 250,
              child: ElevatedButton(
                child: const Text('去投料'),
                onPressed: () async {
                  //参数检查
                  if (_operator == "" || _station == "" || _center == "") {
                    //退出登录
                    //删除缓存信息
                    delAllInfo();
                    //跳转登录页面
                    context.go('/login');
                  } else {
                    if (_feedTeamCode == "") {
                      SmartDialog.show(builder: (context) {
                        return Container(
                          height: 80,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.yellow[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text('当前用户没有绑定班组信息,请完善信息后重新登录!',
                              style: TextStyle(color: Colors.white)),
                        );
                      });
                    } else {
                      if (_materialCode == "" ||
                          _materialName == "" ||
                          _amount == "" ||
                          _unit == "" ||
                          _lot == "" ||
                          _workOrderNo == "" ||
                          _equipmentNo == "" ||
                          _feedPortNo == "") {
                        //弹窗提示
                        SmartDialog.showToast('',
                            builder: (_) =>
                                const ErrorCustomToast('请扫描对应二维码信息'));
                      } else {
                        //调用接口
                        Map feedResult = await feed(
                            _workOrderNo,
                            _materialCode,
                            _materialName,
                            _unit,
                            _amount,
                            _lot,
                            _equipmentNo,
                            _feedPortNo,
                            _feedTeamCode,
                            _operator,
                            _center,
                            _station);
                        if (feedResult['data'] == null &&
                            feedResult['error'] == null) {
                          SmartDialog.showToast('',
                              builder: (_) =>
                                  const ErrorCustomToast('投料失败，原因未知!'));
                        }
                        if (feedResult['data'] != null) {
                          SmartDialog.showToast('',
                              builder: (_) => const SuccessCustomToast('投料成功'));
                        }
                        if (feedResult['error'] != null) {
                          SmartDialog.show(builder: (context) {
                            return Container(
                              height: 200,
                              width: 280,
                              decoration: BoxDecoration(
                                color: Colors.red[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text('投料失败 -- ${feedResult['error']}',
                                  style: const TextStyle(color: Colors.white)),
                            );
                          });
                        }
                      }
                    }
                  }
                },
              ),
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

      setState(() {
        scanResult = result;
        String resultStr = result.rawContent.toString();
        if (resultStr != "") {
          if (resultStr.startsWith("{")) {
            Map<String, dynamic> resultJson = json.decode(resultStr);
            if (resultJson['equipmentNo'] != null) {
              _equipmentNo = resultJson['equipmentNo']!;
            }
            if (resultJson['feedPortNo'] != null) {
              _feedPortNo = resultJson['feedPortNo']!;
            }
            if (resultJson['amount'] != null) {
              _amount = resultJson['amount']!;
            }
            if (resultJson['lotNo'] != null) {
              _lot = resultJson['lotNo']!;
            }
            if (resultJson['materialCode'] != null) {
              _materialCode = resultJson['materialCode']!;
            }
            if (resultJson['materialName'] != null) {
              _materialName = resultJson['materialName']!;
            }
            if (resultJson['unit'] != null) {
              _unit = resultJson['unit']!;
            }
            if (resultJson['workOrderNo'] != null) {
              _workOrderNo = resultJson['workOrderNo']!;
            }
          }
        }
      });
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
