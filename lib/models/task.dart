import 'package:flutter/material.dart';
import 'package:project_craft/models/model.dart';
import 'package:project_craft/services/firestore.dart';

enum Status { toPlan, planned, started, completed, delayed }

@immutable
class Task extends Lockable {
  @override
  final String uuid;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime deadline;
  final Status status;

  final Set<String> agentIds;
  final List<String> subTaskIds;
  final List<String> dependingOnTaskIds;

  @override
  final bool isLocked;
  @override
  final String lockedBy;

  @override
  Task(
      {required this.title,
      required this.description,
      required this.agentIds,
      required this.subTaskIds,
      required this.dependingOnTaskIds,
      required this.startDate,
      required this.deadline,
      required this.status,
      required this.uuid,
      required this.isLocked,
      required this.lockedBy});

  ///Converts the current object to a Map with string keys.
  ///All fields that are of type Person, Project or Task, are mapped to their corresponding uuid.
  @override
  Map<String, dynamic> toMap() {
    return {
      "uuid": uuid,
      "title": title,
      "description": description,
      "startDate": startDate,
      "deadline": deadline,
      "status": status.name,
      "agents": agentIds.toList(),
      "subTasks": subTaskIds,
      "dependingOn": dependingOnTaskIds,
      isLockedKey: isLocked,
      lockedByKey: lockedBy
    };
  }

  @override
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      uuid: map["uuid"],
      title: map["title"],
      description: map["description"],
      startDate: map["startDate"],
      deadline: map["deadline"],
      status:
          Status.values.firstWhere((element) => element.name == map["status"]),
      agentIds: (map["agents"] as List<String>).toSet(),
      subTaskIds: map["subTasks"] as List<String>,
      dependingOnTaskIds: map["dependingOn"] as List<String>,
      isLocked: map[isLockedKey],
      lockedBy: map[lockedByKey],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid &&
          title == other.title &&
          description == other.description &&
          agentIds == other.agentIds &&
          subTaskIds == other.subTaskIds &&
          dependingOnTaskIds == other.dependingOnTaskIds &&
          startDate == other.startDate &&
          deadline == other.deadline &&
          status == other.status;

  @override
  int get hashCode => Object.hash(uuid, title, description, agentIds,
      subTaskIds, dependingOnTaskIds, startDate, deadline, status);

  Task copyWith({
    String? uuid,
    String? title,
    String? description,
    Set<String>? agentIds,
    List<String>? subTaskIds,
    List<String>? dependingOnTaskIds,
    DateTime? startDate,
    DateTime? deadline,
    Status? status,
    bool? isLocked,
    String? lockedBy,
  }) {
    return Task(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      agentIds: agentIds ?? this.agentIds,
      subTaskIds: subTaskIds ?? this.subTaskIds,
      dependingOnTaskIds: dependingOnTaskIds ?? this.dependingOnTaskIds,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      isLocked: isLocked ?? this.isLocked,
      lockedBy: lockedBy ?? this.lockedBy,
    );
  }
}
