import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/comment_model.dart';
import 'package:flutter_share/states/auth_state.dart';
import 'package:provider/provider.dart';
import '../widgets/progress.dart';
import '../widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;

final commentRef = Firestore.instance.collection('comments');

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsScreen({this.postId, this.postMediaUrl, this.postOwnerId});

  @override
  CommentsScreenState createState() => CommentsScreenState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMediaUrl: this.postMediaUrl);
}

class CommentsScreenState extends State<CommentsScreen> {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  TextEditingController commentController = TextEditingController();

  CommentsScreenState({this.postId, this.postMediaUrl, this.postOwnerId});

  buildComments() {
    return StreamBuilder(
      stream: commentRef
          .document(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];

        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });

        return ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                ListTile(
                  title: Text(comments[index].comment),
                  leading: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(comments[index].avatarUrl),
                  ),
                  subtitle:
                      Text(timeago.format(comments[index].timestamp.toDate())),
                ),
                Divider(),
              ],
            );
          },
        );
      },
    );
  }

  addComment() {
    final state = Provider.of<AuthState>(context);
    final DateTime timestamp = DateTime.now();

    commentRef.document(postId).collection('comments').add({
      'username': state.currentUser.username,
      'comment': commentController.text,
      'timestamp': timestamp,
      'avatarUrl': state.currentUser.photoUrl,
      'userId': state.currentUser.id
    });

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(
            height: 1.0,
          ),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Write a comment'),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          )
        ],
      ),
    );
  }
}
