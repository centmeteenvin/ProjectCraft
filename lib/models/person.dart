

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
    //TODO Unit test.
    return Person(
      uuid:map["uuid"],
      firstName:map["firstName"],
      lastName:map["lastName"],
      photoUrl:map["photoUrl"],
      projectIds:map["projects"],
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