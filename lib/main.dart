import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/modules/sharedprefs.dart';
import 'package:pigpen_iot/router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pigpen_iot/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await intializations();

  // Ensure status and navigation bars are visible
  SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge); // Show status & nav bars
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(0, 255, 255, 255), // Transparent status bar
    systemNavigationBarColor:
        Color.fromARGB(255, 0, 0, 0), // Bottom navigation bar color
    systemNavigationBarIconBrightness: Brightness.dark, // Icon color
  ));

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> intializations() async {
  // Lock to portrait orientation only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Firebase
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  // Set Firebase locale
  await FirebaseAuth.instance.setLanguageCode('en');

  // Initialize Shared Preferences
  await SharedPrefs.init();

  // Initialize time zone database
  tz.initializeTimeZones();

  // Initialize NotificationService
  await NotificationService.init();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PigPen IoT',
      routerConfig: router,
    );
  }
}
