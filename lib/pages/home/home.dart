import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_craft/pages/login/login.dart';
import 'package:project_craft/utils/providers.dart';
import 'dart:developer';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    AsyncValue<User?> userStream = ref.watch(userStreamProvider);
    return userStream.when(
      data: (data) {
        if (data == null) {
          return const Login();
        }
        return const HomeScreen();
      },
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: CircularProgressIndicator(),),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user = ref.watch(userProvider);
    log(user.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current projects"),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            child: user?.photoURL == null
                ? const Icon(Icons.person_outline)
                : ImageIcon(NetworkImage(user!.photoURL!)),
            
          ),
        ),
        actions: [
          IconButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            ref.read(userProvider.notifier).state = null;
          },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}