import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

//colors constat
const Color textWhite = Colors.white;
const Color textBlack = Colors.black;
const Color deleteIcon = Color(0xfff00e0e);
const Color primaryColor = Color(0xffdee0de);
const Color secondaryColor = Color(0xff316879);

//itim text Style
TextStyle myTextStyle = GoogleFonts.adventPro();

//for textField Decoration
InputDecoration buildSignUpInputDecoration(String hint) {
  return InputDecoration(
    labelText: hint,
    labelStyle: myTextStyle.copyWith(color: secondaryColor),
    filled: true,
    fillColor: Colors.white,
    focusColor: Colors.white,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: secondaryColor, width: 1)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: secondaryColor, width: 1)),
    contentPadding: EdgeInsets.only(left: 14.0, bottom: 10.0, top: 10.0),
  );
}

//Spinkit Loading
buildDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SpinKitThreeBounce(
            color: Colors.lightBlueAccent,
          ),
        );
      });
}

//vehicle info cards fixed
Widget gridCard(String title, String data) {
  return Card(
    elevation: 5,
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

//delete Dialog

Widget deleteDialog({String titleText, VoidCallback ifYes, VoidCallback ifNo}) {
  return AlertDialog(
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
    content: Row(
      children: [
        Expanded(
          child: TextButton(
            child: Text(
              'Yes',
              style: myTextStyle.copyWith(
                color: textWhite,
              ),
            ),
            onPressed: ifYes,
          ),
        ),
        SizedBox(
            height: 30,
            child: VerticalDivider(
              thickness: 1,
              width: 10,
              color: textWhite,
            )),
        Expanded(
          child: TextButton(
            child: Text('No', style: myTextStyle.copyWith(color: textWhite)),
            onPressed: ifNo,
          ),
        ),
      ],
    ),
  );
}
