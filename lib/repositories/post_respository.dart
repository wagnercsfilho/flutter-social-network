import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/models/post_model.dart';

final postRef = Firestore.instance.collection('posts');

class PostRepository {
  getPost({String postId, String userId}) async {
    final snapshot = await postRef
        .document(userId)
        .collection('userPosts')
        .document(postId)
        .get();

    if (!snapshot.exists) {
      return [];
    }

    return Post.fromDocument(snapshot);
  }
}
