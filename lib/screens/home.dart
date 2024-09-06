import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/helpers/homeUIhelper.dart';
import 'package:musichub/helpers/page_manager.dart';
import 'package:musichub/main.dart';
import 'package:musichub/miniplayer.dart';
import 'package:musichub/screens/search.dart';
import 'package:musichub/screens/settings.dart';
import 'package:musichub/themes/colors.dart';
import 'package:optimize_battery/optimize_battery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // List of texts to display
  final List<String> searchTexts = [
    'what do you want to listen?',
    'search for your favorite songs...',
    'find music you love...',
  ];

  // Current index of the text to display
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  late Timer _timer;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentIndexNotifier.value =
          (_currentIndexNotifier.value + 1) % searchTexts.length;
    });

    getIt<PageManager>().init();

    _requestPermissionsAndExecuteLogic();
  }

  _checkbatteryOpt() {
    OptimizeBattery.isIgnoringBatteryOptimizations().then((onValue) {
      print(onValue);
      setState(() {
        if (onValue) {
          print(onValue);
        } else {
          OptimizeBattery.stopOptimizingBatteryUsage();
        }
      });
    });
  }

  Future<void> _requestPermissionsAndExecuteLogic() async {
    // Check and request notification permission
    var notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      await Permission.notification.request();
    }

    // Check and request storage permission
    var storageStatus = await Permission.storage.status;
    if (storageStatus.isDenied) {
      await Permission.storage.request();
    }

    // Check and request location permission
    var locationStatus = await Permission.location.status;
    if (locationStatus.isDenied) {
      await Permission.location.request();
    }

    // Check if all permissions are granted
    bool allPermissionsGranted = await Permission.notification.isGranted &&
        await Permission.storage.isGranted &&
        await Permission.location.isGranted;

    if (allPermissionsGranted) {
      print('Notification, storage, and location permissions granted');
      // Execute your logic here, including geolocation and country retrieval
      await _getCountry();
    } else {
      // Request all permissions again if not granted
      var statuses = await [
        Permission.storage,
        Permission.notification,
        Permission.location,
      ].request();

      // Check if all permissions are granted after re-request
      if (statuses[Permission.notification]!.isGranted &&
          statuses[Permission.storage]!.isGranted &&
          statuses[Permission.location]!.isGranted) {
        print(
            'Notification, storage, and location permissions granted after re-request');
        // Execute your logic here, including geolocation and country retrieval
        await _getCountry();
      } else {
        print('Notification, storage, or location permission not granted');
      }
    }

    // Additional logic
    _checkbatteryOpt();
  }

  Future<void> _getCountry() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Reverse geocode to get country name
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      String country = placemarks[0].country ?? 'Unknown';
      print('Country: $country');

      // Store the country in Hive

      Audiosetting.put('country', country);
      print('Country stored in Hive: $country');
    } else {
      print('Unable to determine country');
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        // centerTitle: true,
        backgroundColor: black,
        leadingWidth: 150,
        title: Padding(
          padding: const EdgeInsets.only(top: 18.0, left: 10),
          child: Text(getGreeting()),
        ),
        // title: GestureDetector(
        //     onTap: () async {
        //       showDialog(
        //         context: context,
        //         barrierDismissible: true, // Make the dialog cancellable
        //         builder: (BuildContext context) {
        //           return buyMeACoffeePopUp(
        //               context); // Use the separate widget function
        //         },
        //       );
        //       // await launchBuyMeACoffee();
        //     },
        //     child: ClipRRect(
        //         borderRadius: const BorderRadius.all(Radius.circular(4)),
        //         child: Image.asset(
        //           "assets/unnamed.png",
        //           height: 30,
        //         ))),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsPage()));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 30),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const home()));
                },
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentIndexNotifier,
                  builder: (context, currentIndex, child) {
                    return Container(
                      height: 40,
                      margin: const EdgeInsets.only(
                          left: 10, right: 30, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Color.fromARGB(255, 101, 100, 100),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                searchTexts[currentIndex],
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 24, 23, 23)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const homeAlbumsUI(),
              const HomePlaylistsUI(),
              const homeRecentlyPlayedUI()
            ],
          ),
        ),
      ),

      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
