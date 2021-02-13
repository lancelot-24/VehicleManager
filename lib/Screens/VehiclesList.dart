import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Screens/VehicleInfo.dart';
import 'package:vehicle_manager/Widgets/PageHelper.dart';

import '../config.dart';
import 'AddVehicle.dart';

class VehiclesList extends StatefulWidget {
  @override
  _VehiclesListState createState() => _VehiclesListState();
}

class _VehiclesListState extends State<VehiclesList> {
//refresh indicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List vehiclesList = [];

  bool isDelete, isLoading;

  //url
  var url = "${apiURL}vehicle/getVehicleList";

  @override
  void initState() {
    getData();
    isDelete = false;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.initState();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });
    var responseData;
    try {
      Response response = await get(url);
      print(response.body);
      setState(() {
        responseData = jsonDecode(response.body);
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: Duration(seconds: 6),
      ));
    }
    setState(() {
      vehiclesList = responseData["data"];
    });

    bool success = await responseData['success'];
    print(success);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refresh() async {
    getData();
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
                  isDelete = (isDelete == false) ? true : false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 4, 0),
                child: Icon(Icons.delete),
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVehicle(),
                  )),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 10, 0),
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
        body: (vehiclesList.isNotEmpty)
            ? RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: ListView.builder(
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
                                visible: (isDelete == true) ? false : true,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 30,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isDelete,
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
                                          ifYes: () {},
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
                ),
              )
            : Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
                child: (isLoading)
                    ? Center(
                        child: SpinKitThreeBounce(
                          color: Colors.lightBlueAccent,
                        ),
                      )
                    : Text(
                        'Not added vehicle yet, \n you can add vehicle by clicking Plus(+) Button on right corner',
                        style: myTextStyle.copyWith(
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
      ),
    );
  }
}
