
import 'package:flutter/material.dart';


@immutable
class Project {
  final String uuid;
  final String title;
  final DateTime startDate;
  final DateTime deadline;

  final String ownerId;
  final Set<String> contributorIds;
  final List<String> taskIds;

  const Project(
      {required this.title,
      required this.ownerId,
      required this.contributorIds,
      required this.startDate,
      required this.deadline,
      required this.taskIds,
      required this.uuid}); 

  ///Converts the current object to a Map with string keys.
  ///All fields that are of type Person, Project or Task, are mapped to their corresponding uuid.
  Map<String, dynamic> toMap() {
    return {
      "uuid":uuid,
      "title":title,
      "startDate":startDate,
      "deadline":deadline,
      "owner":ownerId,
      "contributors":contributorIds.toList(),
      "tasks":taskIds.toList(),
    };
  }

  
}