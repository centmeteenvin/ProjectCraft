import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_craft/pages/login/login.dart';
import 'package:project_craft/utils/providers.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext , WidgetRef ref) {
    var UserStream = ref.watch(userStreamProvider);
    return UserStream.when(
      data: (data) => const Text("HomeScreen"),
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Login(),
    );
  }
}