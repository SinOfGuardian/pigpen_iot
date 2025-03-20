import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/modules/sharedprefs.dart';
import 'package:pigpen_iot/router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pigpen_iot/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await intializations();

  // Initialize time zone database
  tz.initializeTimeZones();

  // Initialize NotificationService
  await NotificationService().init();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> intializations() async {
  // Lock to portrait orientation only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // // Fullscreen and automtatically hides status bar
  // SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.immersiveSticky,
  // );

  // Fire up and Initialize Firebase
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  // Exit the app when error in release mode
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('error: $details');
    // if (kReleaseMode) exit(1);
  };

  // Initialize Shared Preferences
  await SharedPrefs.init();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //  Listen to the notification response stream
    return StreamBuilder<String?>(
      stream: NotificationService().notificationResponseStream,
      builder: (context, snapshot) {
        // Handle notification tap
        if (snapshot.hasData) {
          final payload = snapshot.data;
          debugPrint('Notification tapped with payload: $payload');

          // Navigate to a specific screen or perform an action
          // Example: Navigate to the schedules page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.push('/schedules'); // Replace with your desired route
          });
        }

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'PigPen IoT',
          routerConfig: router,
        );
      },
    );
  }
}
