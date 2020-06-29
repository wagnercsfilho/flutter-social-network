import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user_model.dart';
import 'package:flutter_share/widgets/progress.dart';
import 'package:flutter_svg/svg.dart';

final userRef = Firestore.instance.collection('users');

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  clearSearch() {
    searchController.clear();
  }

  handleSearch(String query) {
    final usersFeature = userRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .getDocuments();

    setState(() {
      searchResultsFuture = usersFeature;
    });
  }

  buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        onFieldSubmitted: handleSearch,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search for a user...',
          filled: true,
          prefixIcon: Icon(Icons.account_box),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
          contentPadding: EdgeInsets.only(top: 14),
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, AsyncSnapshot<QuerySnapshot> snaphost) {
        if (!snaphost.hasData) {
          return circularProgress();
        }

        List<Widget> searchResults = [];

        snaphost.data.documents.forEach((doc) {
          final user = User.fromDocument(doc);
          final item = buildUserItem(user);

          searchResults.add(item);
        });

        return ListView(
          children: searchResults,
        );
      },
    );
  }

  buildUserItem(User user) {
    return GestureDetector(
      onTap: () => print('tapped'),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(user.photoUrl),
        ),
        title: Text(user.displayName),
        subtitle: Text(user.username),
      ),
    );
  }

  buildNoContent() {
    final Orientation orientaion = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset(
                'assets/images/search.svg',
                height: orientaion == Orientation.portrait ? 150 : 150,
              ),
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}
