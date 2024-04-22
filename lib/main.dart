import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
 
import 'package:musichub/helpers/admanager.dart';
import 'package:musichub/helpers/download.dart';
import 'package:musichub/screens/home.dart';
import 'package:musichub/themes/colors.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // await Hive.openBox('saved');
  await Hive.openBox('history');
  await Hive.openBox('liked');
  adinit();
  runApp(MyApp());
}

adinit() async {
  await MobileAds.instance.initialize();

  // await MobileAds.instance.initialize();
  await Hive.openBox('setting');
  await Hive.openBox('already');

  // await Hive.openBox('history');

  await NotificationService().initNotification();
   
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: 'circular',
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: black),
        home: const home());
  }
}
