import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Model/UserData.dart';
import 'package:vehicle_manager/Widgets/PageHelper.dart';
import 'file:///C:/Users/Niket/AndroidStudioProjects/vehicle_manager/lib/Services/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _userName, _password;
  final formKey = GlobalKey<FormState>();
  var userAuthCheck;
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

  @override
  void dispose() {
    setState(() {
      _isLoading = false;
    });
    super.dispose();
  }

  var url = "${apiURL}userLogin";

  bool validate() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void onSubmit() {
    if (validate()) {
      sendAuthRequest();
    }
  }

  void sendAuthRequest() async {
    setState(() {
      _isLoading = true;
    });

    if (_isLoading == true) {
      buildDialog(context);
    }

    print('url is $url');
    Map<String, String> userData = {
      'userName': _userName,
      'userPassword': _password,
    };

    try {
      Response response = await post(url, body: userData);
      print(response.body);
      setState(() {
        userAuthCheck = jsonDecode(response.body);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (_isLoading == false) {
        Navigator.pop(context);
      }
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: Duration(seconds: 6),
      ));
    }

    checkUserAuth();
  }

  void checkUserAuth() async {
    //authentication check
    bool success = await userAuthCheck['success'];

    //for flutter session
    String name = await userAuthCheck['data']['name'];
    int uid = await userAuthCheck['data']['uid'];

    await saveData(uid, name);

    //authentication check and then nevigate to next page
    print(success);
    if (success) {
      setState(() {
        _isLoading = false;
      });
      if (_isLoading == false) {
        Navigator.pop(context);
      }
      Navigator.pushReplacementNamed(context, '/HomeScreen');
    } else {
      setState(() {
        _isLoading = false;
      });
      if (_isLoading == false) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Wrong Username or Password'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  //for user session data
  Future<void> saveData(int uid, String name) async {
    UserData userData = UserData(uid: uid, name: name);

    await FlutterSession().set('userData', userData);
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
                  key: formKey,
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
                              onPressed: onSubmit,
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
