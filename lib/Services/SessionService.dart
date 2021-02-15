import 'package:flutter_session/flutter_session.dart';
import 'package:vehicle_manager/Model/UserData.dart';

Future<void> saveData(int uID, String userName) async {
  UserData userData = UserData(userName: userName, uID: uID);
  await FlutterSession().set('userData', userData);
}
