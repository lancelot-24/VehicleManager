import 'dart:convert';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:vehicle_manager/Helper/LoadingDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Screens/VehicleInfo.dart';
import 'package:vehicle_manager/Helper/PageHelper.dart';
import 'package:vehicle_manager/Helper/DeleteDialog.dart';
import '../Services/config.dart';

class VehiclesList extends StatefulWidget {
  @override
  _VehiclesListState createState() => _VehiclesListState();
}

class _VehiclesListState extends State<VehiclesList> {
  //refresh indicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  final GlobalKey<ScaffoldState> vehicleListKey =
      new GlobalKey<ScaffoldState>();
  List vehiclesList = [];
  bool isLoading, isDeleteVisible = false, isVehicleDelete = false;

  @override
  void initState() {
    getVehicleList();
    super.initState();
  }

  void getVehicleList() async {
    String url = "${apiURL}vehicle/getVehicleList";
    setState(() {
      isLoading = true;
    });
    var responseData;
    Response response =
        await get(url, headers: {"Content-Type": "application/json"});
    print(response.body);

    setState(() {
      responseData = jsonDecode(response.body);
    });
    bool success = await responseData['success'];

    if (success) {
      setState(() {
        isLoading = false;
      });

      setState(() {
        vehiclesList = responseData["data"];
      });
    } else if (!success) {
      String msg = await responseData['msg'];
      setState(() {
        isLoading = false;
        vehiclesList = [];
      });
      showSnackBar(context, msg);
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, "Something want wrong");
    }
  }

  Future<void> _refresh() async {
    getVehicleList();
  }

  void deleteVehicle(String vehicleNumber) async {
    Navigator.pop(context);
    setState(() {
      isVehicleDelete = true;
    });

    if (isVehicleDelete == true) {
      buildDialog(context);
    }
    var urlDeleteVehicle = "${apiURL}vehicle/deleteVehicle";
    print("Delete vehicle URL is $urlDeleteVehicle");

    var responseToDeleteRequest;
    Map<String, String> deleteVehicle = {
      'vehicleNumber': vehicleNumber,
    };

    Response response = await post(urlDeleteVehicle, body: deleteVehicle);
    print(response.statusCode);
    print(response.body);
    setState(() {
      responseToDeleteRequest = jsonDecode(response.body);
    });

    bool success = responseToDeleteRequest["success"];
    if (success == true) {
      setState(() {
        isVehicleDelete = false;
      });
      if (!isVehicleDelete) {
        Navigator.pop(context);
      }
      getVehicleList();
      showSnackBar(context, "Vehicle Deleted Successfully");
    } else if (success == false) {
      setState(() {
        isVehicleDelete = false;
      });
      if (isVehicleDelete == false) {
        Navigator.pop(context);
      }
      showSnackBar(context, "Failed To Delete Vehicle");
    } else {
      setState(() {
        isVehicleDelete = false;
      });
      if (isVehicleDelete == false) {
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
        key: vehicleListKey,
        backgroundColor: primaryColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: secondaryColor,
          title: Text(
            'Vehicles List',
            style: myTextStyle.copyWith(
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            InkWell(
              onTap: () {
                setState(() {
                  isDeleteVisible = (isDeleteVisible == false) ? true : false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 4, 0),
                child: Icon(Icons.delete),
              ),
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/AddVehicle'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 10, 0),
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: (vehiclesList.isNotEmpty)
              ? ListView.builder(
                  itemBuilder: (BuildContext context, int i) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VehicleInfo(
                                  vehicleNumber: vehiclesList[i]
                                      ["vehicleNumber"]))),
                      child: Container(
                        margin: EdgeInsets.only(top: 5),
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        height: 60,
                        child: Card(
                          elevation: 5,
                          color: textWhite,
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    vehiclesList[i]["vehicleNumber"],
                                    style: myTextStyle.copyWith(
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible:
                                    (isDeleteVisible == true) ? false : true,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 30,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isDeleteVisible,
                                child: IconButton(
                                  padding: EdgeInsets.only(right: 20),
                                  icon: Icon(
                                    Icons.delete,
                                    color: deleteIcon,
                                  ),
                                  onPressed: () => showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return deleteDialog(
                                          titleText:
                                              'Are you sure to delete ${vehiclesList[i]["vehicleNumber"]} this vehicle',
                                          ifYes: () {
                                            deleteVehicle(vehiclesList[i]
                                                ["vehicleNumber"]);
                                          },
                                          ifNo: () => Navigator.pop(context),
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: vehiclesList.length,
                )
              : ListView(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
                      child: (isLoading)
                          ? Center(
                              child: SpinKitThreeBounce(
                                color: Colors.lightBlueAccent,
                              ),
                            )
                          : Text(
                              'No vehicle please Add Vehicle',
                              style: myTextStyle.copyWith(
                                fontSize: 30,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
