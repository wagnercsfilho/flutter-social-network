import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/comment.dart';
import 'package:flutter_share/pages/home.dart';
import '../widgets/progress.dart';
import '../widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;

final commentRef = Firestore.instance.collection('comments');

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({this.postId, this.postMediaUrl, this.postOwnerId});

  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMediaUrl: this.postMediaUrl);
}

class CommentsState extends State<Comments> {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  TextEditingController commentController = TextEditingController();

  CommentsState({this.postId, this.postMediaUrl, this.postOwnerId});

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
    final DateTime timestamp = DateTime.now();

    commentRef.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timestamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id
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
          Divider(),
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
