import 'package:flutter_test/flutter_test.dart';
import 'package:project_craft/models/person.dart';
import 'package:project_craft/models/project.dart';
import 'package:project_craft/models/task.dart';
import 'package:project_craft/services/firestore.dart';
import 'package:project_craft/services/repository.dart';
import 'package:project_craft/utils/exceptions.dart';

import '../models/person_test.dart';
import '../models/project_test.dart';
import '../models/task_test.dart';

void main() {
  group('CRUD method tests on non Lockable objects', () {
    FireStoreService fs = FireStoreService(isTesting: true);
    ProjectRepository repository = ProjectRepository(fs);
    test('Create a Project and remove it', () async {
      Project project = randomProject();
      expect(await repository.create(project), true);
      expect(await repository.create(project), false);
      expect(await repository.delete(project), true);
      expect(await repository.delete(project), false);
    });
    test('Create a Project, read it and remove it', () async {
      Project project = randomProject();
      expect(await repository.create(project), true);
      expect((await repository.read(project.uuid))!.toMap(), project.toMap());
      expect(await repository.delete(project), true);
    });
    test('Create a project via save method, update it and remove it', () async {
      Project project = randomProject();
      expect(await repository.save(project), true);
      expect((await repository.read(project.uuid))!.toMap(), project.toMap());
      Project updatedProject = project.copyWith(title: "Different Title");
      expect(await repository.save(updatedProject), false);
      expect((await repository.read(updatedProject.uuid))!.toMap(),
          updatedProject.toMap());
      expect(await repository.deleteById(project.uuid), true);
      expect(await repository.delete(updatedProject), false);
    });
    test(
        'Add 2 projects check if the contain the correct content, check the collection ids, remove them',
        () async {
      Project project1 = randomProject();
      Project project2 = randomProject();
      Project project3 = randomProject();
      expect(project1 == project2, false);
      expect(project1 == project3, false);
      expect(project3 == project2, false);
      expect((await repository.readAllIds()).length, 0);
      expect(await repository.create(project1), true);
      expect((await repository.readAllIds()).length, 1);
      expect(await repository.create(project2), true);
      expect((await repository.readAllIds()).length, 2);
      expect(await repository.create(project3), true);
      expect((await repository.readAllIds()).length, 3);
      expect((await repository.read(project1.uuid))!.toMap(), project1.toMap());
      expect((await repository.read(project2.uuid))!.toMap(), project2.toMap());
      expect((await repository.read(project3.uuid))!.toMap(), project3.toMap());
      expect(await repository.deleteById(project1.uuid), true);
      expect(await repository.deleteById(project1.uuid), false);
      expect((await repository.readAllIds()).length, 2);
      expect(await repository.deleteAll(), 2);
      expect((await repository.readAllIds()).length, 0);
    });
  });
  group('Lock test for repositories, using the Task model', () {
    FireStoreService fs = FireStoreService(isTesting: true);
    Person agent = randomPerson();
    TaskRepository repository = TaskRepository(fs, agent);
    test('Test that write actions on unlocked objects fail', () async {
      Task task = randomTask();
      expect(await repository.create(task) , true);
      task = task.copyWith(description: "different description");
      expect(await repository.checkLock(task.uuid), false);
      expect(() => repository.save(task), throwsA(isA<NotLockedException>()));
      expect(() => repository.delete(task), throwsA(isA<NotLockedException>()));
      expect(await repository.obtainLock(task), true);
      expect(await repository.checkLock(task.uuid), true);
      expect(await repository.delete(task), true);
    });

    test('Test that write actions on locked objects by another person fail', () async {
      Task task = randomTask();
      expect(await repository.create(task) , true);
      expect(await repository.checkLock(task.uuid), false);
      expect(await repository.obtainLock(task), true);
      expect(await repository.checkLock(task.uuid), true);
      Person agent2 = agent.copyWith(uuid: "2");
      repository.agent = agent2;
      expect(await repository.checkLock(task.uuid), false);
      expect(() => repository.save(task), throwsA(isA<NotLockedException>()));
      expect(() => repository.delete(task), throwsA(isA<NotLockedException>()));
      repository.agent = agent;
      expect(await repository.checkLock(task.uuid), true);
      expect(await repository.delete(task), true);
    });
  });
}
