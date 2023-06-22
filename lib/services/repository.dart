
import 'package:project_craft/models/model.dart';
import 'package:project_craft/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/person.dart';
import '../models/project.dart';
import '../models/task.dart';

class Repository<T extends Serializable>  {
  final FireStoreService fs;
  late final String collection;
  Repository(this.fs) {
    switch (T) {
      case Task: {
        collection = "Tasks";
      } break;
      case Project: {
        collection = "Projects";
      } break;
      case Person: {
        collection = "Persons";
      } break;
      default: throw TypeError();
    }
  }
  
  ///Creates a model, overwrites previous model if it was already stored. Returns true if a new document was created
  Future<bool> create(T model) async {
    return await fs.addDocument(collection,  model.uuid, model.toMap());
  }

  Future<Serializable?> read(String uuid) async {
    Map<String, dynamic>? data = await fs.fetchDocument(collection , uuid);
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
          flutterMap[key] = (value as List<dynamic>).map((e) => e.toString()).toList();
          break;
        default:
          flutterMap[key] = value;
      }
    });
    switch (T) {
      case Task:
        return Task.fromMap(flutterMap);
      case Project:
        return Project.fromMap(flutterMap);
      case Person:
        return Person.fromMap(flutterMap);
    }
    return null;
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
  Future<bool> delete(T model) async {
    return await fs.deleteDocument(collection, model.uuid);
  }

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
  
}
