import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_craft/pages/login/login.dart';
import 'package:project_craft/utils/providers.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext , WidgetRef ref) {
    AsyncValue<User?> userStream = ref.watch(userStreamProvider);
    return userStream.when(
      data: (data) {
        ref.read(userProvider.notifier).state = data;
        return const HomeScreen();
      },
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Login(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current projects"),
        centerTitle: true,
        leading: CircleAvatar(
          child: user?.photoURL == null ? const Icon(Icons.abc) : ImageIcon(NetworkImage(user!.photoURL!)),
        ),
      ),
    );
  }
}