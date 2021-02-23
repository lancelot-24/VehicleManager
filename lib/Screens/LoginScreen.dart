import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:vehicle_manager/Helper/LoadingDialog.dart';
import 'package:vehicle_manager/Helper/PageHelper.dart';
import 'package:vehicle_manager/Helper/TextFieldDecoration.dart';
import 'file:///C:/Users/Niket/AndroidStudioProjects/vehicle_manager/lib/Services/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vehicle_manager/Services/SessionService.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _userName, _password;
  final _formKey = GlobalKey<FormState>();
  var _userAuthCheck;
  IconData _hidePass = FontAwesomeIcons.eyeSlash;
  bool _securePass = true;
  bool _isLoading;

  @override
  void initState() {
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

  bool validate() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void sendAuthRequest() async {
    setState(() {
      _isLoading = true;
    });

    if (_isLoading == true) {
      buildDialog(context);
    }

    String _url = "${apiURL}userLogin";
    print('url is $_url');

    final _body = jsonEncode({
      "userName": _userName,
      "userPassword": _password,
    });
    Map<String, String> _header = {"Content-Type": "application/json"};

    Response response = await post(_url, body: _body, headers: _header);
    print(response.statusCode);
    print(response.body);

    setState(() {
      _userAuthCheck = jsonDecode(response.body);
    });
    bool success = await _userAuthCheck['success'];

    if (success) {
      //flutter session saving data
      String _userName = await _userAuthCheck['data']['name'];
      int _uID = await _userAuthCheck['data']['uid'];

      await saveData(_uID, _userName);

      //Navigate to next page
      setState(() {
        _isLoading = false;
      });
      if (_isLoading == false) {
        Navigator.pop(context);
      }

      Navigator.pushReplacementNamed(context, '/HomeScreen');
    } else if (!success) {
      String msg = await _userAuthCheck['msg'];

      setState(() {
        _isLoading = false;
      });
      if (_isLoading == false) {
        Navigator.pop(context);
      }

      showSnackBar(context, msg);
    } else {
      setState(() {
        _isLoading = false;
      });
      if (_isLoading == false) {
        Navigator.pop(context);
      }

      showSnackBar(context, "Something want wrong");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                width: 300,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: myHeight * 0.25,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              'Sign In',
                              style: myTextStyle.copyWith(
                                color: secondaryColor,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Username can't be empty";
                          }
                          return null;
                        },
                        style: myTextStyle.copyWith(
                          fontSize: 22.0,
                        ),
                        decoration: buildSignUpInputDecoration('Username'),
                        onSaved: (value) => _userName = value,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Password can't be empty";
                          }
                          return null;
                        },
                        style: myTextStyle.copyWith(
                          fontSize: 22.0,
                        ),
                        obscureText: _securePass,
                        decoration:
                            buildSignUpInputDecoration('Password').copyWith(
                                suffixIcon: IconButton(
                                    icon: Icon(
                                      _hidePass,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _securePass = (_securePass == true)
                                            ? false
                                            : true;
                                        _hidePass = (_hidePass ==
                                                FontAwesomeIcons.eyeSlash)
                                            ? FontAwesomeIcons.eye
                                            : FontAwesomeIcons.eyeSlash;
                                      });
                                    })),
                        onSaved: (value) => _password = value,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: MaterialButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                if (validate()) {
                                  sendAuthRequest();
                                }
                              },
                              color: secondaryColor,
                              height: 70,
                              minWidth: 70,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                              child: Icon(
                                Icons.arrow_right_alt_sharp,
                                size: 50,
                                color: textWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/HomeScreen'),
                        child: Text('home'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
