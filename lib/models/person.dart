

import 'package:flutter/material.dart';

@immutable
class Person {
  final String firstName;
  final String lastName;
  final String photoUrl;
  final String uuid;
  final Set<String> projectIds;

  const Person(
      {required this.uuid,
      required this.firstName,
      required this.lastName,
      required this.photoUrl,
      required this.projectIds});

  Map<String, dynamic> toMap() {
    return {
      "uuid":uuid,
      "firstName":firstName,
      "lastName":lastName,
      "photoUrl":photoUrl,
      "projects": projectIds.toList(),
    };
  }

  ///Converts the current object to a Map with string keys.
  ///All fields that are of type Person, Project or Task, are mapped to their corresponding uuid.
  static Person fromMap(Map<String, dynamic> map) {
    return Person(
      uuid:map["uuid"],
      firstName:map["firstName"],
      lastName:map["lastName"],
      photoUrl:map["photoUrl"],
      projectIds:map["projects"],
    );
  }
}
