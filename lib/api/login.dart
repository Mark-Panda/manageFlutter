import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

login(String username, password) async {
  try {
    password =
        "jlATLPKbqovsF5bSz4pc5NFyfLIcRRb974R7V1RLnUiYJPJACUhZQ8Z50CCfIUzUXfKFERizMAS0FdXm9S71iGvs2ozeI+SYQyLFoD+bY82CSjfYthofchjSxDdtBtDBSF1Wg70GLxnM5/u+Hnx9nMQdkIdB0DrYUClFpZjz040=";
    username = "wang";
    final prefs = await SharedPreferences.getInstance();
    var requestIp = prefs.getString('requestIp') ?? '172.21.75.37';
    var requestPort = prefs.getString('requestPort') ?? '3000';
    var url = 'http://$requestIp:${requestPort}/api';
    Response response;
    Dio dio = Dio();
    dio.options
      ..baseUrl = url
      ..connectTimeout = 5000 //5s
      ..receiveTimeout = 5000
      ..validateStatus = (int? status) {
        return status != null && status > 0;
      }
      ..headers = {
        HttpHeaders.userAgentHeader: 'dio',
        'common-header': 'xx',
      };
    dio.interceptors
      ..add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // return handler.resolve( Response(data:"xxx"));
          // return handler.reject( DioError(message: "eh"));
          return handler.next(options);
        },
      ))
      ..add(LogInterceptor(responseBody: false));
    response = await dio.post('/login',
        data: {'username': username, 'password': password},
        options: Options(contentType: Headers.jsonContentType));
    print('登录返回结果Token ${response.data}');
    Map<String, dynamic> data = response.data;
    await prefs.setString('userToken', data['data']['token']);
    // ignore: prefer_typing_uninitialized_variables
    // var formalData;
    return data;
  } catch (e) {
    print('登录异常$e');
    // ignore: prefer_typing_uninitialized_variables
    Map<String, dynamic> error = {'error': e};
    return error;
  }
}

getUserInfo() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('userToken');
    var requestIp = prefs.getString('requestIp') ?? '172.21.75.37';
    var requestPort = prefs.getString('requestPort') ?? '3000';
    var url = 'http://$requestIp:${requestPort}/api';
    Response response;
    Dio dio = Dio();
    dio.options
      ..baseUrl = url
      ..connectTimeout = 5000 //5s
      ..receiveTimeout = 5000
      ..validateStatus = (int? status) {
        return status != null && status > 0;
      }
      ..headers = {
        HttpHeaders.userAgentHeader: 'dio',
        'common-header': 'xx',
        'x-access-token': token
      };
    dio.interceptors
      ..add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // return handler.resolve( Response(data:"xxx"));
          // return handler.reject( DioError(message: "eh"));
          return handler.next(options);
        },
      ))
      ..add(LogInterceptor(responseBody: false));
    response = await dio.get('/userInfo');
    print('登录用户信息 ${response.data}');
    await prefs.setString('userInfo', response.data['data']);
    // TODO: 保存用户信息
    Map<String, dynamic> data = response.data;
    return data;
  } catch (e) {
    print('获取用户信息异常$e');
    // ignore: prefer_typing_uninitialized_variables
    Map<String, dynamic> error = {'error': e};
    return error;
  }
}

void logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('userToken');
    print('token$token');
    var requestIp = prefs.getString('requestIp') ?? '172.21.75.37';
    var requestPort = prefs.getString('requestPort') ?? '3000';
    var url = 'http://$requestIp:${requestPort}/api';
    Response response;
    Dio dio = Dio();
    dio.options
      ..baseUrl = url
      ..connectTimeout = 5000 //5s
      ..receiveTimeout = 5000
      ..validateStatus = (int? status) {
        return status != null && status > 0;
      }
      ..headers = {
        HttpHeaders.userAgentHeader: 'dio',
        'common-header': 'xx',
        'x-access-token': token
      };
    dio.interceptors
      ..add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // return handler.resolve( Response(data:"xxx"));
          // return handler.reject( DioError(message: "eh"));
          return handler.next(options);
        },
      ))
      ..add(LogInterceptor(responseBody: false));
    await dio.get('/logout');
    await prefs.remove('userToken');
    await prefs.remove('userInfo');
  } catch (e) {
    print('注销用户异常$e');
  }
}
