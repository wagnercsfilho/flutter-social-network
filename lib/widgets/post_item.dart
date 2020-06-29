import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/post_model.dart';
import 'package:flutter_share/pages/comments_screen.dart';
import 'package:flutter_share/repositories/activity_repository.dart';
import 'package:flutter_share/repositories/like_repository.dart';
import 'package:flutter_share/states/auth_state.dart';
import 'package:flutter_share/widgets/custom_image.dart';
import 'package:provider/provider.dart';

class PostItem extends StatefulWidget {
  final Post post;

  PostItem(this.post);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  Post post;
  int likeCount;
  bool isLiked;
  Map likes;
  bool showHeart = false;
  AuthState state;

  final likeRepository = new LikeRepository();
  final activityRepository = new ActivityRepository();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    state ??= Provider.of<AuthState>(context);

    likeCount = widget.post.getLikeCount(widget.post.likes);
    likes = widget.post.likes;
    isLiked = (likes[state.currentUser.id] == true);
  }

  handleLikePost() {
    final state = Provider.of<AuthState>(context);

    if (isLiked) {
      likeRepository.dislike(user: state.currentUser, post: widget.post);
      activityRepository.removeLikeToActivityFeed(
        post: widget.post,
      );

      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[state.currentUser.id] = false;
      });
    } else {
      likeRepository.like(user: state.currentUser, post: widget.post);
      activityRepository.addLikeToActivityFeed(
        currentUser: state.currentUser,
        post: widget.post,
      );

      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[state.currentUser.id] = true;
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
      return CommentsScreen(
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
