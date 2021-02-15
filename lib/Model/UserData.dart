import 'package:flutter/cupertino.dart';

class UserData {
  final String userName;
  final int uID;

  UserData({
    @required this.userName,
    @required this.uID,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'uid': uID,
    };
  }
}
