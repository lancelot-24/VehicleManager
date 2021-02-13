import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_manager/Widgets/PageHelper.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var myHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: myHeight * 0.18,
                ),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/VehicleScreen'),
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
                  onTap: () => Navigator.pushNamed(context, '/VehicleScreen'),
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
