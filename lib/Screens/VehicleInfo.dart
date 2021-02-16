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
import 'file:///C:/Users/Niket/AndroidStudioProjects/vehicle_manager/lib/Screens/AddMaintenance.dart';
import '../Services/config.dart';

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
    getVehicleInfo();
    super.initState();
  }

  //scroll index
  int tabIndex = 0;

  //TODO:vehicle info section
  bool infoEdit = false, infoLoading;
  var vehicleInfoData;
  String infoVehicleName, infoVehicleRC, infoVehicleOwner, infoVehicleType;
  //api request
  void getVehicleInfo() async {
    setState(() {
      infoLoading = true;
    });
    var urlInfo = "${apiURL}vehicle/getVehicleInfo";
    final body = jsonEncode({"vehicleNumber": vehicleNumber});
    Map<String, String> header = {"Content-Type": "application/json"};

    Response response = await post(urlInfo, body: body, headers: header);
    print(response.statusCode);
    print(response.body);

    setState(() {
      vehicleInfoData = jsonDecode(response.body);
    });

    bool success = await vehicleInfoData['success'];

    if (success == true) {
      setState(() {
        infoVehicleType = vehicleInfoData["data"]["VehicleType"];
        infoVehicleOwner = vehicleInfoData["data"]["VehicleOwner"];
        infoVehicleRC = vehicleInfoData["data"]["VehicleRC"];
        infoVehicleName = vehicleInfoData["data"]["VehicleName"];
      });
    } else if (success == false) {
      String msg = await vehicleInfoData['msg'];
      showSnackBar(context, msg);
    }
    setState(() {
      infoLoading = false;
    });
  }

  // data pickers
  DateTime selectedDateInsurance = DateTime.now();
  DateTime selectedDateFitness = DateTime.now();
  Future<void> selectDate(String value) async {
    DateTime selectedDate;
    selectedDate =
        await datePicker(context: context, selectedDate: selectedDateInsurance);
    print(selectedDate);
    switch (value) {
      case 'Insurance':
        setState(() {
          selectedDateInsurance =
              (selectedDate == null) ? selectedDateInsurance : selectedDate;
        });
        break;
      case "Fitness":
        setState(() {
          selectedDateFitness =
              (selectedDate == null) ? selectedDateFitness : selectedDate;
        });
        break;
    }
  }

  //TODO:History section
  List repairHistoryList = [];

  bool getHistoryOnce = true, loadHistory = true, isRecordDelete = false;

  int repairTotalAmount;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void getRepairHistory() async {
    var responseHistoryData;
    List tempList = [];
    String urlHistory = "${apiURL}vehicle/getRepairHistory";
    print("URL for history is $urlHistory");

    final body = jsonEncode({"vehicleNumber": vehicleNumber});
    Map<String, String> header = {"Content-Type": "application/json"};

    Response response = await post(urlHistory, body: body, headers: header);
    print(response.statusCode);
    print(response.body);

    setState(() {
      responseHistoryData = jsonDecode(response.body);
    });

    bool success = await responseHistoryData['success'];
    if (success == true) {
      setState(() {
        tempList = responseHistoryData['data'];
        repairTotalAmount = tempList.last['totalAmount'];
        repairHistoryList =
            List.from(tempList.getRange(0, tempList.length - 1));
      });
      print(repairHistoryList);
      setState(() {
        loadHistory = false;
        getHistoryOnce = false;
      });
    } else if (success == false) {
      String msg = await responseHistoryData['msg'];
      setState(() {
        repairHistoryList = [];
        loadHistory = false;
        getHistoryOnce = false;
      });
      showSnackBar(context, msg);
    } else {
      setState(() {
        loadHistory = false;
        getHistoryOnce = false;
      });
      showSnackBar(context, "Something want wrong");
    }
  }

  void deleteRepairRecord(int repairID) async {
    print(repairID);
    Navigator.pop(context);
    setState(() {
      isRecordDelete = true;
    });
    if (isRecordDelete == true) {
      buildDialog(context);
    }

    var responseDeleteRecord;
    String urlDeleteRecord = "${apiURL}vehicle/deleteRepairRecord";
    print("URL for history is $urlDeleteRecord");

    final body = jsonEncode({"repairID": repairID});
    Map<String, String> header = {"Content-Type": "application/json"};

    Response response =
        await post(urlDeleteRecord, body: body, headers: header);
    print(response.statusCode);
    print(response.body);

    setState(() {
      responseDeleteRecord = jsonDecode(response.body);
    });

    bool success = await responseDeleteRecord['success'];

    if (success == true) {
      setState(() {
        isRecordDelete = false;
      });
      if (isRecordDelete == false) {
        Navigator.pop(context);
      }
      getRepairHistory();
      showSnackBar(context, "delete success");
    } else if (success == false) {
      String msg = await responseDeleteRecord['msg'];
      setState(() {
        isRecordDelete = false;
      });
      if (isRecordDelete == false) {
        Navigator.pop(context);
      }
      showSnackBar(context, msg);
    } else {
      setState(() {
        isRecordDelete = false;
      });
      if (isRecordDelete == false) {
        Navigator.pop(context);
      }
      showSnackBar(context, "Something want wrong");
    }
  }

  Future<void> _refresh() async {
    getRepairHistory();
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
                  tabIndex = tabController.index;
                });
              }
            });
            if (tabIndex == 2) {
              if (getHistoryOnce) {
                getRepairHistory();
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
                    visible: (tabIndex == 0) ? true : false,
                    child: IconButton(
                        icon: Icon(Icons.edit),
                        tooltip: 'Edit',
                        onPressed: () {
                          setState(() {
                            infoEdit = (infoEdit == false) ? true : false;
                          });
                        }),
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
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: (infoLoading)
                        ? Center(
                            child: SpinKitThreeBounce(
                              color: Colors.lightBlueAccent,
                            ),
                          )
                        : CustomScrollView(
                            slivers: [
                              SliverGrid(
                                  delegate: SliverChildListDelegate([
                                    gridCard(
                                        title: 'Vehicle Number',
                                        data: vehicleNumber,
                                        cardColor: textWhite),
                                    gridCard(
                                        title: 'Vehicle Type',
                                        data: (infoVehicleType == null)
                                            ? '-'
                                            : infoVehicleType,
                                        cardColor: (infoVehicleType == null)
                                            ? redWhite
                                            : textWhite),
                                    gridCard(
                                        title: 'Vehicle Name',
                                        data: (infoVehicleName == null)
                                            ? '-'
                                            : infoVehicleName,
                                        cardColor: (infoVehicleName == null)
                                            ? redWhite
                                            : textWhite),
                                    Card(
                                      elevation: 5,
                                      color: (selectedDateInsurance == null)
                                          ? redWhite
                                          : textWhite,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Insurance Upto',
                                              style: myTextStyle.copyWith(
                                                fontSize: 14,
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                      (selectedDateInsurance ==
                                                              null)
                                                          ? 'Expaired'
                                                          : "${selectedDateInsurance.day.toString()}/${selectedDateInsurance.month.toString()}/${selectedDateInsurance.year.toString()}",
                                                      style:
                                                          myTextStyle.copyWith(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                  Visibility(
                                                      visible: infoEdit,
                                                      child: GestureDetector(
                                                          onTap: () =>
                                                              selectDate(
                                                                  'Insurance'),
                                                          child: Icon(Icons
                                                              .date_range_rounded))),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    gridCard(
                                        title: 'Vehicle Owner',
                                        data: (infoVehicleOwner == null)
                                            ? '-'
                                            : infoVehicleOwner,
                                        cardColor: (infoVehicleOwner == null)
                                            ? redWhite
                                            : textWhite),
                                    Card(
                                      elevation: 5,
                                      color: (selectedDateFitness == null)
                                          ? redWhite
                                          : textWhite,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fitness Upto',
                                              style: myTextStyle.copyWith(
                                                fontSize: 14,
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    (selectedDateFitness ==
                                                            null)
                                                        ? 'Expaired'
                                                        : "${selectedDateFitness.day.toString()}/${selectedDateFitness.month.toString()}/${selectedDateFitness.year.toString()}",
                                                    style: myTextStyle.copyWith(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Visibility(
                                                      visible: infoEdit,
                                                      child: GestureDetector(
                                                          onTap: () =>
                                                              selectDate(
                                                                  "Fitness"),
                                                          child: Icon(Icons
                                                              .date_range_rounded))),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    gridCard(
                                        title: 'Vehicle RC',
                                        data: (infoVehicleRC == null)
                                            ? '-'
                                            : infoVehicleRC,
                                        cardColor: (infoVehicleRC == null)
                                            ? redWhite
                                            : textWhite),
                                  ]),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          childAspectRatio: 1.5)),
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Visibility(
                                    visible: infoEdit,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      elevation: 5,
                                      child: MaterialButton(
                                        height: 50,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        onPressed: () {
                                          setState(() {
                                            infoEdit = false;
                                          });
                                        },
                                        child: Text(
                                          'SUBMIT',
                                          style: myTextStyle.copyWith(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                              )
                            ],
                          ),
                  ),
                  AddMaintenance(vehicleNumber: vehicleNumber),
                  Container(
                    child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _refresh,
                        child: (repairHistoryList.isNotEmpty)
                            ? CustomScrollView(
                                slivers: [
                                  if (repairHistoryList.isNotEmpty)
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
                                                    "₹$repairTotalAmount",
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
                                                        "Are you sure to delete (${repairHistoryList[i]['repairId'].toString()}) maintenance report of rupees ₹${repairHistoryList[i]['amount']}",
                                                    ifYes: () =>
                                                        deleteRepairRecord(
                                                            repairHistoryList[i]
                                                                ['repairId']),
                                                    ifNo: () =>
                                                        Navigator.pop(context),
                                                  );
                                                });
                                            return null;
                                          },
                                          background: Container(
                                            color: redWhite,
                                            child: Icon(Icons.delete),
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
                                                          '${repairHistoryList[i]['repairId'].toString()} - ${repairHistoryList[i]['vehicleName']}',
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
                                                          "${repairHistoryList[i]['repairDate']}",
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
                                                        '₹${repairHistoryList[i]['amount']}',
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
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Description',
                                                          style: myTextStyle
                                                              .copyWith(
                                                                  fontSize: 10),
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        SizedBox(
                                                          width: 300,
                                                          height: 60,
                                                          child: Text(
                                                            "${repairHistoryList[i]['description']}",
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
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: repairHistoryList.length,
                                    ),
                                  )
                                ],
                              )
                            : ListView(
                                children: [
                                  SizedBox(
                                    height: myHeight * 0.35,
                                  ),
                                  (loadHistory)
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
