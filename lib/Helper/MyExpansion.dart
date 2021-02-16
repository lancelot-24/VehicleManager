import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:vehicle_manager/Services/config.dart';
import 'Colors.dart';
import 'DeleteDialog.dart';
import 'LoadingDialog.dart';
import 'PageHelper.dart';

class MyExpansion extends StatefulWidget {
  final String repairId, vehicleName, date, amount, description;
  MyExpansion({
    this.repairId,
    this.vehicleName,
    this.date,
    this.amount,
    this.description,
  });
  @override
  _MyExpansionState createState() => _MyExpansionState(
        vehicleName: vehicleName,
        repairId: repairId,
        date: date,
        description: description,
        amount: amount,
      );
}

class _MyExpansionState extends State<MyExpansion> {
  final String repairId, vehicleName, date, amount, description;

  _MyExpansionState({
    this.repairId,
    this.vehicleName,
    this.date,
    this.amount,
    this.description,
  });

  @override
  void initState() {
    super.initState();
  }

  IconData expansionIcon = Icons.keyboard_arrow_down;
  bool isExpand = false, isRecordDelete = false;

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repair ID',
                        style: myTextStyle.copyWith(fontSize: 10),
                      ),
                      Text(
                        '$repairId - $vehicleName',
                        style: myTextStyle.copyWith(fontSize: 14),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Date',
                        style: myTextStyle.copyWith(fontSize: 10),
                      ),
                      Text(
                        date,
                        style: myTextStyle.copyWith(fontSize: 24),
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: myTextStyle.copyWith(fontSize: 10),
                    ),
                    Text(
                      '₹$amount',
                      style: myTextStyle.copyWith(fontSize: 24),
                    ),
                    IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(expansionIcon),
                      onPressed: () {
                        setState(() {
                          isExpand = (isExpand == true) ? false : true;
                          expansionIcon =
                              (expansionIcon == Icons.keyboard_arrow_down)
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
            Visibility(
              visible: isExpand,
              child: SizedBox(
                height: 8,
              ),
            ),
            Visibility(
              visible: isExpand,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Description',
                          style: myTextStyle.copyWith(fontSize: 10),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          description,
                          style: myTextStyle.copyWith(fontSize: 16),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return deleteDialog(
                            titleText:
                                "Are you sure to delete ($repairId) maintenance report of rupees $amount",
                            ifYes: () =>
                                deleteRepairRecord(int.parse(repairId)),
                            ifNo: () => Navigator.pop(context),
                          );
                        }),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                      child: Icon(
                        Icons.delete,
                        color: deleteIcon,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
