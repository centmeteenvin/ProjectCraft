import 'dart:math';

import 'package:project_craft/models/project.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Project Map Tests', () {
    test('Project with empty person, contributors and tasks', () {
      var project = Project(
        uuid: "1",
        title: "test",
        ownerId: "",
        startDate: DateTime.now(),
        deadline: DateTime.now(),
        contributorIds: const <String>{},
        taskIds: const <String>[],
      );
      var resultMap = {
        "uuid": "1",
        "title": "test",
        "startDate": DateTime.now(),
        "deadline": DateTime.now(),
        "owner": "",
        "contributors": [],
        "tasks": [],
      };
      expect(project.toMap(), resultMap);
    });
    test(
        'Project with one owner, random contributors, and random amount of tasks',
        () {
      for (int n = 0; n < 100; n++) {
        var owner = const Uuid().v4();
        var contributors = <String>{};
        int amount = Random().nextInt(20);
        for (int i = 0; i < amount; i++) {
          contributors.add(const Uuid().v4());
        }
        var tasks = <String>[];
        amount = Random().nextInt(20);
        for (int i = 0; i < amount; i++) {
          tasks.add(const Uuid().v4());
        }
        var project = Project(
          uuid: "1",
          title: "test",
          ownerId: owner,
          startDate: DateTime.now(),
          deadline: DateTime.now(),
          contributorIds: contributors,
          taskIds: tasks,
        );
        var resultMap = {
          "title": "test",
          "owner": owner,
          "startDate": DateTime.now(),
          "deadline": DateTime.now(),
          "contributors": contributors.toList(),
          "tasks": tasks,
          "uuid": "1",
        };
        expect(project.toMap(), resultMap);
      }
    });
  });
}
