import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/models/post_model.dart';
import 'package:flutter_share/models/user_model.dart';

final postRef = Firestore.instance.collection('posts');

class LikeRepository {
  like({Post post, User user}) async {
    return postRef
        .document(post.ownerId)
        .collection('userPosts')
        .document(post.postId)
        .updateData({
      'likes.${user.id}': true,
    });
  }

  dislike({Post post, User user}) async {
    return postRef
        .document(post.ownerId)
        .collection('userPosts')
        .document(post.postId)
        .updateData({
      'likes.${user.id}': false,
    });
  }
}
