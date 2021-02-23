import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:vehicle_manager/Services/SessionService.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _userData;

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    _userData = await getUserData();
    Timer(Duration(seconds: 3), () {
      print(_userData);
      if (_userData == null) {
        Navigator.pushReplacementNamed(context, '/LoginScreen');
      }
      if (_userData != null) {
        Navigator.pushReplacementNamed(context, '/HomeScreen');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
    );
  }
}
