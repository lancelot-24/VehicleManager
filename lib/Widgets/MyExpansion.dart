import 'package:flutter/material.dart';
import 'package:vehicle_manager/Widgets/PageHelper.dart';

class MyExpansion extends StatefulWidget {
  final String repairId, vehicleName, date, amount, description;
  final VoidCallback delete;
  MyExpansion(
      {this.repairId,
      this.vehicleName,
      this.date,
      this.amount,
      this.description,
      this.delete});
  @override
  _MyExpansionState createState() => _MyExpansionState(
      vehicleName: vehicleName,
      repairId: repairId,
      date: date,
      description: description,
      amount: amount,
      delete: delete);
}

class _MyExpansionState extends State<MyExpansion> {
  final String repairId, vehicleName, date, amount, description;
  final VoidCallback delete;
  _MyExpansionState(
      {this.repairId,
      this.vehicleName,
      this.date,
      this.amount,
      this.description,
      this.delete});
  IconData expansionIcon = Icons.keyboard_arrow_down;
  bool isExpand = false;

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
                        'Vehicle',
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
                    onTap: delete,
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
