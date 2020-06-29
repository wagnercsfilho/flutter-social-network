import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/post_model.dart';
import 'package:flutter_share/pages/edit_profile_screen.dart';
import 'package:flutter_share/pages/home_screen.dart';
import 'package:flutter_share/states/auth_state.dart';
import 'package:flutter_share/widgets/header.dart';
import 'package:flutter_share/widgets/post_item.dart';
import 'package:flutter_share/widgets/post_tile.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../widgets/progress.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;

  ProfileScreen({Key key, this.profileId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userRef = Firestore.instance.collection('users');
  final postRef = Firestore.instance.collection('posts');

  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  String postOrientation = 'grid';

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    final snapshot = await postRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  setPostOrientation(String oriention) {
    setState(() {
      postOrientation = oriention;
    });
  }

  buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  buildButton({String text, Function function}) {
    return Expanded(
      child: FlatButton(
        onPressed: function,
        child: Container(
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    final state = Provider.of<AuthState>(context);
    final isCurrentProfile = widget.profileId == state.currentUser.id;

    if (isCurrentProfile) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    }

    return buildButton(text: "Follow", function: () => {});
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(),
      ),
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(snapshot.data);

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn('posts', postCount),
                            buildCountColumn('posts', 0),
                            buildCountColumn('posts', 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[buildProfileButton()],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  user.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2),
                child: Text(user.bio),
              )
            ],
          ),
        );
      },
    );
  }

  buildNoContent() {
    return Center(
      child: SvgPicture.asset(
        'assets/images/no_content.svg',
        height: 100,
      ),
    );
  }

  buildGridProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }

    if (posts.length == 0) {
      buildNoContent();
    }

    return GridView.builder(
      itemBuilder: (context, index) {
        return GridTile(child: PostTile(posts[index]));
      },
      shrinkWrap: true,
      itemCount: posts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
      ),
    );
  }

  buildListProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }

    if (posts.length == 0) {
      buildNoContent();
    }

    return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostItem(posts[index]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile'),
      body: NestedScrollView(
        controller: ScrollController(keepScrollOffset: true),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([buildProfileHeader()]),
            ),
          ];
        },
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              Divider(
                height: 0.0,
              ),
              Container(
                child: TabBar(
                  unselectedLabelColor: Colors.grey,
                  labelColor: Theme.of(context).accentColor,
                  indicatorColor: Colors.transparent,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.grid_on),
                    ),
                    Tab(icon: Icon(Icons.list))
                  ],
                ),
              ),
              Divider(
                height: 0.0,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    buildGridProfilePosts(),
                    buildListProfilePosts(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
