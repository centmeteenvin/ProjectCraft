
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_craft/services/authentication.dart';

import '../../utils/providers.dart';

class Login extends ConsumerWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width/4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:  [
            Text(
              "Welcome to ProjectCraft",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const LoginButton(),
            if (dotenv.get("MODE") == "development")
              TextButton(onPressed: () async {
                await FirebaseAuth.instance.signInAnonymously();
                ref.read(userProvider.notifier).state = FirebaseAuth.instance.currentUser;
              }, 
              child: const Text("Dev")),
          ],
        ),
      ),
    );
  }
}

class LoginButton extends ConsumerWidget {
  const LoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        await AuthenticationService.loginGoogle();
        ref.read(userProvider.notifier).state = FirebaseAuth.instance.currentUser;
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blue)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Flexible(
              flex: 1,
              child: Icon(
                FontAwesomeIcons.google,
                color: Colors.white,
                size: 30,
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30
                  )
                ),
              ),
            ),
            
          ],
        ),
      ),
      );
  }
}