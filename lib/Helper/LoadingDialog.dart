import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

buildDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SpinKitThreeBounce(
            color: Colors.lightBlueAccent,
          ),
        );
      });
}
