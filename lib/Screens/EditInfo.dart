import 'package:flutter/material.dart';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:vehicle_manager/Helper/PageHelper.dart';

class EditInfo extends StatefulWidget {
  final String vehicleNumber,
      vehicleName,
      vehicleType,
      vehicleOwner,
      vehicleRC,
      vehicleInsurance,
      vehicleFitness;
  EditInfo(
      {this.vehicleNumber,
      this.vehicleName,
      this.vehicleType,
      this.vehicleOwner,
      this.vehicleRC,
      this.vehicleInsurance,
      this.vehicleFitness});
  @override
  _EditInfoState createState() => _EditInfoState(vehicleNumber: vehicleNumber);
}

class _EditInfoState extends State<EditInfo> {
  final String vehicleNumber;
  _EditInfoState({@required this.vehicleNumber});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: secondaryColor,
          title: Text(
            "Edit Vehicle Info",
            style: myTextStyle.copyWith(),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
