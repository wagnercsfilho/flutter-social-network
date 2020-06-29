import 'package:flutter/material.dart';
import 'package:flutter_share/models/post_model.dart';
import 'package:flutter_share/pages/post_screen.dart';
import 'package:flutter_share/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: this.post.postId,
          userId: this.post.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () => showPost(context),
        child: cachedNetworkImage(post.mediaUrl),
      ),
    );
  }
}
