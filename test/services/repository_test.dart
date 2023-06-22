
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_craft/models/task.dart';
import 'package:project_craft/services/firestore.dart';
import 'package:project_craft/services/repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('CRUD method tests', () {
      FireStoreService fs = FireStoreService(isTesting: true);
      Repository<Task> repository = Repository(fs);
    test('Create a Task and remove it', () async {
      Task task = randomTask();
      expect(await repository.create(task), true);
      expect(await repository.create(task), false);
      expect(await repository.delete(task), true);
      expect(await repository.delete(task), false);
    });
    test('Create a Task, read it and remove it', () async {
      Task task = randomTask();
      expect(await repository.create(task), true);
      expect((await repository.read(task.uuid))!.toMap(), task.toMap());
      expect(await repository.delete(task), true);
    });
    test('Create a task via save method, update it and remove it', () async {
      Task task = randomTask();
      expect(await repository.save(task), true);
      expect((await repository.read(task.uuid))!.toMap(), task.toMap());
      Task updatedTask = task.copyWith(title: "Different Title");
      expect(await repository.save(updatedTask), false);
      expect((await repository.read(updatedTask.uuid))!.toMap(), updatedTask.toMap());
      expect(await repository.deleteById(task.uuid), true);
      expect(await repository.delete(updatedTask), false);
    });
    test('Add 2 tasks check if the contain the correct content, check the collection ids, remove them', () async {
      Task task1 = randomTask();
      Task task2 = randomTask();
      Task task3 = randomTask();
      expect(task1 == task2, false);
      expect(task1 == task3, false);
      expect(task3 == task2, false);
      expect((await repository.readAllIds()).length, 0);
      expect(await repository.create(task1), true);
      expect((await repository.readAllIds()).length, 1);
      expect(await repository.create(task2), true);
      expect((await repository.readAllIds()).length, 2);
      expect(await repository.create(task3), true);
      expect((await repository.readAllIds()).length, 3);
      expect((await repository.read(task1.uuid))!.toMap(), task1.toMap());
      expect((await repository.read(task2.uuid))!.toMap(), task2.toMap());
      expect((await repository.read(task3.uuid))!.toMap(), task3.toMap());
      expect(await repository.deleteById(task1.uuid), true);
      expect(await repository.deleteById(task1.uuid), false);
      expect((await repository.readAllIds()).length, 2);
      expect(await repository.deleteAll(), 2);
      expect((await repository.readAllIds()).length, 0);


    });
  });
}

Task randomTask() {
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
        return Task(
          uuid: const Uuid().v4(),
          title: "test",
          description: "test description",
          startDate: now,
          deadline: now,
          agentIds: agents,
          subTaskIds: subTasks,
          dependingOnTaskIds: dependents,
          status: Status.toPlan,
        );
}