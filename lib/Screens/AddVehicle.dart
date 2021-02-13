import 'package:flutter/material.dart';
import 'package:vehicle_manager/Widgets/PageHelper.dart';

class AddVehicle extends StatefulWidget {
  @override
  _AddVehicleState createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  String vehicleNumber,
      vehicleType,
      vehicleName,
      vehicleOwner,
      insuranceUpto,
      fitnessUpto;
  final formKey = GlobalKey<FormState>();

  bool validate() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  DateTime selectedDate = DateTime.now();
  Future<void> _selectDateInsurance(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
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
          actions: [
            TextButton(
              child: Text('Save',
                  style:
                      myTextStyle.copyWith(color: Colors.white, fontSize: 20)),
              onPressed: () {
                if (validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 3),
                      content: Text(
                        '$vehicleNumber \n $vehicleType \n $vehicleName \n $vehicleOwner \n $insuranceUpto \n $fitnessUpto',
                        style: myTextStyle,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
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
                    decoration: buildSignUpInputDecoration('Vehicle Number'),
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
                    decoration: buildSignUpInputDecoration('Vehicle Type'),
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
                    decoration: buildSignUpInputDecoration('Vehicle Name'),
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
                    decoration: buildSignUpInputDecoration('Vehicle Owner'),
                    onSaved: (value) => vehicleOwner = value,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Insurance can't be empty";
                      }
                      return null;
                    },
                    style: myTextStyle.copyWith(
                      fontSize: 22,
                    ),
                    onTap: () {
                      _selectDateInsurance(context);
                    },
                    decoration: buildSignUpInputDecoration('Insurance'),
                    onSaved: (value) => insuranceUpto = value,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Fitness can't be empty";
                      }
                      return null;
                    },
                    style: myTextStyle.copyWith(
                      fontSize: 22,
                    ),
                    decoration: buildSignUpInputDecoration('Fitness'),
                    onSaved: (value) => fitnessUpto = value,
                  ),
                  SizedBox(
                    height: 15,
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
