import 'dart:math';

import 'package:project_craft/models/task.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Task To Map Tests', () {
    test('Task with empty agents, no subtask or dependents', () {
      DateTime now = DateTime.now();
      var task = Task(
        uuid: "1",
        title: "test",
        description: "test description",
        startDate: now,
        deadline: now,
        agentIds: const <String>{},
        subTaskIds: List.empty(),
        dependingOnTaskIds: List.empty(),
        status: Status.toPlan,
      );
      var resultMap = {
        "uuid": "1",
        "title": "test",
        "description": "test description",
        "startDate": now,
        "deadline": now,
        "agents": const <String>{},
        "subTasks": List.empty(),
        "dependingOn": List.empty(),
        "status": Status.toPlan,
      };
      expect(task.toMap(), resultMap);
    });
    test(
        'Task To Map test, with random amount of subtasks, agents, and dependents',
        () {
      for (int n = 0; n < 100; n++) {
        var agents = <String>{};
        int amount = Random().nextInt(20);
        for (int i = 0; i < amount; i++) {
          agents.add(const Uuid().v4());
        }
        var subTasks = <String>[];
        amount = Random().nextInt(20);
        for (int i = 0; i < amount; i++) {
          subTasks.add(const Uuid().v4());
        }
        var dependents = <String>[];
        amount = Random().nextInt(20);
        for (int i = 0; i < amount; i++) {
          dependents.add(const Uuid().v4());
        }

        DateTime now = DateTime.now();
        var task = Task(
          uuid: "1",
          title: "test",
          description: "test description",
          startDate: now,
          deadline: now,
          agentIds: agents,
          subTaskIds: subTasks,
          dependingOnTaskIds: dependents,
          status: Status.toPlan,
        );
        var resultMap = {
          "uuid": "1",
          "title": "test",
          "description": "test description",
          "startDate": now,
          "deadline": now,
          "agents": agents.toList(),
          "subTasks": subTasks,
          "dependingOn": dependents,
          "status": Status.toPlan,
        };
        expect(task.toMap(), resultMap);
      }
    });
  });
}
