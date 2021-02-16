import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:vehicle_manager/Helper/PageHelper.dart';
import 'package:vehicle_manager/Helper/TextFieldDecoration.dart';
import '../Services/config.dart';

class AddMaintenance extends StatefulWidget {
  final String vehicleNumber;
  AddMaintenance({@required this.vehicleNumber});
  @override
  _AddMaintenanceState createState() =>
      _AddMaintenanceState(vehicleNumber: vehicleNumber);
}

class _AddMaintenanceState extends State<AddMaintenance> {
  final String vehicleNumber;
  _AddMaintenanceState({@required this.vehicleNumber});

  @override
  void initState() {
    super.initState();
  }

  final formKey = GlobalKey<FormState>();

  String _amount, _description;
  bool isRequesting = false;

  var responseToAddRequest;

  //validate function for form
  bool validate() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Text infoText({@required String msg}) {
    return Text(
      msg,
      style: myTextStyle.copyWith(color: textWhite, fontSize: 18),
    );
  }

  //on submit send request
  void sendAddRequest(String amount, String description) async {
    var urlAddMaintenance = "${apiURL}vehicle/addNewMaintainance";
    setState(() {
      isRequesting = true;
    });
    final addMaintenanceModel = jsonEncode({
      'vehicleNumber': vehicleNumber,
      'repairCost': amount,
      'repairText': description,
    });
    Map<String, String> header = {"Content-Type": "application/json"};

    Response response = await post(urlAddMaintenance,
        body: addMaintenanceModel, headers: header);
    print(response.statusCode);
    print(response.body);

    setState(() {
      responseToAddRequest = jsonDecode(response.body);
    });

    bool success = responseToAddRequest["success"];
    setState(() {
      isRequesting = false;
    });

    if (success == true) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text(
                'Maintenance Added',
              ),
              backgroundColor: secondaryColor,
              titleTextStyle:
                  myTextStyle.copyWith(color: textWhite, fontSize: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      infoText(
                          msg:
                              'Maintenance ID = ${responseToAddRequest["data"]["id"]}'),
                      SizedBox(
                        height: 8,
                      ),
                      infoText(msg: 'Maintenance Date = ${DateTime.now()}'),
                      SizedBox(
                        height: 8,
                      ),
                      infoText(
                          msg:
                              'Vehicle Number = ${responseToAddRequest["data"]["VehicleNumber"]}'),
                      SizedBox(
                        height: 8,
                      ),
                      infoText(
                          msg:
                              'Amount = ${responseToAddRequest["data"]["RepairCost"]}'),
                      SizedBox(
                        height: 8,
                      ),
                      infoText(
                          msg:
                              'Description = ${responseToAddRequest["data"]["RepairDescription"]}'),
                      SizedBox(
                          height: 46,
                          width: double.infinity,
                          child: Center(
                            child: TextButton(
                              child: Text(
                                'OK',
                                textAlign: TextAlign.center,
                                style: myTextStyle.copyWith(
                                    color: textWhite, fontSize: 24),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            );
          });
    } else if (success == false) {
      String msg = responseToAddRequest["msg"];
      showSnackBar(context, msg);
    } else {
      showSnackBar(context, "Something want wrong");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return Container(
      child: (isRequesting)
          ? Center(
              child: SpinKitThreeBounce(
                color: Colors.lightBlueAccent,
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: myHeight * 0.09,
                        ),
                        Container(
                          width: myWidth,
                          height: 46,
                          decoration: BoxDecoration(
                            border: Border.all(color: secondaryColor),
                            borderRadius: BorderRadius.circular(10),
                            color: textWhite,
                          ),
                          child: Center(
                            child: Text(
                              vehicleNumber,
                              style: myTextStyle.copyWith(
                                color: secondaryColor,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: myHeight * 0.08,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Amount can't be empty";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          style: myTextStyle.copyWith(fontSize: 22),
                          decoration:
                              buildSignUpInputDecoration('Amount').copyWith(
                            prefix: Icon(FontAwesomeIcons.rupeeSign),
                          ),
                          onSaved: (value) => _amount = value,
                        ),
                        SizedBox(
                          height: myHeight * 0.04,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Description can't be empty";
                            }
                            return null;
                          },
                          style: myTextStyle.copyWith(
                            fontSize: 22,
                          ),
                          maxLines: 4,
                          decoration: buildSignUpInputDecoration('Description')
                              .copyWith(),
                          onSaved: (value) => _description = value,
                        ),
                        SizedBox(
                          height: myHeight * 0.04,
                        ),
                        MaterialButton(
                          color: Colors.white,
                          height: 50,
                          minWidth: 300,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onPressed: () {
                            if (validate()) {
                              sendAddRequest(_amount, _description);
                            }
                          },
                          child: Text(
                            'SUBMIT',
                            style: myTextStyle.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
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
