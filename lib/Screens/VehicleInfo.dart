import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Widgets/MyExpansion.dart';
import 'package:vehicle_manager/Widgets/PageHelper.dart';

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
    getData();
    setState(() {
      isRequesting = false;
    });
    super.initState();
  }

  //TODO:vehicle info section
  bool infoEdit = false, infoLoading;
  var vehicleInfoData;
  String infoVehicleName, infoVehicleRC, infoVehicleOwner, infoVehicleType;
  //api request
  void getData() async {
    var urlInfo = "${apiURL}vehicle/getVehicleInfo";
    setState(() {
      infoLoading = true;
    });
    try {
      Response response =
          await post(urlInfo, body: {"vehicleNumber": vehicleNumber});
      print(response.body);
      setState(() {
        vehicleInfoData = jsonDecode(response.body);
      });
      print('vehicle Info response = $vehicleInfoData');
    } catch (e) {
      setState(() {
        infoLoading = false;
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: Duration(seconds: 6),
      ));
    }
    dynamic success = await vehicleInfoData['success'];
    print(success);
    if (success == true) {
      setState(() {
        infoVehicleType = vehicleInfoData["data"]["VehicleType"];
        infoVehicleOwner = vehicleInfoData["data"]["VehicleOwner"];
        infoVehicleRC = vehicleInfoData["data"]["VehicleRC"];
        infoVehicleName = vehicleInfoData["data"]["VehicleName"];
      });
    }

    if (success == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(vehicleInfoData["msg"]),
        duration: Duration(seconds: 4),
      ));
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
    Map<String, String> addMaintenanceModel = {
      'vehicleNumber': vehicleNumber,
      'repairCost': amount,
      'repairText': description,
    };

    try {
      Response response =
          await post(urlAddMaintenance, body: addMaintenanceModel);
      print(response.body);
      setState(() {
        responseToAddRequest = jsonDecode(response.body);
      });
    } catch (e) {
      setState(() {
        isRequesting = false;
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: Duration(seconds: 6),
      ));
    }
    setState(() {
      isRequesting = false;
    });

    bool success = responseToAddRequest["success"];

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
    }
  }

  //TODO:History section
  List repairHistoryList = [];
  bool getHistoryOnce = true, loadHistory = true;
  String repairVehicleName, repairDate, repairDescription, repairAmount;
  int repairId, repairTotalAmount;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  var urlHistory = "${apiURL}vehicle/getRepairHistory";

  void getRepairHistory() async {
    var responseHistoryData;
    try {
      Response response =
          await post(urlHistory, body: {"vehicleNumber": vehicleNumber});
      print(response.body);
      setState(() {
        responseHistoryData = jsonDecode(response.body);
      });
      print('this is response data from History $responseHistoryData');
    } catch (e) {
      setState(() {
        loadHistory = false;
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: Duration(seconds: 6),
      ));
    }
    dynamic success = responseHistoryData['success'];
    if (success == true) {
      setState(() {
        repairHistoryList = responseHistoryData['data'];
      });
    }

    setState(() {
      loadHistory = false;
      getHistoryOnce = false;
    });
  }

  void setVehicleHistory(int i) async {
    repairAmount = repairHistoryList[i]['amount'];
    repairId = repairHistoryList[i]['repairId'];
    repairDate = repairHistoryList[i]['repairDate'];
    repairVehicleName = repairHistoryList[i]['vehicleName'];
    repairDescription = repairHistoryList[i]['description'];
  }

  Future<void> _refresh() async {
    getRepairHistory();
  }

  //scroll index
  int tabIndex = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      child: (loadHistory)
                          ? Center(
                              child: SpinKitThreeBounce(
                                color: Colors.lightBlueAccent,
                              ),
                            )
                          : CustomScrollView(
                              slivers: [
                                SliverList(
                                  delegate:
                                      SliverChildBuilderDelegate((context, i) {
                                    setVehicleHistory(i);
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
                                                  'Are you sure to delete',
                                              ifYes: () {},
                                              ifNo: () =>
                                                  Navigator.pop(context),
                                            );
                                          }),
                                    );
                                  }, childCount: repairHistoryList.length - 1),
                                ),
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
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Total',
                                                    style: myTextStyle.copyWith(
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
                                  )
                              ],
                            ),
                    ),
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
