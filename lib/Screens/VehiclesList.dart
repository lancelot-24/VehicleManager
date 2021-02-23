import 'dart:convert';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:vehicle_manager/Helper/LoadingDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Helper/TextFieldDecoration.dart';
import 'package:vehicle_manager/Screens/VehicleInfo.dart';
import 'package:vehicle_manager/Helper/PageHelper.dart';
import 'package:vehicle_manager/Helper/DeleteDialog.dart';
import 'package:vehicle_manager/Services/SessionService.dart';
import '../Services/config.dart';

class VehiclesList extends StatefulWidget {
  @override
  _VehiclesListState createState() => _VehiclesListState();
}

class _VehiclesListState extends State<VehiclesList> {
  //refresh indicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  List _vehiclesList = [];
  List _showVehicle = [];
  bool _isLoading, _isDeleteVisible = false, _isVehicleDelete = false;

  @override
  void initState() {
    getVehicleList();
    super.initState();
    _controller.addListener(searchResultList);
  }

  //search vehicle List
  TextEditingController _controller = TextEditingController();

  String _searchNumber, _searchName;

  searchResultList() async {
    List showResult = [];
    if (_controller.text != '') {
      if (_vehiclesList.length != null) {
        for (int i = 0; i != _vehiclesList.length; i++) {
          _searchNumber = _vehiclesList[i]["vehicleNumber"];
          _searchName = _vehiclesList[i]["vehicleName"];
          if (_searchNumber
                  .toLowerCase()
                  .contains(_controller.text.toLowerCase()) ||
              _searchName
                  .toLowerCase()
                  .contains(_controller.text.toLowerCase())) {
            showResult.add(_vehiclesList[i]);
          }
        }
      }
    } else {
      showResult = List.from(_vehiclesList);
    }
    setState(() {
      _showVehicle = showResult;
    });
  }

  Future<void> getVehicleList() async {
    String _url = "${apiURL}vehicle/getVehicleList";
    setState(() {
      _isLoading = true;
    });
    var _responseData;
    Map<String, String> _header = {"Content-Type": "application/json"};
    String _userName = await getUserName();
    var _body = jsonEncode({
      'userName': _userName,
    });
    // Response response = await post(_url, headers: _header, body: _body);
    Response response = await get(_url, headers: _header);
    print(response.body);

    setState(() {
      _responseData = jsonDecode(response.body);
    });
    bool _success = await _responseData['success'];

    if (_success) {
      setState(() {
        _isLoading = false;
      });

      setState(() {
        _vehiclesList = _responseData["data"];
        _showVehicle = List.from(_vehiclesList);
      });
    } else if (!_success) {
      String msg = await _responseData['msg'];
      setState(() {
        _isLoading = false;
        _vehiclesList = [];
      });
      showSnackBar(context, msg);
    } else {
      setState(() {
        _isLoading = false;
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
      _isVehicleDelete = true;
    });

    if (_isVehicleDelete == true) {
      buildDialog(context);
    }
    var _url = "${apiURL}vehicle/deleteVehicle";
    print("Delete vehicle URL is $_url");

    var _responseData;
    Map<String, String> _header = {"Content-Type": "application/json"};
    String _userName = await getUserName();
    var _body = jsonEncode({
      'vehicleNumber': vehicleNumber,
      'userName': _userName,
    });

    Response response = await post(_url, body: _body, headers: _header);
    print(response.statusCode);
    print(response.body);
    setState(() {
      _responseData = jsonDecode(response.body);
    });

    bool _success = _responseData["success"];
    if (_success == true) {
      setState(() {
        _isVehicleDelete = false;
      });
      if (!_isVehicleDelete) {
        Navigator.pop(context);
      }
      getVehicleList();
      showSnackBar(context, "Vehicle Deleted Successfully");
    } else if (_success == false) {
      String msg = await _responseData['msg'];
      setState(() {
        _isVehicleDelete = false;
      });
      if (_isVehicleDelete == false) {
        Navigator.pop(context);
      }
      showSnackBar(context, msg);
    } else {
      setState(() {
        _isVehicleDelete = false;
      });
      if (_isVehicleDelete == false) {
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
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: (_vehiclesList.isNotEmpty)
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
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
                              _isDeleteVisible =
                                  (_isDeleteVisible == false) ? true : false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 4, 0),
                            child: Icon(Icons.delete),
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, '/AddVehicle'),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 10, 0),
                            child: Icon(Icons.add),
                          ),
                        ),
                      ],
                      expandedHeight: 130,
                      flexibleSpace: Container(
                        alignment: Alignment.bottomCenter,
                        color: secondaryColor,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                          child: TextField(
                            style: myTextStyle.copyWith(
                              fontSize: 22.0,
                            ),
                            controller: _controller,
                            decoration:
                                buildSignUpInputDecoration('Search').copyWith(
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(
                          height: 10,
                        ),
                      ]),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int i) {
                          return Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (isDismiss) {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return deleteDialog(
                                      titleText:
                                          'Are you sure to delete ${_showVehicle[i]["vehicleNumber"]} this vehicle',
                                      ifYes: () {
                                        deleteVehicle(
                                            _showVehicle[i]["vehicleNumber"]);
                                      },
                                      ifNo: () => Navigator.pop(context),
                                    );
                                  });
                              return null;
                            },
                            background: Container(
                              padding: EdgeInsets.only(right: 30),
                              color: redWhite,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(Icons.delete)),
                            ),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VehicleInfo(
                                          vehicleNumber: _showVehicle[i]
                                              ["vehicleNumber"]))),
                              child: SizedBox(
                                height: 80,
                                child: Card(
                                  margin: EdgeInsets.fromLTRB(5, 7, 5, 0),
                                  color: textWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            _showVehicle[i]["vehicleNumber"],
                                            style: myTextStyle.copyWith(
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: (_isDeleteVisible == true)
                                            ? false
                                            : true,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Icon(
                                            Icons.chevron_right,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: _isDeleteVisible,
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
                                                      'Are you sure to delete ${_showVehicle[i]["vehicleNumber"]} this vehicle',
                                                  ifYes: () {
                                                    deleteVehicle(
                                                        _showVehicle[i]
                                                            ["vehicleNumber"]);
                                                  },
                                                  ifNo: () =>
                                                      Navigator.pop(context),
                                                );
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _showVehicle.length,
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
                      child: (_isLoading)
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
