import 'package:flutter/material.dart';
import 'package:flutter_share/repositories/post_respository.dart';
import 'package:flutter_share/widgets/post_item.dart';
import '../widgets/header.dart';
import '../models/post_model.dart';
import '../widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  final postRepository = new PostRepository();

  PostScreen({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRepository.getPost(postId: postId, userId: userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        return Center(
          child: Scaffold(
            appBar: header(context, titleText: snapshot.data.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: PostItem(snapshot.data),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
