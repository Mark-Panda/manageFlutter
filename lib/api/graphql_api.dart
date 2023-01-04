import 'dart:convert';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

GraphQLClient getClient(String requestIp, String requestPort, String token) {
  var url = 'http://$requestIp:$requestPort/data';
  final Link _link = HttpLink(
    '$url/base',
    defaultHeaders: {
      'x-access-token': token,
    },
  );

  return GraphQLClient(
    cache: GraphQLCache(),
    link: _link,
  );
}

/// 获取用户信息
getUserBaseInfo(String personId) async {
  print('sssss');
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('userToken');
  var requestIp = prefs.getString('requestIp') ?? '172.21.75.37';
  var requestPort = prefs.getString('requestPort') ?? '80';

  final GraphQLClient _client = getClient(requestIp, requestPort, token!);
  final QueryOptions options = QueryOptions(
    document: gql(
      r'''
        query personInfo($where:PersonWhereUniqueInput!) {
          person(where:$where){
            code
            name
            user{
              name
              email
            }
            organize{
              code
              name
            }
            team{
              code
              name
            }
          }
        }
      ''',
    ),
    variables: <String, dynamic>{
      'where': {"id": personId},
    },
  );

  final QueryResult result = await _client.query(options);
  if (result.hasException) {
    // stderr.writeln(result.exception.toString());
    // exit(2);
    // ignore: prefer_typing_uninitialized_variables
    Map<String, dynamic> error = {'error': result.exception.toString()};
    return error;
  }
  await prefs.setString('userInfo', jsonEncode(result.data));

  Map<String, dynamic>? data = result.data;
  return data;
}
