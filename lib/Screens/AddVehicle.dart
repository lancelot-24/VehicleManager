import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:vehicle_manager/Helper/LoadingDialog.dart';
import 'package:vehicle_manager/Helper/PageHelper.dart';
import 'package:vehicle_manager/Helper/TextFieldDecoration.dart';
import 'package:vehicle_manager/Services/SessionService.dart';
import 'package:vehicle_manager/Services/config.dart';

class AddVehicle extends StatefulWidget {
  @override
  _AddVehicleState createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  String _vehicleNumber, _vehicleType, _vehicleName, _vehicleOwner, _vehicleRC;
  final _formKey = GlobalKey<FormState>();
  bool _isAddLoading;

  @override
  void initState() {
    setState(() {
      _isAddLoading = false;
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

  void addVehicle() async {
    setState(() {
      _isAddLoading = true;
    });

    if (_isAddLoading == true) {
      buildDialog(context);
    }

    var _responseData;
    String _url = "${apiURL}vehicle/registerVehicle";

    String _userName = await getUserName();
    Map<String, String> _header = {"Content-Type": "application/json"};
    var _body = jsonEncode({
      'userName': _userName,
      'vehicleNumber': _vehicleNumber,
      'vehicleType': _vehicleType,
      'vehicleOwner': _vehicleOwner,
      'vehicleName': _vehicleName,
      'vehicleRC': (_vehicleRC != null) ? _vehicleRC : null,
    });

    Response response = await post(_url, body: _body, headers: _header);
    print(response.statusCode);
    print(response.body);

    setState(() {
      _responseData = jsonDecode(response.body);
    });

    bool _success = await _responseData['success'];

    if (_success) {
      setState(() {
        _isAddLoading = false;
      });

      if (!_isAddLoading) {
        Navigator.pop(context);
      }
      VehicleData();
    } else if (!_success) {
      String msg = await _responseData['msg'];
      setState(() {
        _isAddLoading = false;
      });

      if (!_isAddLoading) {
        Navigator.pop(context);
      }
      showSnackBar(context, msg);
    } else {
      setState(() {
        _isAddLoading = false;
      });

      if (!_isAddLoading) {
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
              key: _formKey,
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
                    onSaved: (value) => _vehicleNumber = value,
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
                    onSaved: (value) => _vehicleType = value,
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
                    onSaved: (value) => _vehicleName = value,
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
                    onSaved: (value) => _vehicleOwner = value,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      return null;
                    },
                    style: myTextStyle.copyWith(
                      fontSize: 22,
                    ),
                    decoration: buildSignUpInputDecoration('Vehicle RC'),
                    onSaved: (value) => _vehicleRC = value,
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

class VehicleData extends StatefulWidget {
  @override
  _VehicleDataState createState() => _VehicleDataState();
}

class _VehicleDataState extends State<VehicleData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
