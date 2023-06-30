import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_craft/models/person.dart';

final userStreamProvider = StreamProvider((ref) => FirebaseAuth.instance.authStateChanges());
final userProvider = StateProvider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});
final currentPersonProvider = StateNotifierProvider<PersonNotifier, Person?>((ref) => PersonNotifier(null),);