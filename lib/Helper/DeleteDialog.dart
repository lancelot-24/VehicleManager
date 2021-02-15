import 'package:flutter/material.dart';
import 'Colors.dart';
import 'PageHelper.dart';

Widget deleteDialog({String titleText, VoidCallback ifYes, VoidCallback ifNo}) {
  return SimpleDialog(
    backgroundColor: secondaryColor,
    title: Center(
      child: Text(
        titleText,
        textAlign: TextAlign.center,
        style: myTextStyle.copyWith(
          color: textWhite,
        ),
      ),
    ),
    contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    children: [
      Divider(
        thickness: 1,
        height: 20,
        color: textWhite,
      ),
      Row(
        children: [
          Expanded(
            child: TextButton(
              child: Text(
                'Yes',
                style: myTextStyle.copyWith(color: textWhite, fontSize: 20),
              ),
              onPressed: ifYes,
            ),
          ),
          SizedBox(
              height: 48,
              child: VerticalDivider(
                thickness: 1,
                width: 10,
                color: textWhite,
              )),
          Expanded(
            child: TextButton(
              child: Text('No',
                  style: myTextStyle.copyWith(color: textWhite, fontSize: 20)),
              onPressed: ifNo,
            ),
          ),
        ],
      ),
    ],
  );
}
