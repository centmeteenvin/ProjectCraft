
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
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Project &&
        uuid == other.uuid &&
        title == other.title &&
        startDate == other.startDate &&
        deadline == other.deadline &&
        ownerId == other.ownerId &&
        contributorIds == other.contributorIds &&
        taskIds == other.taskIds
        ;
  }

  @override
  int get hashCode {
    return Object.hash(
      uuid,
      title,
      startDate,
      deadline,
      ownerId,
      contributorIds,
      taskIds,
    );
  }

  Project copyWith({
    String? uuid,
    String? title,
    DateTime? startDate,
    DateTime? deadline,
    String? ownerId,
    Set<String>? contributorIds,
    List<String>? taskIds,
  }) {
    return Project(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      ownerId: ownerId ?? this.ownerId,
      contributorIds: contributorIds ?? this.contributorIds,
      taskIds: taskIds ?? this.taskIds,
    );
  }
}