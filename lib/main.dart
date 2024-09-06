import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:musichub/helpers/MyAudioHandler.dart';
import 'package:musichub/helpers/page_manager.dart';
import 'package:musichub/notifiers/gradient_notifier.dart';
import 'package:musichub/screens/home.dart';
import 'package:musichub/themes/colors.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('login');
  await Hive.initFlutter();
  const supabaseUrl = 'https://vlcaeklcsipijbnxsqba.supabase.co';
  await Supabase.initialize(
      url: supabaseUrl,
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZsY2Fla2xjc2lwaWpibnhzcWJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTk4MTY0NTIsImV4cCI6MjAzNTM5MjQ1Mn0.X0-EmSVxp8tIAcLmxSGmGtTUAW5mPsoqW3glzGg0x1Q");
  // await Hive.openBox('saved');
  await Hive.openBox('history');
  await Hive.openBox('liked');
  await Hive.openBox('recents');
  await Hive.openBox('playlists');
  await setupServiceLocator();
  adinit();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        debugPrint('notification payload: ${response.payload}');
      }
    },
  );
  // runApp(MyApp());
  final themeNotifier = ThemeNotifier();
  runApp(
    ChangeNotifierProvider(
      create: (_) => themeNotifier,
      child: MyApp(),
    ),
  );
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Hive.initFlutter();
//   await Hive.openBox('settingsBox'); // Open your settings box
//   await Hive.openBox('login');
//   await Hive.openBox('history');
//   await Hive.openBox('liked');
//   await Hive.openBox('recents');
//   await Hive.openBox('already');

//   await Supabase.initialize(
//       url: 'https://vlcaeklcsipijbnxsqba.supabase.co',
//       anonKey: 'YOUR_SUPABASE_ANON_KEY');

//   await setupServiceLocator();
//   adinit();

//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   final InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);

//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: (NotificationResponse response) async {
//       if (response.payload != null) {
//         debugPrint('notification payload: ${response.payload}');
//       }
//     },
//   );

//   runApp(MyApp());
// }

GetIt getIt = GetIt.instance;
setupServiceLocator() async {
  //  getIt.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());
  getIt.registerLazySingleton<ThemeNotifier>(() => ThemeNotifier());
  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());
  // getIt<PageManager>().init();
  getIt.registerSingleton<AudioHandler>(await initAudioService());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
adinit() async {
  await Hive.openBox('setting');
  await Hive.openBox('already');
  // checkPermission();
  // checkpermissionnotif();
}

final supabase = Supabase.instance.client;

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
      home: LandingPage(),
      // home: FutureBuilder<bool>(
      //   future: checkLoginBoxContent(), // Check if login box has content
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(
      //         body: Center(
      //           child: CircularProgressIndicator(),
      //         ),
      //       );
      //     } else {
      //       if (snapshot.hasData && snapshot.data == true) {
      //         // If login box has content, navigate to home
      //         return const home();
      //       } else {
      //         // If login box is empty, navigate to login page
      //         return AuthScreen();
      //       }
      //     }
      //   },
      // ),
    );
  }
}

// Future<bool> checkLoginBoxContent() async {
//   final hasContent = LoginBox.isNotEmpty;
//   return hasContent;
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//             create: (_) => ThemeProvider()), // Provide ThemeProvider
//       ],
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProvider, child) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             theme: themeProvider.currentTheme, // Apply the current theme
//             home: LandingPage(), // Your main screen
//           );
//         },
//       ),
//     );
//   }
// }
