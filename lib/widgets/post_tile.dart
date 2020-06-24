import 'package:flutter/material.dart';
import 'package:flutter_share/models/post.dart';
import 'package:flutter_share/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () => print('showing post'),
        child: cachedNetworkImage(post.mediaUrl),
      ),
    );
  }
}
