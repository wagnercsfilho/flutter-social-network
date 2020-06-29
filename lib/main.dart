import 'package:flutter/material.dart';
import 'package:flutter_share/locator.dart';
import 'package:flutter_share/pages/splash_screen.dart';
import 'package:flutter_share/states/auth_state.dart';
import 'package:provider/provider.dart';

void main() async {
  await setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => locator<AuthState>(),
        )
      ],
      child: MaterialApp(
        title: 'Up',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
