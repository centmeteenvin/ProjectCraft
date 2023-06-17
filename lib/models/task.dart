import 'package:flutter/material.dart';
import 'package:project_craft/models/person.dart';

enum Status { toPlan, planned, started, completed, delayed }

@immutable
class Task {
  final String uuid;
  final String title;
  final String description;
  final Set<String> agentIds;
  final List<String> subTaskIds;
  final List<String> dependingOnTaskIds;
  final DateTime startDate;
  final DateTime deadline;
  final Status status;

  const Task(
      {required this.title,
      required this.description,
      required this.agentIds,
      required this.subTaskIds,
      required this.dependingOnTaskIds,
      required this.startDate,
      required this.deadline,
      required this.status,
      required this.uuid});

  ///Converts the current object to a Map with string keys.
  ///All fields that are of type Person, Project or Task, are mapped to their corresponding uuid.
  Map<String, dynamic> toMap() {
    return {
      "uuid": uuid,
      "title": title,
      "description": description,
      "startDate": startDate,
      "deadline": deadline,
      "status": status,
      "agents": agentIds.toList(),
      "subTasks": subTaskIds,
      "dependingOn": dependingOnTaskIds,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid &&
          title == other.title &&
          description == other.description &&
          agentIds  == other.agentIds &&
          subTaskIds == other.subTaskIds &&
          dependingOnTaskIds == other.dependingOnTaskIds &&
          startDate == other.startDate &&
          deadline == other.deadline &&
          status == other.status;

  @override
  int get hashCode =>
    Object.hash(uuid, title, description, agentIds, subTaskIds, dependingOnTaskIds, startDate, deadline, status);

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
    );
  }
}