

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_craft/models/model.dart';
import 'package:project_craft/services/repository.dart';
import 'package:project_craft/services/service_locator.dart';

@immutable
class Person implements Serializable{
  final String firstName;
  final String lastName;
  final String photoUrl;
  @override
  final String uuid;
  final Set<String> projectIds;
  @override

  const Person(
      {required this.uuid,
      required this.firstName,
      required this.lastName,
      required this.photoUrl,
      required this.projectIds});

  @override
  Map<String, dynamic> toMap() {
    return {
      "uuid":uuid,
      "firstName":firstName,
      "lastName":lastName,
      "photoUrl":photoUrl,
      "projects": projectIds.toList(),
    };
  }

  @override
  ///Converts the current object to a Map with string keys.
  ///All fields that are of type Person, Project or Task, are mapped to their corresponding uuid.
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      uuid:map["uuid"],
      firstName:map["firstName"],
      lastName:map["lastName"],
      photoUrl:map["photoUrl"],
      projectIds:(map["projects"] as List).toSet() as Set<String>,
    );
  }

Person copyWith(
      {String? uuid,
      String? firstName,
      String? lastName,
      String? photoUrl,
      Set<String>? projectIds}) {
    return Person(
      uuid: uuid ?? this.uuid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      projectIds: projectIds ?? this.projectIds,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        photoUrl == other.photoUrl &&
        uuid == other.uuid &&
        projectIds == other.projectIds;
  }

  @override
  int get hashCode {
    return Object.hash(
      firstName,
      lastName,
      photoUrl,
      uuid,
      projectIds,
    );
  }
}

class PersonNotifier extends StateNotifier<Person?> {
  PersonNotifier(super.state);

  Future<void> fetchFromFireStore(String uuid) async {
    var repository = locator<PersonRepository>();
    Person? person = await repository.read(uuid);
    if (person == null) {
      var user = FirebaseAuth.instance.currentUser!;
      List<String> nameParts = (user.displayName ?? "anon").split(' ');
      state = Person(uuid: user.uid, firstName: nameParts.first, lastName: nameParts.last, photoUrl: user.photoURL ?? "", projectIds: const <String>{});
      repository.create(state!);
      return;
    }
    state = person;
  }

}