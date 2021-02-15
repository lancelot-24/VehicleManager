import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//itim text Style
TextStyle myTextStyle = GoogleFonts.adventPro();

//datapicker
Future<DateTime> datePicker(
    {BuildContext context, DateTime selectedDate}) async {
  final DateTime picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(3000),
  );

  if (picked != null && picked != selectedDate) {
    selectedDate = picked;
  }
  return picked;
}

//vehicle info cards fixed
Widget gridCard({String title, String data, Color cardColor}) {
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

//Tab Widget
Widget myTab(String text, IconData icon) {
  return Tab(
    icon: Icon(
      icon,
      size: 20,
    ),
    text: text,
  );
}

//snackBar
showSnackBar(BuildContext context, String msg) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    duration: Duration(seconds: 4),
  ));
}
