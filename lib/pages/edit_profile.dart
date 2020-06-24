import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/widgets/header.dart';
import 'package:flutter_share/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  EditProfile({Key key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final userRef = Firestore.instance.collection('users');
  final auth = FirebaseAuth.instance;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final displayNameController = TextEditingController();
  final bioController = TextEditingController();

  User user;
  bool isLoading;

  bool _bioValid = true;
  bool _displayNameValid = true;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });

    final doc = await userRef.document(currentUser.id).get();
    user = User.fromDocument(doc);

    displayNameController.text = user.displayName;
    bioController.text = user.bio;

    setState(() {
      isLoading = false;
    });
  }

  updateProfile() async {
    displayNameController.text.trim().length < 3 ||
            displayNameController.text.isEmpty
        ? _displayNameValid = false
        : _displayNameValid = true;

    bioController.text.trim().length > 100
        ? _bioValid = false
        : _bioValid = true;

    if (_displayNameValid && _bioValid) {
      await userRef.document(user.id).updateData({
        'displayName': displayNameController.text,
        'bio': bioController.text,
      });

      final snackBar = SnackBar(content: Text('Profile updated'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }

    setState(() {});
  }

  logout() async {
    await auth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text('Display Name', style: TextStyle(color: Colors.grey)),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'Update Display Name',
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
          controller: displayNameController,
        ),
      ],
    );
  }

  buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text('Bio', style: TextStyle(color: Colors.grey)),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'Update Display Name',
            errorText: _bioValid ? null : "Bio too long",
          ),
          controller: bioController,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: 'Edit Profile'),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: CachedNetworkImageProvider(
                            user.photoUrl,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            SizedBox(
                              height: 8.0,
                            ),
                            buildBioField(),
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: updateProfile,
                        color: Theme.of(context).accentColor,
                        child: Text(
                          'Update profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                            onPressed: logout,
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            )),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
