import 'package:flutter/material.dart';

AppBar header(BuildContext context,
    {bool isAppTitle = false,
    String titleText,
    bool removeBackButton = false,
    List<Widget> actions}) {
  return AppBar(
    automaticallyImplyLeading: !removeBackButton,
    title: Text(
      isAppTitle ? 'Up!' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
    actions: actions,
  );
}
