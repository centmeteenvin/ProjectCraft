import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:project_craft/utils/exceptions.dart';
class FireStoreService {

  late final FirebaseFirestore _db;
  FireStoreService({bool isTesting = false}) {
    if (isTesting) {
      final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: "test_user"));
      _db = FakeFirebaseFirestore(
        securityRules: rules,
        authObject: auth.authForFakeFirestore,
      );
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
      if (!data.containsKey(isLockedKey)) {
        transaction.delete(docref);
        return true;
      }
      if (agent == null) {
        throw NoAgentException(data, data[isLockedKey]);
      }
      if (snapshot[isLockedKey] == false) {
        throw NotLockedException(data);
      }
      if (snapshot[lockedByKey] != agent) {
        throw IsLockedException(data);
      }
      transaction.delete(docref);
      return true;
    });
  }//TODO test lock

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
      if (!snapshotData.containsKey(isLockedKey)) {
        transaction.update(docref, data);
        return false;
      }
      if (agent == null) {
        throw NoAgentException(snapshotData, snapshotData[isLockedKey]);
      }
      if (snapshot[isLockedKey] == false) {
        throw NotLockedException(snapshotData);
      }
      if (snapshot[lockedByKey] != agent) {
        throw IsLockedException(snapshotData);
      }
      data.remove(isLockedKey);
      data.remove(lockedByKey);
      transaction.update(docref, data);
      return false;
    });
  }//TODO test lock

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

  /// Try to obtain the lock for a lockable document, only tries it once. returns true for when lock is obtained. if document was already locked return false
  Future<bool> obtainLock(String collection, String docId, String agent) async {
    var docref = _db.collection(collection).doc(docId);
    return await _db.runTransaction<bool>((transaction) async {
      var snapshot = await transaction.get(docref);
      if (!snapshot.exists) {
        throw ResourceDoesNotExistException("The resource wasn't stored in the database and could not be locked");
      }
      var data = snapshot.data()!;
      if (!data.containsKey(isLockedKey)) {
        throw ResourceNotLockableException("The resource you tried to lock does not contain the lock field");
      }
      if (data[isLockedKey] == true) {
        return false;
      }
      transaction.update(docref, {isLockedKey:true, lockedByKey:agent});
      return true;
      });
  }//TODO test


  ///Try to release the lock, returns true if we had the lock and released it otherwise returns false.
  Future<bool> releaseLock(String collection, String docId, String agent) async {
    var docref = _db.collection(collection).doc(docId);
    return await _db.runTransaction<bool>((transaction) async {
      var snapshot = await transaction.get(docref);
      if (!snapshot.exists) {
        throw ResourceDoesNotExistException("The resource wasn't stored in the database and could no be unlocked");
      }
      var data = snapshot.data()!;
      if (!data.containsKey(isLockedKey)) {
        throw ResourceNotLockableException("The resource did not contain the lock fields");
      }
      if (data[isLockedKey] == false) {
        return false;
      }
      if (data[lockedByKey] != agent) {
        return false;
      }
      transaction.update(docref, {isLockedKey:false, lockedByKey:""});
      return true;
    });
  }//TODO test

} 

const String rules = '''
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
	}
}''';
//TODO security rules that include the resource and collection functionality. I don't want to update firestore rules in console if I cannot test it here.

const String isLockedKey = "isLocked";
const String lockedByKey = "lockedBy";