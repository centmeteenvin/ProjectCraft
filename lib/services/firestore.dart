import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:project_craft/utils/exceptions.dart';
class FireStoreService {

  late final FirebaseFirestore _db;
  FireStoreService({bool isTesting = false}) {
    if (isTesting) {
      _db = FakeFirebaseFirestore();
    } else {
      _db = FirebaseFirestore.instance;
    } 
    
  }
  Future<bool> _exists(String collection, String docId) async {
    var snapshot = await _db.collection(collection).doc(docId).get();
    return snapshot.exists;
  }

  ///Returns true if a new document was created. Doesn't overwrite an existing document.
  Future<bool> addDocument(String collection, String docId, Map<String, dynamic> data) async {
    if (await _exists(collection, docId)) return false;
    await  _db.collection(collection).doc(docId).set(data);
    return true;
  }


  ///Returns true if a document was delete.
  Future<bool> deleteDocument(String collection, String docId, {String? agent}) async {
    final docref = _db.collection(collection).doc(docId);
    return await _db.runTransaction<bool>((transaction) async {
      var snapshot = await transaction.get(docref);
      if (!snapshot.exists) {
        return false;
      }
      var data = snapshot.data()!;
      if (!data.containsKey("isLocked")) {
        transaction.delete(docref);
        return true;
      }
      if (agent == null) {
        throw NoAgentException(data, data["isLocked"]);
      }
      if (snapshot["isLocked"] == false) {
        throw NotLockedException(data);
      }
      if (snapshot["lockedBy"] != agent) {
        throw IsLockedException(data);
      }
      transaction.delete(docref);
      return true;
    });
  }

  ///updates a given document, if the document didn't already exist a new one will be created and returning true,
  ///otherwise return false
  Future<bool> updateDocument(String collection, String docId, Map<String, dynamic> data, {String? agent}) async {
    final docref = _db.collection(collection).doc(docId);
    return await _db.runTransaction<bool>((transaction) async {
      var snapshot = await transaction.get(docref);
      if (!snapshot.exists) {
        transaction.set(docref, data);
        return true;
      }
      var snapshotData = snapshot.data()!;
      if (!snapshotData.containsKey("isLocked")) {
        transaction.update(docref, data);
        return false;
      }
      if (agent == null) {
        throw NoAgentException(snapshotData, snapshotData["isLocked"]);
      }
      if (snapshot["isLocked"] == false) {
        throw NotLockedException(snapshotData);
      }
      if (snapshot["lockedBy"] != agent) {
        throw IsLockedException(snapshotData);
      }
      transaction.update(docref, data);
      return false;
    });
  }

Future<Map<String,dynamic>?> fetchDocument(String collection, String docId) async {
  DocumentSnapshot snapshot = await _db.collection(collection).doc(docId).get();
  if (!snapshot.exists) {
    return null;
  }
  return snapshot.data() as Map<String,dynamic>?;
}
  Future<List<String>> listDocIds(String collection) async {
    var snapshot = await _db.collection(collection).get();
    return snapshot.docs.map((e) => e.id).toList();
  }

} 