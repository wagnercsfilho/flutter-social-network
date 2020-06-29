import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/activity_model.dart';
import 'package:flutter_share/pages/post_screen.dart';
import 'package:flutter_share/pages/profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget mediaPreview;
String activityItemText;

class ActivityItem extends StatelessWidget {
  final Activity activity;

  ActivityItem(this.activity);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: activity.postId,
          userId: activity.userId,
        ),
      ),
    );
  }

  showProfile(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          profileId: activity.userId,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (activity.type == 'like' || activity.type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(
          context,
        ),
        child: Container(
          width: 50.0,
          height: 50.0,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(activity.mediaUrl),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (activity.type == 'like') {
      activityItemText = 'liked your post';
    } else if (activity.type == 'follow') {
      activityItemText = 'is following you';
    } else if (activity.type == 'comment') {
      activityItemText = 'replied ${activity.commentData}';
    } else {
      activityItemText = "Error: Unknown type ${activity.type}";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return (Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                  children: [
                    TextSpan(
                      text: activity.username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' $activityItemText'),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage:
                CachedNetworkImageProvider(activity.userProfileImg),
          ),
          subtitle: Text(
            timeago.format(activity.timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    ));
  }
}
