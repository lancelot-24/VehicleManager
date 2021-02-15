import 'package:flutter/material.dart';
import 'Colors.dart';
import 'PageHelper.dart';

InputDecoration buildSignUpInputDecoration(String hint) {
  return InputDecoration(
    labelText: hint,
    labelStyle: myTextStyle.copyWith(color: secondaryColor),
    filled: true,
    fillColor: Colors.white,
    focusColor: Colors.white,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: secondaryColor, width: 1)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: secondaryColor, width: 1)),
    contentPadding: EdgeInsets.only(left: 14.0, bottom: 10.0, top: 10.0),
  );
}
