import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/activity_model.dart';
import 'package:flutter_share/models/comment_model.dart';
import 'package:flutter_share/models/post_model.dart';
import 'package:flutter_share/models/user_model.dart';

final activityRef = Firestore.instance.collection('activities');

class ActivityRepository {
  addLikeToActivityFeed({@required User currentUser, @required Post post}) {
    final timestamp = new DateTime.now();

    activityRef
        .document(post.ownerId)
        .collection('activities')
        .document(post.postId)
        .setData({
      "type": 'like',
      "username": currentUser.username,
      "userId": currentUser.id,
      "userProfileImg": currentUser.photoUrl,
      "postId": post.postId,
      "mediaUrl": post.mediaUrl,
      "timestamp": timestamp
    });
  }

  removeLikeToActivityFeed({@required Post post}) {
    activityRef
        .document(post.ownerId)
        .collection('activities')
        .document(post.postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  addCommentToAcitivity({
    @required Post post,
    @required Comment comment,
    @required User user,
  }) {
    final timestamp = new DateTime.now();

    activityRef.document(post.ownerId).collection('activities').add({
      'type': 'comment',
      'commentData': comment.comment,
      'timestamp': timestamp,
      'postId': post.postId,
      'username': user.username,
      'userId': user.id,
      'userProfileImg': user.photoUrl,
      "mediaUrl": post.mediaUrl,
    });
  }

  Future<List<Activity>> getActivities({@required User user}) async {
    final snapshot = await activityRef
        .document(user.id)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();

    List<Activity> feedItems = [];

    snapshot.documents.forEach((doc) {
      feedItems.add(Activity.fromDocument(doc));
    });

    return feedItems;
  }
}
