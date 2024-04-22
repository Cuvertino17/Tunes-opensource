import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

var alreadyBox = Hive.box('already');
var Audiosetting = Hive.box('setting');
var history = Hive.box('history');
var likedBox = Hive.box('liked');

Widget emptyscreen(String mssg, String logo) {
  return Center(
      child: Container(
    alignment: Alignment.center,
    margin: EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          mssg,
          style: TextStyle(fontSize: 25),
        ),
        Text(
          ' $logo',
          style: TextStyle(fontSize: 30, color: Color(0xff1DB954)),
        )
      ],
    ),
  ));
}
