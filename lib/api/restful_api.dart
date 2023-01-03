import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:manager_flutter/api/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
// ignore: depend_on_referenced_packages
import 'package:pointycastle/asymmetric/api.dart';

// 登录方法
login(String username, password, station) async {
  try {
    // 公钥导入
    final publicPem = await rootBundle.loadString('assets/pki/public.pem');
    final publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;
    // 私钥导入
    final privPem = await rootBundle.loadString('assets/pki/private.pem');
    final privKey = RSAKeyParser().parse(privPem) as RSAPrivateKey;
    // RSA加密
    final encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privKey));
    final encryptedPwd = encrypter.encrypt(password);
    // print(encryptedPwd.base64);
    // final decrypted = encrypter.decrypt(encryptedPwd);
    // print(decrypted);
    final prefs = await SharedPreferences.getInstance();
    var requestIp = prefs.getString('requestIp') ?? '172.21.75.37';
    var requestPort = prefs.getString('requestPort') ?? '3000';
    var url = 'http://$requestIp:$requestPort/api';
    Response response;
    Dio dio = Dio();
    dio.options
      ..baseUrl = url
      ..connectTimeout = 5000 //5s
      ..receiveTimeout = 5000
      ..validateStatus = (int? status) {
        return status != null && status > 0;
      }
      ..headers = {};
    dio.interceptors
      ..add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
      ))
      ..add(LogInterceptor(responseBody: false));
    response = await dio.post('/login',
        data: {
          'username': username,
          'password': encryptedPwd.base64,
          'workStation': station
        },
        options: Options(contentType: Headers.jsonContentType));
    print('登录返回结果Token ${response.data}');
    Map<String, dynamic> data = response.data;
    if (data['data'] != null) {
      await prefs.setString('userToken', data['data']['token']);
      // ignore: prefer_typing_uninitialized_variables
      return data;
    } else {
      return data;
    }
  } catch (e) {
    print('登录异常$e');
    // ignore: prefer_typing_uninitialized_variables
    Map<String, dynamic> error = {'error': e};
    return error;
  }
}

//获取用户信息
getUserInfo() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('userToken');
    var requestIp = prefs.getString('requestIp') ?? '172.21.75.37';
    var requestPort = prefs.getString('requestPort') ?? '3000';
    var url = 'http://$requestIp:$requestPort/api';
    Response response;
    Dio dio = Dio();
    dio.options
      ..baseUrl = url
      ..connectTimeout = 5000 //5s
      ..receiveTimeout = 5000
      ..validateStatus = (int? status) {
        return status != null && status > 0;
      }
      ..headers = {'x-access-token': token};
    dio.interceptors
      ..add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
      ))
      ..add(LogInterceptor(responseBody: false));
    response = await dio.get('/userInfo');
    print('登录用户信息 ${response.data}');
    // await prefs.setString('userInfo', jsonEncode(response.data['data']));
    Map<String, dynamic> data = response.data;
    return data;
  } catch (e) {
    print('获取用户信息异常$e');
    // ignore: prefer_typing_uninitialized_variables
    Map<String, dynamic> error = {'error': e};
    return error;
  }
}

// 注销用户
logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('userToken');
    var requestIp = prefs.getString('requestIp') ?? '172.21.75.37';
    var requestPort = prefs.getString('requestPort') ?? '3000';
    var url = 'http://$requestIp:$requestPort/api';
    Dio dio = Dio();
    dio.options
      ..baseUrl = url
      ..connectTimeout = 5000 //5s
      ..receiveTimeout = 5000
      ..validateStatus = (int? status) {
        return status != null && status > 0;
      }
      ..headers = {'x-access-token': token};
    dio.interceptors
      ..add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
      ))
      ..add(LogInterceptor(responseBody: false));
    await dio.get('/logout');
    delAllInfo();
    Map<String, dynamic> data = {'data': '注销成功'};
    return data;
  } catch (e) {
    print('注销用户异常$e');
    // ignore: prefer_typing_uninitialized_variables
    Map<String, dynamic> error = {'error': e};
    return error;
  }
}

// 获取工作站
getStations() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var requestIp = prefs.getString('requestIp') ?? '172.21.75.37';
    var requestPort = prefs.getString('requestPort') ?? '3000';
    var url = 'http://$requestIp:$requestPort/api';
    Response response;
    Dio dio = Dio();
    dio.options
      ..baseUrl = url
      ..connectTimeout = 5000 //5s
      ..receiveTimeout = 5000
      ..validateStatus = (int? status) {
        return status != null && status > 0;
      }
      ..headers = {};
    dio.interceptors
      ..add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
      ))
      ..add(LogInterceptor(responseBody: false));
    response = await dio.get('/pass/workStations',
        options: Options(contentType: Headers.jsonContentType));
    print('获取工作站返回结果 ${response.data}');
    Map<String, dynamic> data = response.data;
    // ignore: prefer_typing_uninitialized_variables
    return data;
  } catch (e) {
    print('获取工作站异常$e');
    // ignore: prefer_typing_uninitialized_variables
    Map<String, dynamic> error = {'error': e};
    return error;
  }
}

feed(String workOrderNo, materialCode, materialName, unit, amount, lotNo,
    equipmentNo, feedPortNo, teamCode, operatorName, center, station) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('userToken');
    var requestIp = prefs.getString('requestIp') ?? '172.21.75.37';
    var requestPort = prefs.getString('requestPort') ?? '3000';
    var url = 'http://$requestIp:$requestPort/internal';
    Response response;
    Dio dio = Dio();
    dio.options
      ..baseUrl = url
      ..connectTimeout = 5000 //5s
      ..receiveTimeout = 5000
      ..validateStatus = (int? status) {
        return status != null && status > 0;
      }
      ..headers = {'x-access-token': token};
    dio.interceptors
      ..add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
      ))
      ..add(LogInterceptor(responseBody: false));
    response = await dio.post('/workOrderFeeding',
        data: {
          'type': 'SCAN',
          'workOrderNo': workOrderNo,
          'materialCode': materialCode,
          'materialName': materialName,
          'unit': unit,
          'amount': amount,
          'lotNo': lotNo,
          'equipmentNo': equipmentNo,
          'feedPortNo': feedPortNo,
          'feedTeamCode': teamCode,
          'operator': operatorName,
          'workCenter': center,
          'workStation': station
        },
        options: Options(contentType: Headers.jsonContentType));
    print('投料返回结果 ${response.data}');
    Map<String, dynamic> data = response.data;
    if (data['error'] != null) {
      // ignore: prefer_typing_uninitialized_variables
      Map<String, dynamic> error = {'error': data['error']};
      return error;
    }
    // ignore: prefer_typing_uninitialized_variables
    return data;
  } catch (e) {
    print('登录异常$e');
    // ignore: prefer_typing_uninitialized_variables
    Map<String, dynamic> error = {'error': e};
    return error;
  }
}
