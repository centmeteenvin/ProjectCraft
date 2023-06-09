import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_craft/utils/routes.dart' as route;
import 'firebase_options.dart';

void main() async {
  await dotenv.load(fileName: "../.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(const ProjectCraft());
}

class ProjectCraft extends StatelessWidget {
  const ProjectCraft({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: route.routes,
      initialRoute: "/home",
    );
  }
}

