import 'package:flutter/material.dart';
import 'package:flutter_share/models/user_model.dart';
import 'package:flutter_share/repositories/auth_repository.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class AuthState with ChangeNotifier {
  final AuthRepository authRepository;

  User currentUser;
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  AuthState({@required this.authRepository});

  checkLoginState() async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        authStatus = AuthStatus.LOGGED_IN;
        currentUser = user;
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      }
    } catch (error) {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<User> login() async {
    final user = await authRepository.login();
    authStatus = AuthStatus.LOGGED_IN;
    currentUser = user;

    notifyListeners();

    return user;
  }

  updateProfile({String displayName, String bio}) async {
    await userRef.document(currentUser.id).updateData({
      'displayName': displayName,
      'bio': bio,
    });

    final user = await authRepository.getCurrentUser();
    currentUser = user;

    notifyListeners();
  }
}
