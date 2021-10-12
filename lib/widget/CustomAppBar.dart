import 'package:flutter/material.dart';

customAppBar(title) {
  return AppBar(
    backgroundColor: Colors.white,
    // AppBar 배경 색상
    // elevation: 0.0, //
    centerTitle: false,
    elevation: 0.0,
    title: Text(title,
        style: TextStyle(fontFamily: 'SLEIGothic', fontSize: 30, fontWeight: FontWeight.bold, color: Colors.lightBlue)),
  );
}
