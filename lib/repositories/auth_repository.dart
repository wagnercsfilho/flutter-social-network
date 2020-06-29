import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuth = FirebaseAuth.instance;
final userRef = Firestore.instance.collection('users');
final googleSignIn = GoogleSignIn();

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final Firestore firestore;
  final GoogleSignIn googleSignIn;

  CollectionReference userRef;

  AuthRepository({
    @required this.firebaseAuth,
    @required this.firestore,
    @required this.googleSignIn,
  }) {
    userRef = firestore.collection('users');
  }

  Future<User> getCurrentUser() {
    return firebaseAuth.currentUser().then((firebasUser) {
      return userRef.document(firebasUser.uid).get().then((value) {
        if (!value.exists) {
          return null;
        }

        return User.fromDocument(value);
      });
    });
  }

  Future<User> login() async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await firebaseAuth.signInWithCredential(credential)).user;

    DocumentSnapshot doc = await userRef.document(user.uid).get();
    final timestamp = DateTime.now();

    if (!doc.exists) {
      userRef.document(user.uid).setData({
        "id": user.uid,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await userRef.document(user.uid).get();
    }

    return User.fromDocument(doc);
  }
}
