import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_manager/Helper/Colors.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 100,
                ),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/VehicleList'),
                  child: Image(
                    height: 250,
                    width: 250,
                    image: AssetImage('assets/truck.png'),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/VehicleList'),
                  child: Image(
                    height: 200,
                    width: 200,
                    image: AssetImage(
                      'assets/employ.png',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
