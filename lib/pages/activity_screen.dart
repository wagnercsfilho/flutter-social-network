import 'package:flutter/material.dart';
import 'package:flutter_share/models/activity_model.dart';
import 'package:flutter_share/pages/home_screen.dart';
import 'package:flutter_share/repositories/activity_repository.dart';
import 'package:flutter_share/states/auth_state.dart';
import 'package:flutter_share/widgets/activity_item.dart';
import 'package:flutter_share/widgets/header.dart';
import 'package:flutter_share/widgets/progress.dart';
import 'package:provider/provider.dart';

class ActivityScreen extends StatefulWidget {
  ActivityScreen({Key key}) : super(key: key);

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final activityRepository = new ActivityRepository();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AuthState>(context);

    return Scaffold(
      appBar: header(context, titleText: 'Activities'),
      body: Container(
        child: FutureBuilder(
          future: activityRepository.getActivities(user: state.currentUser),
          builder: (context, AsyncSnapshot<List<Activity>> snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }

            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ActivityItem(snapshot.data[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
