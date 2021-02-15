import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Helper/Colors.dart';
import 'package:vehicle_manager/Helper/DeleteDialog.dart';
import 'package:vehicle_manager/Helper/LoadingDialog.dart';
import 'package:vehicle_manager/Helper/MyExpansion.dart';
import 'package:vehicle_manager/Helper/PageHelper.dart';
import 'package:vehicle_manager/Helper/TextFieldDecoration.dart';

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
    setState(() {
      isRequesting = false;
    });
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

  //TODO:maintenance section
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Maintenance ID = ${responseToAddRequest["data"]["id"]}',
                      textAlign: TextAlign.center,
                      style:
                          myTextStyle.copyWith(color: textWhite, fontSize: 18),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Maintenance Date = ${responseToAddRequest["data"]["MaintainanceDate"]}',
                      textAlign: TextAlign.center,
                      style:
                          myTextStyle.copyWith(color: textWhite, fontSize: 18),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Vehicle Number = ${responseToAddRequest["data"]["VehicleNumber"]}',
                      textAlign: TextAlign.center,
                      style:
                          myTextStyle.copyWith(color: textWhite, fontSize: 18),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Amount = ${responseToAddRequest["data"]["RepairCost"]}',
                      textAlign: TextAlign.center,
                      style:
                          myTextStyle.copyWith(color: textWhite, fontSize: 18),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Description = ${responseToAddRequest["data"]["RepairDescription"]}',
                      textAlign: TextAlign.center,
                      style:
                          myTextStyle.copyWith(color: textWhite, fontSize: 18),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextButton(
                      child: Text(
                        'OK',
                        textAlign: TextAlign.center,
                        style: myTextStyle.copyWith(
                            color: textWhite, fontSize: 24),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
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

  //TODO:History section
  List repairHistoryList = [];
  bool getHistoryOnce = true, loadHistory = true, isRecordDelete = false;
  String repairVehicleName, repairDate, repairDescription, repairAmount;
  int repairId, repairTotalAmount;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void getRepairHistory() async {
    var responseHistoryData;
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
        repairHistoryList = responseHistoryData['data'];
      });
      setState(() {
        loadHistory = false;
        getHistoryOnce = false;
      });
    } else if (success == false) {
      String msg = await responseHistoryData['msg'];
      setState(() {
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
                  Container(
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
                                        height: 100,
                                      ),
                                      TextFormField(
                                        textAlign: TextAlign.center,
                                        style: myTextStyle.copyWith(
                                          fontSize: 22.0,
                                        ),
                                        decoration: buildSignUpInputDecoration(
                                                vehicleNumber)
                                            .copyWith(
                                          disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: secondaryColor,
                                                  width: 1)),
                                        ),
                                        enabled: false,
                                      ),
                                      SizedBox(
                                        height: 50,
                                      ),
                                      TextFormField(
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return "Amount can't be empty";
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                        style:
                                            myTextStyle.copyWith(fontSize: 22),
                                        decoration:
                                            buildSignUpInputDecoration('Amount')
                                                .copyWith(
                                          prefix:
                                              Icon(FontAwesomeIcons.rupeeSign),
                                        ),
                                        onSaved: (value) => _amount = value,
                                      ),
                                      SizedBox(
                                        height: 30,
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
                                        decoration: buildSignUpInputDecoration(
                                                'Description')
                                            .copyWith(),
                                        onSaved: (value) =>
                                            _description = value,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        elevation: 5,
                                        child: MaterialButton(
                                          height: 50,
                                          minWidth: 300,
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          onPressed: () {
                                            if (validate()) {
                                              sendAddRequest(
                                                  _amount, _description);
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
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
                                                    "${repairHistoryList.last['totalAmount']}",
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
                                        (context, i) {
                                      repairAmount =
                                          repairHistoryList[i]['amount'];
                                      repairId =
                                          repairHistoryList[i]['repairId'];
                                      repairDate =
                                          repairHistoryList[i]['repairDate'];
                                      repairVehicleName =
                                          repairHistoryList[i]['vehicleName'];
                                      repairDescription =
                                          repairHistoryList[i]['description'];
                                      return MyExpansion(
                                        repairId: (repairId == null)
                                            ? '-'
                                            : repairId.toString(),
                                        vehicleName: (repairVehicleName == null)
                                            ? '-'
                                            : repairVehicleName,
                                        amount: (repairAmount == null)
                                            ? '-'
                                            : repairAmount,
                                        date: (repairDate == null)
                                            ? '-'
                                            : repairDate,
                                        description: (repairDescription == null)
                                            ? '-'
                                            : repairDescription,
                                        delete: () => showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return deleteDialog(
                                                titleText:
                                                    'Are you sure to delete ($repairId) maintenance report of rupees $repairAmount',
                                                ifYes: () => deleteRepairRecord(
                                                    repairId),
                                                ifNo: () =>
                                                    Navigator.pop(context),
                                              );
                                            }),
                                      );
                                    },
                                        childCount:
                                            repairHistoryList.length - 1),
                                  ),
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
