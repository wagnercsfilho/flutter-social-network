import 'package:flutter/material.dart';
import 'package:flutter_share/locator.dart';
import 'package:flutter_share/pages/auth_screen.dart';
import 'package:flutter_share/pages/home_screen.dart';
import 'package:flutter_share/states/auth_state.dart';
import 'package:flutter_share/widgets/progress.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthState state;

  @override
  void initState() {
    super.initState();
    state = locator<AuthState>();
    state.checkLoginState();
    // Future.microtask(() => context.read<AuthState>().checkLoginState());
  }

  @override
  Widget build(BuildContext context) {
    print(state.authStatus);

    return Scaffold(
      body: Consumer<AuthState>(
        builder: (context, _, child) {
          return Container(
            child: state.authStatus == AuthStatus.NOT_DETERMINED
                ? Center(
                    child: circularProgress(),
                  )
                : state.authStatus == AuthStatus.LOGGED_IN
                    ? Home()
                    : AuthScreen(),
          );
        },
      ),
    );
  }
}
