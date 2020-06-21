import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_share/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  CreateAccount({Key key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      final snackbar = SnackBar(
        content: Center(
          child: Text('Welcome $username!'),
        ),
      );

      _scaffoldKey.currentState.showSnackBar(snackbar);

      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        titleText: 'Setup your profile',
        removeBackButton: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 24.0),
            child: Center(
              child: Text(
                'Create a username',
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidate: true,
              child: TextFormField(
                validator: (val) {
                  if (val.trim().length < 3 || val.isEmpty) {
                    return "Username too short";
                  } else if (val.trim().length > 12) {
                    return "Username too long";
                  } else {
                    return null;
                  }
                },
                onSaved: (val) => username = val,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 15.0),
                  hintText: 'Must be at least 3 characters',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
            child: GestureDetector(
              onTap: submit,
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Center(
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
