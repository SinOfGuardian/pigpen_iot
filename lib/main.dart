import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pigpen_iot/modules/sharedprefs.dart';
import 'package:pigpen_iot/router.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
    // final router = ref.watch(router);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PigPen IoT',
      routerConfig: router,
    );
  }
}
