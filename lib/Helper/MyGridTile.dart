import 'package:flutter/material.dart';
import 'PageHelper.dart';

class MyGridTile extends StatelessWidget {
  final String title, data;
  final Color cardColor;
  MyGridTile(
      {@required this.title, @required this.data, @required this.cardColor});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: myTextStyle.copyWith(
                fontSize: 14,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  data,
                  textAlign: TextAlign.center,
                  style: myTextStyle.copyWith(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
