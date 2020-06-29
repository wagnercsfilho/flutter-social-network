import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/pages/activity_screen.dart';
import 'package:flutter_share/pages/profile_screen.dart';
import 'package:flutter_share/pages/search_screen.dart';
import 'package:flutter_share/pages/timeline_screen.dart';
import 'package:flutter_share/pages/upload_screen.dart';
import 'package:flutter_share/states/auth_state.dart';
import 'package:provider/provider.dart';

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
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onTap(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  buildAuthScreen() {
    final state = Provider.of<AuthState>(context);
    print(state.currentUser);

    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: <Widget>[
          TimelineScreen(),
          ActivityScreen(),
          UploadScreen(currentUser: state.currentUser),
          SearchScreen(),
          ProfileScreen(profileId: state.currentUser?.id),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Container(child: buildAuthScreen());
  }
}
