import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User(
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
  );

  User.fromDocument(DocumentSnapshot doc)
      : id = doc['id'],
        username = doc['username'],
        email = doc['email'],
        photoUrl = doc['photoUrl'],
        displayName = doc['displayName'],
        bio = doc['bio'];
}
