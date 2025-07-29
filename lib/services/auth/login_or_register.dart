import 'package:flutter/material.dart';
import 'package:my_messenger/pages/login_page.dart';
import 'package:my_messenger/pages/sign_in_page.dart';

class LoginOrSignin extends StatefulWidget {
  const LoginOrSignin({super.key});

  @override
  State<LoginOrSignin> createState() => _LoginOrSigninState();
}

class _LoginOrSigninState extends State<LoginOrSignin> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return SignIn(
        onTap: togglePages,
      );
    }
  }
}
