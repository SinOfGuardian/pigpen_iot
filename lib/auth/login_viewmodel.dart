import 'package:riverpod/src/framework.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pigpen_iot/models/auth_model.dart';
import 'package:pigpen_iot/services/internet_connection.dart';
import 'package:firebase_auth/firebase_auth.dart';


part 'login_viewmodel.g.dart';

@riverpod
class ShowPasswordLogin extends _$ShowPasswordLogin {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void reset() => state = false;
}

@Riverpod(keepAlive: true)
class Login extends _$Login {
  @override
  AuthUser build() => AuthUser.clear();
  void clear() => state = AuthUser.clear();

  void update({String? email, String? password, String? password2}) {
    state =
        state.copyWith(email: email, password: password, password2: password2);
  }

  final _auth = FirebaseAuth.instance;
  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Future<UserCredential?> loginWithGoogle() async {
  //   try {
      // Sign in with Google
      // final googleUser = await _googleSignIn.signIn();
      // if (googleUser == null) return null; // User canceled the sign-in

      // final googleAuth = await googleUser.authentication;

      // Obtain credentials for Firebase
      // final cred = GoogleAuthProvider.credential(
      //   idToken: googleAuth.idToken,
      //   accessToken: googleAuth.accessToken,
      // );

      // Sign in with Firebase using the Google credentials
    //   final userCredential = await _auth.signInWithCredential(cred);

    //   // Fetch or initialize user data in Firebase Realtime Database
    //   final user = userCredential.user;
    //   if (user != null) {
    //     await _initializeUserInDatabase(user);
    //   }

    //   return userCredential;
    // } catch (e) {
    //   print('Error during Google Sign-In: $e');
    //   return null;
    // }
  }

//GOOGLE LOG OUT
  Future<void> logout() async {
    try {
      // Sign out from Firebase
     // await _auth.signOut();

      // Sign out from Google if the user signed in with Google
      // if (await _googleSignIn.isSignedIn()) {
      //   await _googleSignIn.signOut();
      // }

      // Optionally, clear the local user state
      // ref.invalidate(activeUserProvider);
     // clear();
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }

  // Future<void> _initializeUserInDatabase(User user) async {
  //   final DatabaseReference userRef =
  //       FirebaseDatabase.instance.ref('users/${user.uid}/profile');
  //   final snapshot = await userRef.get();

  //   // If the user profile does not exist, create a new one
  //   if (!snapshot.exists) {
  //     final dateRegistered =
  //         DateFormat("MM-dd-yyyy hh:mm a").format(DateTime.now());
  //     final newUser = PlantitoUser(
  //       userId: user.uid,
  //       email: user.email ?? '',
  //       firstname: user.displayName?.split(' ').first ?? '',
  //       lastname: user.displayName?.split(' ').skip(1).join(' ') ?? '',
  //       dateRegistered: dateRegistered,
  //       role: 'user',
  //       things: 0,
  //       profileImageUrl: user.photoURL ?? '',
  //     );
  //     await userRef.set(newUser.toJson());
  //   }
  // }

// //NATHANIEL
//   Future<String?> fetchUserRole(User user) async {
//     // Create a reference to the user's role field in the database
//     final DatabaseReference userRoleRef =
//         FirebaseDatabase.instance.ref("users/${user.uid}/profile/role");
//     final snapshot = await userRoleRef.get();
//     if (snapshot.exists) {
//       return snapshot.value as String?;
//     }
//     return null;
//   }
// }

@riverpod
class LoginFields extends _$LoginFields with InternetConnection {
  @override
  AuthFieldsMessage build() => const AuthFieldsMessage();

  void updateState(AuthFieldsMessage newState) => state = newState;

  void resetLoginFields() => ref.invalidateSelf();

  void resetEmail() => state = state
      .cloneWith(AuthFieldsMessage(passwordMessage: state.passwordMessage));

  void resetPassword() => state =
      state.cloneWith(AuthFieldsMessage(emailMessage: state.emailMessage));

  bool validateFields(ProviderListenable loginProvider) {
    final emailFormat = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    final authUser = ref.read(loginProvider);
    bool isValid = true;
    AuthFieldsMessage newState = const AuthFieldsMessage();
    if (authUser.email.isEmpty) {
      isValid = false;
      newState = newState.copyWith(emailMessage: 'Please enter email');
    } else if (!emailFormat.hasMatch(authUser.email)) {
      isValid = false;
      newState = newState.copyWith(emailMessage: 'Please enter valid email');
    }
    if (authUser.password.isEmpty) {
      isValid = false;
      newState = newState.copyWith(passwordMessage: 'Please enter a password');
    }
    state = newState;
    return isValid;
  }
}
