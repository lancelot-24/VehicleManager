import 'package:flutter/material.dart';
import 'package:vehicle_manager/Screens/AddVehicle.dart';
import 'package:vehicle_manager/Screens/HomeScreen.dart';
import 'package:vehicle_manager/Screens/LoginScreen.dart';
import 'package:vehicle_manager/Screens/SplashScreen.dart';
import 'package:vehicle_manager/Screens/VehiclesList.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/SplashScreen',
      routes: {
        '/SplashScreen': (context) => SplashScreen(),
        '/LoginScreen': (context) => LoginScreen(),
        '/HomeScreen': (context) => HomeScreen(),
        '/VehicleList': (context) => VehiclesList(),
        '/AddVehicle': (context) => AddVehicle(),
      },
    );
  }
}
