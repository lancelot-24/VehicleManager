import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:vehicle_manager/Widgets/PageHelper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  dynamic userData;

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    userData = await FlutterSession().get('userData');
    Timer(Duration(seconds: 3), () {
      print(userData);
      if (userData == null) {
        Navigator.pushReplacementNamed(context, '/LoginScreen');
      }
      if (userData != null) {
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
