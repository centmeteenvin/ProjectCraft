import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_craft/utils/routes.dart' as route;
import 'package:project_craft/utils/theme.dart';
import 'firebase_options.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(const ProviderScope(child: ProjectCraft()));
}

class ProjectCraft extends StatelessWidget {
  const ProjectCraft({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: route.routes,
      initialRoute: "/home",
      theme:  theme,
      debugShowCheckedModeBanner: false,
    );
  }
}

