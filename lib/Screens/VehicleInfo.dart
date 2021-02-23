import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:vehicle_manager/Helper/DeleteDialog.dart';
import 'package:vehicle_manager/Helper/LoadingDialog.dart';
import 'package:vehicle_manager/Helper/PageHelper.dart';
import 'package:vehicle_manager/Services/SessionService.dart';
import '../Services/config.dart';
import 'AddMaintenance.dart';
import 'package:vehicle_manager/Helper/MyGridTile.dart';
import 'EditInfo.dart';

class VehicleInfo extends StatefulWidget {
  final String vehicleNumber;
  VehicleInfo({@required this.vehicleNumber});
  @override
  _VehicleInfoState createState() =>
      _VehicleInfoState(vehicleNumber: vehicleNumber);
}

class _VehicleInfoState extends State<VehicleInfo> {
  final String vehicleNumber;
  _VehicleInfoState({@required this.vehicleNumber});

  @override
  void initState() {
    _getVehicleInfo();
    super.initState();
  }

  //scroll index
  int _tabIndex = 0;

  //TODO:vehicle info section
  bool _infoLoading;
  String _infoVehicleName, _infoVehicleRC, _infoVehicleOwner, _infoVehicleType;
  //api request
  void _getVehicleInfo() async {
    setState(() {
      _infoLoading = true;
    });

    var _vehicleInfoData;
    var _urlInfo = "${apiURL}vehicle/getVehicleInfo";
    String _userName = await getUserName();

    final _body =
        jsonEncode({"vehicleNumber": vehicleNumber, "userName": _userName});
    Map<String, String> _header = {"Content-Type": "application/json"};

    Response response = await post(_urlInfo, body: _body, headers: _header);
    print(response.statusCode);
    print(response.body);

    setState(() {
      _vehicleInfoData = jsonDecode(response.body);
    });

    bool _success = await _vehicleInfoData['success'];

    if (_success == true) {
      setState(() {
        _infoVehicleType = _vehicleInfoData["data"]["VehicleType"];
        _infoVehicleOwner = _vehicleInfoData["data"]["VehicleOwner"];
        _infoVehicleRC = _vehicleInfoData["data"]["VehicleRC"];
        _infoVehicleName = _vehicleInfoData["data"]["VehicleName"];
      });
    } else if (_success == false) {
      String _msg = await _vehicleInfoData['msg'];
      showSnackBar(context, _msg);
    }
    setState(() {
      _infoLoading = false;
    });
  }

  // data pickers
  DateTime _selectedDateInsurance = DateTime.now();
  DateTime _selectedDateFitness = DateTime.now();
  Future<void> _selectDate(String value) async {
    DateTime _selectedDate;
    _selectedDate = await datePicker(
        context: context, selectedDate: _selectedDateInsurance);
    print(_selectedDate);
    switch (value) {
      case 'Insurance':
        setState(() {
          _selectedDateInsurance =
              (_selectedDate == null) ? _selectedDateInsurance : _selectedDate;
        });
        break;
      case "Fitness":
        setState(() {
          _selectedDateFitness =
              (_selectedDate == null) ? _selectedDateFitness : _selectedDate;
        });
        break;
    }
  }

  //TODO:History section
  List _repairHistoryList = [];

  bool _getHistoryOnce = true, _loadHistory = true, _isRecordDelete = false;

  int _repairTotalAmount;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void _getRepairHistory() async {
    var _responseData;
    List _tempList = [];
    String _url = "${apiURL}vehicle/getRepairHistory";
    print("URL for history is $_url");

    String _userName = await getUserName();
    final _body =
        jsonEncode({"vehicleNumber": vehicleNumber, "userName": _userName});
    Map<String, String> _header = {"Content-Type": "application/json"};

    Response response = await post(_url, body: _body, headers: _header);
    print(response.statusCode);
    print(response.body);

    setState(() {
      _responseData = jsonDecode(response.body);
    });

    bool _success = await _responseData['success'];
    if (_success == true) {
      setState(() {
        _tempList = _responseData['data'];
        _repairTotalAmount = _tempList.last['totalAmount'];
        _repairHistoryList =
            List.from(_tempList.getRange(0, _tempList.length - 1));
      });
      print(_repairHistoryList);
      setState(() {
        _loadHistory = false;
        _getHistoryOnce = false;
      });
    } else if (_success == false) {
      String msg = await _responseData['msg'];
      setState(() {
        _repairHistoryList = [];
        _loadHistory = false;
        _getHistoryOnce = false;
      });
      showSnackBar(context, msg);
    } else {
      setState(() {
        _loadHistory = false;
        _getHistoryOnce = false;
      });
      showSnackBar(context, "Something want wrong");
    }
  }

  void _deleteRepairRecord(int repairID) async {
    print(repairID);
    Navigator.pop(context);
    setState(() {
      _isRecordDelete = true;
    });
    if (_isRecordDelete == true) {
      buildDialog(context);
    }

    var _responseDeleteRecord;
    String _url = "${apiURL}vehicle/deleteRepairRecord";
    print("URL for history is $_url");

    String _userName = await getUserName();
    final _body = jsonEncode({"repairID": repairID, "userName": _userName});
    Map<String, String> _header = {"Content-Type": "application/json"};

    Response response = await post(_url, body: _body, headers: _header);
    print(response.statusCode);
    print(response.body);

    setState(() {
      _responseDeleteRecord = jsonDecode(response.body);
    });

    bool _success = await _responseDeleteRecord['success'];

    if (_success == true) {
      setState(() {
        _isRecordDelete = false;
      });
      if (_isRecordDelete == false) {
        Navigator.pop(context);
      }
      _getRepairHistory();
      showSnackBar(context, "delete success");
    } else if (_success == false) {
      String msg = await _responseDeleteRecord['msg'];
      setState(() {
        _isRecordDelete = false;
      });
      if (_isRecordDelete == false) {
        Navigator.pop(context);
      }
      showSnackBar(context, msg);
    } else {
      setState(() {
        _isRecordDelete = false;
      });
      if (_isRecordDelete == false) {
        Navigator.pop(context);
      }
      showSnackBar(context, "Something want wrong");
    }
  }

  Future<void> _refresh() async {
    _getRepairHistory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Builder(
          builder: (BuildContext context) {
            final TabController tabController =
                DefaultTabController.of(context);
            tabController.addListener(() {
              if (!tabController.indexIsChanging) {
                setState(() {
                  _tabIndex = tabController.index;
                });
              }
            });
            if (_tabIndex == 2) {
              if (_getHistoryOnce) {
                _getRepairHistory();
              }
            }
            return Scaffold(
              backgroundColor: primaryColor,
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  vehicleNumber,
                  style: myTextStyle,
                ),
                elevation: 0,
                backgroundColor: secondaryColor,
                actions: [
                  Visibility(
                    visible: (_tabIndex == 0) ? true : false,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditInfo(
                              vehicleNumber: vehicleNumber,
                              vehicleName: _infoVehicleName,
                              vehicleOwner: _infoVehicleOwner,
                              vehicleRC: _infoVehicleRC,
                              vehicleType: _infoVehicleType,
                              vehicleInsurance:
                                  "${_selectedDateInsurance.day.toString()}/${_selectedDateInsurance.month.toString()}/${_selectedDateInsurance.year.toString()}",
                              vehicleFitness:
                                  "${_selectedDateInsurance.day.toString()}/${_selectedDateInsurance.month.toString()}/${_selectedDateInsurance.year.toString()}",
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 18, 15, 0),
                        child: Text(
                          "Edit",
                          style: myTextStyle.copyWith(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: TabBar(
                  unselectedLabelColor: textWhite,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: secondaryColor,
                  labelStyle: myTextStyle,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    color: textWhite,
                  ),
                  tabs: [
                    myTab(
                      'Vehicle Info',
                      FontAwesomeIcons.addressCard,
                    ),
                    myTab(
                      'Add Maintenance',
                      FontAwesomeIcons.receipt,
                    ),
                    myTab(
                      'History',
                      FontAwesomeIcons.history,
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
                    child: (_infoLoading)
                        ? Center(
                            child: SpinKitThreeBounce(
                              color: Colors.lightBlueAccent,
                            ),
                          )
                        : CustomScrollView(
                            slivers: [
                              SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 5,
                                        crossAxisSpacing: 5,
                                        childAspectRatio: 1.5),
                                delegate: SliverChildListDelegate([
                                  MyGridTile(
                                      title: 'Vehicle Number',
                                      data: vehicleNumber,
                                      cardColor: textWhite),
                                  MyGridTile(
                                      title: 'Vehicle Type',
                                      data: (_infoVehicleType == null)
                                          ? '-'
                                          : _infoVehicleType,
                                      cardColor: (_infoVehicleType == null)
                                          ? redWhite
                                          : textWhite),
                                  MyGridTile(
                                      title: 'Vehicle Name',
                                      data: (_infoVehicleName == null)
                                          ? '-'
                                          : _infoVehicleName,
                                      cardColor: (_infoVehicleName == null)
                                          ? redWhite
                                          : textWhite),
                                  MyGridTile(
                                    title: 'Insurance Upto',
                                    data: (_selectedDateInsurance == null)
                                        ? 'Expaired'
                                        : "${_selectedDateInsurance.day.toString()}/${_selectedDateInsurance.month.toString()}/${_selectedDateInsurance.year.toString()}",
                                    cardColor: (_selectedDateInsurance == null)
                                        ? redWhite
                                        : textWhite,
                                  ),
                                  MyGridTile(
                                      title: 'Vehicle Owner',
                                      data: (_infoVehicleOwner == null)
                                          ? '-'
                                          : _infoVehicleOwner,
                                      cardColor: (_infoVehicleOwner == null)
                                          ? redWhite
                                          : textWhite),
                                  MyGridTile(
                                    title: 'Fitness Upto',
                                    data: (_selectedDateFitness == null)
                                        ? 'Expaired'
                                        : "${_selectedDateFitness.day.toString()}/${_selectedDateFitness.month.toString()}/${_selectedDateFitness.year.toString()}",
                                    cardColor: (_selectedDateFitness == null)
                                        ? redWhite
                                        : textWhite,
                                  ),
                                  MyGridTile(
                                      title: 'Vehicle RC',
                                      data: (_infoVehicleRC == null)
                                          ? '-'
                                          : _infoVehicleRC,
                                      cardColor: (_infoVehicleRC == null)
                                          ? redWhite
                                          : textWhite),
                                ]),
                              ),
                            ],
                          ),
                  ),
                  AddMaintenance(vehicleNumber: vehicleNumber),
                  Container(
                    child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _refresh,
                        child: (_repairHistoryList.isNotEmpty)
                            ? CustomScrollView(
                                slivers: [
                                  if (_repairHistoryList.isNotEmpty)
                                    SliverList(
                                      delegate: SliverChildListDelegate([
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 100,
                                          child: Card(
                                            elevation: 5,
                                            color: textWhite,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 0, 20, 0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Total',
                                                      style:
                                                          myTextStyle.copyWith(
                                                        fontSize: 30,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "₹$_repairTotalAmount",
                                                    style: myTextStyle.copyWith(
                                                      fontSize: 30,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int i) {
                                        return Dismissible(
                                          key: UniqueKey(),
                                          direction:
                                              DismissDirection.endToStart,
                                          confirmDismiss: (isDismiss) {
                                            print("tried");
                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) {
                                                  return deleteDialog(
                                                    titleText:
                                                        "Are you sure to delete (${_repairHistoryList[i]['repairId'].toString()}) maintenance report of rupees ₹${_repairHistoryList[i]['amount']}",
                                                    ifYes: () =>
                                                        _deleteRepairRecord(
                                                            _repairHistoryList[
                                                                i]['repairId']),
                                                    ifNo: () =>
                                                        Navigator.pop(context),
                                                  );
                                                });
                                            return null;
                                          },
                                          background: Container(
                                            padding: EdgeInsets.only(right: 30),
                                            color: redWhite,
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Icon(Icons.delete)),
                                          ),
                                          child: Card(
                                            elevation: 5,
                                            child: ExpansionTile(
                                              tilePadding: EdgeInsets.fromLTRB(
                                                  6, 2, 10, 2),
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Repair ID',
                                                          style: myTextStyle
                                                              .copyWith(
                                                                  fontSize: 10),
                                                        ),
                                                        Text(
                                                          '${_repairHistoryList[i]['repairId'].toString()} - ${_repairHistoryList[i]['vehicleName']}',
                                                          style: myTextStyle
                                                              .copyWith(
                                                                  fontSize: 14),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          'Date',
                                                          style: myTextStyle
                                                              .copyWith(
                                                                  fontSize: 10),
                                                        ),
                                                        Text(
                                                          "${_repairHistoryList[i]['repairDate']}",
                                                          style: myTextStyle
                                                              .copyWith(
                                                                  fontSize: 24),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Amount',
                                                        style: myTextStyle
                                                            .copyWith(
                                                                fontSize: 10),
                                                      ),
                                                      Text(
                                                        '₹${_repairHistoryList[i]['amount']}',
                                                        style: myTextStyle
                                                            .copyWith(
                                                                fontSize: 18),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              childrenPadding:
                                                  EdgeInsets.fromLTRB(
                                                      6, 2, 6, 4),
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Description',
                                                            style: myTextStyle
                                                                .copyWith(
                                                                    fontSize:
                                                                        10),
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            "${_repairHistoryList[i]['description']}",
                                                            softWrap: true,
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: myTextStyle
                                                                .copyWith(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.delete),
                                                      onPressed: () =>
                                                          showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return deleteDialog(
                                                                  titleText:
                                                                      "Are you sure to delete (${_repairHistoryList[i]['repairId'].toString()}) maintenance report of rupees ₹${_repairHistoryList[i]['amount']}",
                                                                  ifYes: () => _deleteRepairRecord(
                                                                      _repairHistoryList[
                                                                              i]
                                                                          [
                                                                          'repairId']),
                                                                  ifNo: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                );
                                                              }),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: _repairHistoryList.length,
                                    ),
                                  )
                                ],
                              )
                            : ListView(
                                children: [
                                  SizedBox(
                                    height: myHeight * 0.35,
                                  ),
                                  (_loadHistory)
                                      ? Center(
                                          child: SpinKitThreeBounce(
                                            color: Colors.lightBlueAccent,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                          'No Maintenance Done Yet',
                                          style: myTextStyle.copyWith(
                                              fontSize: 30),
                                        )),
                                ],
                              )),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
