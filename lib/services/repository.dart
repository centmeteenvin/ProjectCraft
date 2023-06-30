import 'package:project_craft/models/model.dart';
import 'package:project_craft/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_craft/utils/exceptions.dart';

import '../models/person.dart';
import '../models/project.dart';
import '../models/task.dart';

abstract class Repository<T extends Serializable> {
  final FireStoreService fs;
  late final String collection;
  Repository(this.fs);

  ///Creates a model. Doesn't overwrite previous date if the document didn't exist . Returns true if a new document was created
  Future<bool> create(T model) async {
    return await fs.addDocument(collection, model.uuid, model.toMap());
  }

  ///Returns null if object did not exist
  Future<Map<String, dynamic>?> _read(String uuid) async {
    Map<String, dynamic>? data = await fs.fetchDocument(collection, uuid);
    if (data == null) {
      return null;
    }
    //Firestore might store data in different models than we do eg: Timestamp <-> DateTime
    Map<String, dynamic> flutterMap = {};
    data.forEach((key, value) {
      switch (value.runtimeType) {
        case Timestamp:
          flutterMap[key] = (value as Timestamp).toDate();
          break;
        case List<dynamic>:
          flutterMap[key] =
              (value as List<dynamic>).map((e) => e.toString()).toList();
          break;
        default:
          flutterMap[key] = value;
      }
    });
    return flutterMap;
  }

  ///Read all the ids from the elements in the repository
  Future<List<String>> readAllIds() async {
    return await fs.listDocIds(collection);
  }

  ///saves model in the firestore, returns true if new document was created.
  Future<bool> save(T model) async {
    return await fs.updateDocument(collection, model.uuid, model.toMap());
  }

  ///Delete a model in the firestore, returns true if a document was deleted.
  Future<bool> delete(Serializable model) async {
    return await fs.deleteDocument(collection, model.uuid);
  }

  ///Delete a model in the firestore, returns true if a document was deleted.
  Future<bool> deleteById(String uuid) async {
    return await fs.deleteDocument(collection, uuid);
  }

  ///Delete all entries from the repository, return the amount of entries deleted.
  Future<int> deleteAll() async {
    List<String> ids = await readAllIds();
    for (String id in ids) {
      await deleteById(id);
    }
    return ids.length;
  }

  Future<T?> read(String uuid);
}

abstract class LockedRepository<T extends Lockable> extends Repository<T> {
  Person agent;
  LockedRepository(super.fs, this.agent);

  ///Returns true if the object is locked by us.
  Future<bool> checkLock(String uuid) async {
      Map<String,dynamic>? model = await _read(uuid);
    if (model == null) {
      return false;
    }
    if (model[isLockedKey] == false) {
      return false;
    }
    return model[lockedByKey] == agent.uuid;
  }

  /// Tries to obtain the lock otherwise returns false;
  Future<bool> obtainLock(Lockable model) async {
    return (await fs.obtainLock(collection, model.uuid, agent.uuid));
  }

  ///Releases the lock, returns true if you had it and released it.
  Future<bool> releaseLock(Lockable model) async {
    return await fs.releaseLock(collection, model.uuid, agent.uuid);
  }

  ///Save the given model in the db, returns true if a new document was created.
  ///throws [NotLockedException] if we dit not obtain the lock.
  @override
  Future<bool> save(T model ) async {
    if (await checkLock(model.uuid)) {
      return await fs.updateDocument(collection, model.uuid, model.toMap(), agent: agent.uuid);
    }
    throw NotLockedException(model.toMap());
  }

  ///Delete a model in the firestore, returns true if a document was deleted.
  ///Throws [NotLockedException] if the object was not locked.
  @override
  Future<bool> deleteById(String uuid) async {
    if (await checkLock(uuid)) {
      return await fs.deleteDocument(collection, uuid, agent: agent.uuid);
    }
    throw NotLockedException({"uuid":uuid});
  }

  ///Delete a model in the firestore, returns true if a document was deleted.
  ///Throws [NotLockedException] if the object was not locked.
  @override
  Future<bool> delete(Serializable model) {
    return deleteById(model.uuid);
  }

  ///Delete all models that are locked by us
  @override
  Future<int> deleteAll() async {
    int count = 0;
    List<String> ids = await readAllIds();
    for (var element in ids) {
      if (await checkLock(element)) {
        await deleteById(element);
        count++;
      }
    }
    return count;
  }
}

class ProjectRepository extends Repository<Project> {
  ProjectRepository(super.fs) {
    collection = "Projects";
  }
  
  @override
  Future<Project?> read(String uuid) async {
    Map<String, dynamic>? map = await _read(uuid);
    return map == null ? null : Project.fromMap(map);
  }
}

class PersonRepository extends Repository<Person> {
  PersonRepository(super.fs) {
    collection = "Persons";
  }
  
  @override
  Future<Person?> read(String uuid) async {
    Map<String, dynamic>? map = await _read(uuid);
    return map == null ? null : Person.fromMap(map);
  }
}

class TaskRepository extends LockedRepository<Task> {
  TaskRepository(super.fs, super.agent) {
    collection = "Tasks";
  }

  @override
  Future<Task?> read(String uuid) async {
    Map<String, dynamic>? map = await _read(uuid);
    return map == null ? null : Task.fromMap(map);
  }
}

