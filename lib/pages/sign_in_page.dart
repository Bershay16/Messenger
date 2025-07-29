// ignore_for_file: no_leading_underscores_for_local_identifiers, must_be_immutable

import 'package:flutter/material.dart';
import 'package:my_messenger/services/auth/auth_service.dart';
import 'package:my_messenger/components/my_textfield.dart';

class SignIn extends StatefulWidget {
  final void Function()? onTap;
  const SignIn({super.key, required this.onTap});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  //sign in method
  void signin(BuildContext context) async {
    final _auth = AuthService();
    setState(() {
      isLoading = true;
    });

    try {
      if (_passwordController.text == _confirmPasswordController.text) {
        await _auth.signUpWithEmailPassword(
            _emailController.text, _passwordController.text);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Passwords Don't Match"),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 50),
              Text(
                "Let's create an account for you",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              MyTextField(
                hintText: "Email...",
                isPassword: false,
                controller: _emailController,
                focusNode: null,
              ),
              MyTextField(
                hintText: "Password...",
                isPassword: true,
                controller: _passwordController,
                focusNode: null,
              ),
              MyTextField(
                hintText: "Confirm Password...",
                isPassword: true,
                controller: _confirmPasswordController,
                focusNode: null,
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: InkWell(
                  onTap: () {
                    signin(context);
                  },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: ShapeDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(50),
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ))),
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          )
                        : Text(
                            "Sign in",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      margin: EdgeInsets.all(5),
                      child: Text(
                        "Log in",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
