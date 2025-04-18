import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:pigpen_iot/apps/home/userdevices/monitoring/monitoring_model.dart';
import 'package:pigpen_iot/services/internet_connection.dart';

// ignore: constant_identifier_names
const Duration TIMEOUT_TIME = Duration(seconds: 5);
// ignore: constant_identifier_names
const String TIMEOUT_MESSAGE = 'The operation has timeout';

class DeviceFirebase {
  final _database = FirebaseDatabase.instance;
  final _path = '/realtime/devices';

  Stream<DeviceData> deviceStream(String deviceId) {
    return _database.ref('$_path/$deviceId/readings').onValue.map((event) =>
        DeviceData.fromJson(event.snapshot.value as Map<Object?, Object?>?));
  }

  Future<void> setManualDuration({
    required String deviceId,
    required String type, // "drinkler" or "drum"
    required int duration, // e.g. 0 to 5
  }) async {
    await _database
        .ref('$_path/$deviceId/variables/manual_${type}_duration')
        .set(duration);
  }

  Future<void> updateDeviceName(String deviceId, String newName) async {
    await FirebaseDatabase.instance.ref('devices/$deviceId').update({
      'deviceName': newName,
    });
  }

  Stream<int> manualStatusStream({
    required String deviceId,
    required String type,
  }) {
    return _database
        .ref('$_path/$deviceId/variables/manual_${type}_duration')
        .onValue
        .map((event) => (event.snapshot.value ?? 0) as int);
  }
}

class ScheduleOperations with InternetConnection {
  final database = FirebaseDatabase.instance;
  final path = '/realtime/schedules/';

  // Future<DataSnapshot> getSchedules(String deviceId) async {
  //   return FirebaseDatabase.instance
  //       .ref(path)
  //       .child(deviceId)
  //       .get()
  //       .timeout(TIMEOUT_TIME);
  // }

  Stream<DatabaseEvent> listenToSchedules(String deviceId) {
    return database.ref(path).child(deviceId).orderByValue().onValue;
  }

  Future<void> uploadSchedule(String deviceId, DateTime dateTimePicked) async {
    // final key = database.ref(path).child(deviceId).push().key;
    // return database.ref(path).child(deviceId).update({
    //   dateTimePicked.toString(): dateTimePicked.toString(),
    // }).timeout(TIMEOUT_TIME);
    try {
      await database.ref(path).child(deviceId).update({
        dateTimePicked.toString().replaceFirst(".", " "):
            dateTimePicked.toString(),
      }).timeout(TIMEOUT_TIME);
    } catch (e) {
      debugPrint('Error uploading schedule: $e');
      // Optionally, show an alert or handle the error appropriately
    }
  }

  Future<void> overwriteSchedules(
      String deviceId, Map<Object?, Object?> schedules) {
    return database
        .ref(path)
        .child(deviceId)
        .set(schedules)
        .timeout(TIMEOUT_TIME);
  }

  Future<void> deleteSchedule(String deviceId, String databaseKey) async {
    // if (!await isConnected()) throw TimeoutException;
    return database
        .ref(path)
        .child(deviceId)
        .child(databaseKey)
        .remove()
        .timeout(TIMEOUT_TIME);
  }
}

class CarouselFirebase {
  Stream<DatabaseEvent> carouselContentsListen() {
    const String path = 'contents/home/carousel';
    return FirebaseDatabase.instance.ref(path).onValue;
  }
}

class TipsAndGuidesFirebase {
  Stream<DatabaseEvent> tipsContentsListen() {
    const String path = 'contents/home/tips/';
    return FirebaseDatabase.instance.ref(path).onValue;
  }
}

class ThingsFirebase {
  // Stream<DatabaseEvent> userDevicesListListen() {
  //   final String pathToDeviceList =
  //       'userdata/user_devices/${FirebaseAuth.instance.currentUser!.uid}';
  //   return FirebaseDatabase.instance.ref(pathToDeviceList).orderByKey().onValue;
  // }

  // Future<DataSnapshot> getAllPlantsGraphicUrl() {
  //   const String path = 'contents/home/plants/';
  //   return FirebaseDatabase.instance.ref(path).orderByKey().get();
  // }

  // Future<DataSnapshot> getDeployedDevices() {
  //   String path = 'devices/deployed/';
  //   return FirebaseDatabase.instance.ref(path).get();
  // }

  // Future<DataSnapshot> getUserDevicesList() {
  //   final String pathToDeviceList =
  //       'userdata/user_devices/${FirebaseAuth.instance.currentUser!.uid}';
  //   return FirebaseDatabase.instance.ref(pathToDeviceList).get();
  // }

  // Future<void> addDeviceToDatabase(
  //     {required String deviceid,
  //     required String graphic,
  //     required String name,
  //     required String url}) async {
  //   final dateNow = DateFormat("MM-dd-yyyy hh:mm:ss a").format(DateTime.now()).toString();
  //   final path = '/userdata/user_devices/${FirebaseAuth.instance.currentUser!.uid}';
  //   await FirebaseDatabase.instance.ref(path).child(dateNow).update({
  //     'deviceid': deviceid,
  //     'graphic': graphic,
  //     'name': name,
  //     'url': url,
  //   }).catchError((e) => debugPrint(e.toString()));
  // }
}

// class UserOperations {
// Stream<DatabaseEvent> userProfileListen() {
//   final String path =
//       'users/${FirebaseAuth.instance.currentUser!.uid}/profile';
//   return FirebaseDatabase.instance.ref(path).onValue;
// }

// Future<void> createUser(String? email) async {
//   if (email == null) return;
//   await FirebaseDatabase.instance
//       .ref('users/${FirebaseAuth.instance.currentUser!.uid}/profile')
//       .set({
//     'firstName': 'not-set-yet',
//     'lastName': 'not-set-yet',
//     'email': email,
//     'dateRegistered':
//         DateFormat("MM-dd-yyyy hh:mm a").format(DateTime.now()).toString(),
//     'things': 0
//   }).catchError((e) => debugPrint(e.toString()));
// }

// Future<void> updateName(String? fname, String lname) async {
//   await FirebaseDatabase.instance
//       .ref('users/${FirebaseAuth.instance.currentUser!.uid}/profile')
//       .update({'firstName': fname, 'lastName': lname}).catchError(
//           (e) => debugPrint(e.toString()));
// }

// Future<void> updateThings(int thingsCount) async {
//   await FirebaseDatabase.instance
//       .ref('users/${FirebaseAuth.instance.currentUser!.uid}/profile')
//       .update({'things': thingsCount}).timeout(const Duration(seconds: 5));
// }
// }

class AuthOperations with InternetConnection {
  final Function(FirebaseException e) authException;
  AuthOperations(this.authException);

  Future<User?> performLogin(
      TextEditingController email, TextEditingController password) async {
    // if (!await isConnected()) throw TimeoutException(TIMEOUT_MESSAGE);
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text.trim(), password: password.text.trim());
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      authException(e);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  // Future<User?> performRegister(
  //     TextEditingController email, TextEditingController password) async {
  //   if (!await isConnected()) throw TimeoutException(TIMEOUT_MESSAGE);

  //   try {
  //     final userCredential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(
  //             email: email.text.trim(), password: password.text.trim())
  //         .timeout(TIMEOUT_TIME);
  //     if (userCredential.user != null) {
  //       UserOperations userOperation = UserOperations();
  //       await userOperation.createUser(email.text.trim());
  //     }
  //     return userCredential.user;
  //   } on FirebaseAuthException catch (e) {
  //     authException(e);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   return null;
  // }

  // Future<bool?> updateDisplayName(
  //     TextEditingController fname, TextEditingController lname) async {
  //   if (!await isConnected()) throw TimeoutException(TIMEOUT_MESSAGE);

  //   // UserOperations userOperations = UserOperations();
  //   await userOperations
  //       .updateName(fname.text.trim(), lname.text.trim())
  //       .timeout(TIMEOUT_TIME);
  //   await FirebaseAuth.instance.currentUser
  //       ?.updateDisplayName(fname.text)
  //       .timeout(TIMEOUT_TIME);
  //   return true;
  // }
}
