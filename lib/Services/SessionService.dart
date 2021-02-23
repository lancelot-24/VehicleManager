import 'package:flutter_session/flutter_session.dart';
import 'package:vehicle_manager/Model/UserData.dart';

Future<void> saveData(int uID, String userName) async {
  UserData _userData = UserData(userName: userName, uID: uID);
  await FlutterSession().set('userData', _userData);
}

Future<Map> getUserData() async {
  Map _userData = await FlutterSession().get('userData');
  return _userData;
}

Future<String> getUserName() async {
  Map _userData = await FlutterSession().get('userData');
  String _userName = _userData["userName"];
  return _userName;
}
