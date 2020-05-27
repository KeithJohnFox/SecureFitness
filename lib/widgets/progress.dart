import 'package:flutter/material.dart';

//Circle loading icon 
Container circularProgress() {
  return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.0), //top padding
      child: CircularProgressIndicator( //gives circular spinner loading animation
        valueColor: AlwaysStoppedAnimation(Colors.orange), //color of loading spinner
      ));
}

//Straight Bar loading icon
Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0), //bottom padding
    child: LinearProgressIndicator( //Linear loading animation
      valueColor: AlwaysStoppedAnimation(Colors.blue),
    ),
  );
}
