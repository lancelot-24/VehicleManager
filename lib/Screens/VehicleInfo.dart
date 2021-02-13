import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vehicle_manager/Widgets/MyExpansion.dart';
import 'package:vehicle_manager/Widgets/PageHelper.dart';

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
  final formKey = GlobalKey<FormState>();
  String _amount, _detail;
  bool edit = false;
  DateTime selectedDate = DateTime.now();
  DateTime selectedDateFitness = DateTime.now();
  int tabIndex = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _selectDateInsurance(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectDateFitness(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDateFitness,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );

    if (picked != null && picked != selectedDateFitness) {
      setState(() {
        selectedDateFitness = picked;
      });
    }
  }

  bool validate() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
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
                            edit = true;
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
                    padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
                    child: CustomScrollView(
                      slivers: [
                        SliverGrid(
                            delegate: SliverChildListDelegate([
                              gridCard('Vehicle Number', vehicleNumber),
                              gridCard('Vehicle Type', 'LVC-NT'),
                              gridCard('Vehicle Name', 'Activa'),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                                "${selectedDate.day.toString()}/${selectedDate.month.toString()}/${selectedDate.year.toString()}",
                                                style: myTextStyle.copyWith(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Visibility(
                                                visible: edit,
                                                child: GestureDetector(
                                                    onTap: () =>
                                                        _selectDateInsurance(
                                                            context),
                                                    child: Icon(Icons
                                                        .date_range_rounded))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              gridCard('Vehicle Owner', 'Some One '),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              "${selectedDateFitness.day.toString()}/${selectedDateFitness.month.toString()}/${selectedDateFitness.year.toString()}",
                                              style: myTextStyle.copyWith(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Visibility(
                                                visible: edit,
                                                child: GestureDetector(
                                                    onTap: () =>
                                                        _selectDateFitness(
                                                            context),
                                                    child: Icon(Icons
                                                        .date_range_rounded))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                              height: 40,
                            ),
                            Visibility(
                              visible: edit,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                                child: MaterialButton(
                                  height: 50,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  onPressed: () {
                                    setState(() {
                                      edit = false;
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
                    child: SingleChildScrollView(
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
                                  decoration:
                                      buildSignUpInputDecoration(vehicleNumber)
                                          .copyWith(
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: secondaryColor, width: 1)),
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
                                  style: myTextStyle.copyWith(fontSize: 22),
                                  decoration:
                                      buildSignUpInputDecoration('Amount')
                                          .copyWith(
                                    prefix: Icon(FontAwesomeIcons.rupeeSign),
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
                                  decoration:
                                      buildSignUpInputDecoration('Description')
                                          .copyWith(),
                                  onSaved: (value) => _detail = value,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'amount is $_amount \n detail is $_detail'),
                                          duration: Duration(seconds: 5),
                                        ));
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
                      child: CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate((context, i) {
                              return MyExpansion(
                                vehicleNumber: vehicleNumber,
                                vehicleName: 'Activa',
                                amount: '10',
                                date: '20/10/2021',
                                description: 'Air Refile 2 tires',
                                delete: () => showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return deleteDialog(
                                        titleText: 'Are you sure to delete',
                                        ifYes: () {},
                                        ifNo: () => Navigator.pop(context),
                                      );
                                    }),
                              );
                            }, childCount: 10),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 100,
                                child: Card(
                                  elevation: 5,
                                  color: textWhite,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                                          '₹100',
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
