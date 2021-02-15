import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:vehicle_manager/Helper/LoadingDialog.dart';
import 'package:vehicle_manager/Helper/PageHelper.dart';
import 'package:vehicle_manager/Helper/TextFieldDecoration.dart';
import 'package:vehicle_manager/Services/config.dart';

class AddVehicle extends StatefulWidget {
  @override
  _AddVehicleState createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  String vehicleNumber, vehicleType, vehicleName, vehicleOwner, vehicleRC;
  final formKey = GlobalKey<FormState>();
  bool _isAddLoading;

  @override
  void initState() {
    setState(() {
      _isAddLoading = false;
    });
    super.initState();
  }

  bool validate() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  var responseToAddRequest;

  void addVehicle() async {
    setState(() {
      _isAddLoading = true;
    });

    if (_isAddLoading == true) {
      buildDialog(context);
    }
    print('in1');
    var urlAddVehicle = "${apiURL}vehicle/registerVehicle";
    Map<String, String> addVehicle = {
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'vehicleOwner': vehicleOwner,
      'vehicleName': vehicleName,
      'vehicleRC': vehicleRC,
    };
    print('in2');

    try {
      Response response = await post(urlAddVehicle, body: addVehicle);

      print(response.body);

      setState(() {
        responseToAddRequest = jsonDecode(response.body);
      });
    } catch (e) {
      setState(() {
        _isAddLoading = false;
      });
      if (_isAddLoading == false) {
        Navigator.pop(context);
      }
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: Duration(seconds: 6),
      ));
    }
    bool success = responseToAddRequest["success"];

    setState(() {
      _isAddLoading = false;
    });
    if (_isAddLoading == false) {
      Navigator.pop(context);
    }
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Vehicle Added'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: secondaryColor,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Add Vehicle',
            style: myTextStyle,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Vehicle Number can't be empty";
                      }
                      return null;
                    },
                    style: myTextStyle.copyWith(fontSize: 22),
                    decoration: buildSignUpInputDecoration('Vehicle Number *'),
                    onSaved: (value) => vehicleNumber = value,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Vehicle Type can't be empty";
                      }
                      return null;
                    },
                    style: myTextStyle.copyWith(
                      fontSize: 22,
                    ),
                    decoration: buildSignUpInputDecoration('Vehicle Type *'),
                    onSaved: (value) => vehicleType = value,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Vehicle Name can't be empty";
                      }
                      return null;
                    },
                    style: myTextStyle.copyWith(
                      fontSize: 22,
                    ),
                    decoration: buildSignUpInputDecoration('Vehicle Name *'),
                    onSaved: (value) => vehicleName = value,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Vehicle Owner can't be empty";
                      }
                      return null;
                    },
                    style: myTextStyle.copyWith(
                      fontSize: 22,
                    ),
                    decoration: buildSignUpInputDecoration('Vehicle Owner *'),
                    onSaved: (value) => vehicleOwner = value,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Vehicle can't be empty";
                      }
                      return null;
                    },
                    style: myTextStyle.copyWith(
                      fontSize: 22,
                    ),
                    decoration: buildSignUpInputDecoration('Vehicle RC *'),
                    onSaved: (value) => vehicleRC = value,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    color: secondaryColor,
                    child: MaterialButton(
                      height: 50,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onPressed: () {
                        if (validate()) {
                          addVehicle();
                        }
                      },
                      child: Text(
                        'Add Vehicle',
                        style: myTextStyle.copyWith(
                          fontSize: 24,
                          color: textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
