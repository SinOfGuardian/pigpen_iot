// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final logsProvider = FutureProvider.family
//     .autoDispose<List<String>, DateTime>((ref, dateTime) async {
//   final database = FirebaseDatabase.instance.ref();
//   final path = 'realtime/logs/pigpeniot-38eba81f8a3c'
//       '/year_${dateTime.year}'
//       '/month_${dateTime.month.toString().padLeft(2, '0')}'
//       '/day_${dateTime.day.toString().padLeft(2, '0')}'
//       '/hour_${dateTime.hour.toString().padLeft(2, '0')}'
//       '/minute_${dateTime.minute.toString().padLeft(2, '0')}';

//   final snapshot = await database.child(path).get();
// });
