import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/post.dart';
import 'package:flutter_share/pages/comments.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/widgets/custom_image.dart';

final postRef = Firestore.instance.collection('posts');

class PostWidget extends StatefulWidget {
  final Post post;

  PostWidget(this.post);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  Post post;
  String currentUserId = currentUser?.id;
  int likeCount;
  bool isLiked;
  Map likes;
  bool showHeart = false;

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.getLikeCount(widget.post.likes);
    likes = widget.post.likes;
    isLiked = likes[currentUserId] == true;
  }

  handleLikePost() {
    if (isLiked) {
      postRef
          .document(widget.post.ownerId)
          .collection('userPosts')
          .document(widget.post.postId)
          .updateData({
        'likes.$currentUserId': false,
      });

      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else {
      postRef
          .document(widget.post.ownerId)
          .collection('userPosts')
          .document(widget.post.postId)
          .updateData({
        'likes.$currentUserId': true,
      });

      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });

      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  showComments() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Comments(
        postId: widget.post.postId,
        postOwnerId: widget.post.ownerId,
        postMediaUrl: widget.post.mediaUrl,
      );
    }));
  }

  buildPostHeader() {
    return ListTile(
      contentPadding: EdgeInsets.only(right: 0, left: 16.0),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(widget.post.mediaUrl),
        backgroundColor: Colors.grey,
      ),
      title: Text(
        widget.post.username,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(widget.post.location),
      trailing: IconButton(
        onPressed: () => print(''),
        icon: Icon(Icons.more_vert),
      ),
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(widget.post.mediaUrl),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 500),
                  tween: Tween(begin: 0.2, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, anim, child) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80.0,
                      color: Colors.red,
                    ),
                  ),
                )
              : Text('')
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              onPressed: handleLikePost,
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            IconButton(
              onPressed: showComments,
              icon: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 16.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 16.0),
              child: Text(
                '${widget.post.username}',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 4.0,
            ),
            Expanded(
              child: Text(widget.post.description),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          buildPostHeader(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ),
    );
  }
}
