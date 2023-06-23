import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_craft/models/project.dart';
import 'package:uuid/uuid.dart';

void main() async {
  group('Project Map Tests', () {
    test('Project with empty person, contributors and tasks', () {
      DateTime now = DateTime.now();
      var project = Project(
        uuid: "1",
        title: "test",
        ownerId: "",
        startDate: now,
        deadline: now,
        contributorIds: const <String>{},
        taskIds: const <String>[],
      );
      var resultMap = {
        "uuid": "1",
        "title": "test",
        "startDate": now,
        "deadline": now,
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
        DateTime now = DateTime.now();
        var owner = const Uuid().v4();
        var contributors = randomContributors();
        var tasks = randomTasks();
        Project project = Project(
          uuid: "1",
          title: "test",
          ownerId: owner,
          startDate: now,
          deadline: now,
          contributorIds: contributors,
          taskIds: tasks,
        );
        var resultMap = {
          "title": "test",
          "owner": owner,
          "startDate": now,
          "deadline": now,
          "contributors": contributors.toList(),
          "tasks": tasks,
          "uuid": "1",
        };
        expect(project.toMap(), resultMap);
      }
    });
    test('FromMap tests', () {
      Project project = randomProject();
      Map<String, dynamic> projectMap = project.toMap();
      Project copy = Project.fromMap(projectMap);
      expect(copy.toMap(), projectMap);
    });
  });
  group('CopyWith tests', () {
    test('No fields changed', () {
      Project project1 = randomProject();
      Project project2 = project1.copyWith();
      expect(project1, project2);
    });
    test('DateTime fields changed', () {
      Project project1 = randomProject();
      Project project2 = project1.copyWith(startDate: DateTime.fromMicrosecondsSinceEpoch(1000));
      expect(project2.uuid, project1.uuid);
      expect(project2.startDate, DateTime.fromMicrosecondsSinceEpoch(1000));
    });
    test('contributors fields changed', () {
      Project project1 = randomProject();
      Set<String> contributors = randomContributors();
      Project project2 = project1.copyWith(contributorIds: contributors);
      expect(project1.contributorIds == contributors, false);
      expect(project2.contributorIds == contributors, true);
    });
    test('Tasks changed', () {
      Project project1 = randomProject();
      List<String> tasks = randomTasks();
      Project project2 = project1.copyWith(taskIds: tasks);
      expect(project1.taskIds == tasks, false);
      expect(project2.taskIds == tasks, true);
    });
  });
}

Project randomProject() {
        var owner = const Uuid().v4();
        var tasks = <String>[];
        var contributors = randomContributors();
        var amount = Random().nextInt(20);
        for (int i = 0; i < amount; i++) {
          tasks.add(const Uuid().v4());
        }
        return Project(
          uuid: const Uuid().v4(),
          title: "test",
          ownerId: owner,
          startDate: DateTime.now(),
          deadline: DateTime.now(),
          contributorIds: contributors,
          taskIds: tasks,
        );
}
Set<String> randomContributors() {
        var contributors = <String>{};
        int amount = Random().nextInt(20);
        for (int i = 0; i < amount; i++) {
          contributors.add(const Uuid().v4());
        }
        return contributors;
}
List<String> randomTasks() {
        var tasks = <String>[];
        var amount = Random().nextInt(20);
        for (int i = 0; i < amount; i++) {
          tasks.add(const Uuid().v4());
        }
        return tasks;
}