import 'package:shared_preferences/shared_preferences.dart';

void saveOperatInfo(String station) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('stationInfo', station.toString());
}

void delAllInfo() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('stationInfo');
  prefs.remove('userToken');
  prefs.remove('userInfo');
}
