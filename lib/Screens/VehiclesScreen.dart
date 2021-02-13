import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_manager/Screens/VehicleInfo.dart';
import 'package:vehicle_manager/Widgets/PageHelper.dart';

import 'AddVehicle.dart';

class VehiclesScreen extends StatefulWidget {
  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
//refresh indicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List vehicleNumber = [
    'MH20RS2000',
    'MH20RS2001',
    'MH20RS2002',
    'MH20RS2003',
    'MH20RS2004',
    'MH20RS2005',
    'MH20RS2006',
    'MH20RS2007',
    'MH20RS2008',
    'MH20RS2009',
    'MH20RS2010',
    'MH20RS2011',
    'MH20RS2012',
    'MH20RS2013',
    'MH20RS2014',
    'MH20RS2015',
  ];

  bool isDelete;

  @override
  void initState() {
    isDelete = false;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.initState();
  }

  Future<void> _refresh() async {
    // return getUser().then((_user) {
    //   setState(() => user = _user);
    // });
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
        body: (vehicleNumber.isNotEmpty)
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
                                  vehicleNumber: vehicleNumber[i]))),
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
                                    vehicleNumber[i],
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
                                              'Are you sure to delete ${vehicleNumber[i]} this vehicle',
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
                  itemCount: vehicleNumber.length,
                ),
              )
            : Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
                child: Text(
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
