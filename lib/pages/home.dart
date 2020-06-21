import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/activity_feed.dart';
import 'package:flutter_share/pages/create_account.dart';
import 'package:flutter_share/pages/profile.dart';
import 'package:flutter_share/pages/search.dart';
import 'package:flutter_share/pages/timeline.dart';
import 'package:flutter_share/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignIn = GoogleSignIn();
final userRef = Firestore.instance.collection('users');
User currentUser;

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  final PageController pageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen(handleSignIn);
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore(account);
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  Future<void> createUserInFirestore(GoogleSignInAccount account) async {
    DocumentSnapshot doc = await userRef.document(account.id).get();
    final timestamp = DateTime.now();

    if (!doc.exists) {
      final username = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateAccount()),
      );

      userRef.document(account.id).setData({
        "id": account.id,
        "username": username,
        "photoUrl": account.photoUrl,
        "email": account.email,
        "displayName": account.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await userRef.document(account.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  void onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  login() {
    googleSignIn.signIn();
  }

  signOut() {
    googleSignIn.signOut();
  }

  onTap(int pageIndex) {
    print(pageIndex);
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: pageIndex,
        onTap: onTap,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            title: Text('Timeline'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            title: Text('Notifications'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            title: Text('Create'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
        ],
      ),
    );
  }

  buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Up!',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/google_signin_button.png'),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isAuth ? buildAuthScreen() : buildUnAuthScreen(),
    );
  }
}
