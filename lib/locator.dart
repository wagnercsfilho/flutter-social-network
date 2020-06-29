import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_share/repositories/auth_repository.dart';
import 'package:flutter_share/states/auth_state.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerLazySingleton(() => AuthState(authRepository: locator()));

  locator.registerLazySingleton<AuthRepository>(() => AuthRepository(
        firebaseAuth: locator(),
        firestore: locator(),
        googleSignIn: locator(),
      ));

  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerLazySingleton<Firestore>(() => Firestore.instance);
  locator.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
}
