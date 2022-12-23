import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
// ignore: depend_on_referenced_packages
import 'package:pointycastle/asymmetric/api.dart';

// 登录方法
login(String username, password) async {
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
        data: {'username': username, 'password': encryptedPwd.base64},
        options: Options(contentType: Headers.jsonContentType));
    print('登录返回结果Token ${response.data}');
    Map<String, dynamic> data = response.data;
    await prefs.setString('userToken', data['data']['token']);
    // ignore: prefer_typing_uninitialized_variables
    return data;
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
    await prefs.setString('userInfo', jsonEncode(response.data['data']));
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
    await prefs.remove('userToken');
    await prefs.remove('userInfo');
    Map<String, dynamic> data = {'data': '注销成功'};
    return data;
  } catch (e) {
    print('注销用户异常$e');
    // ignore: prefer_typing_uninitialized_variables
    Map<String, dynamic> error = {'error': e};
    return error;
  }
}
