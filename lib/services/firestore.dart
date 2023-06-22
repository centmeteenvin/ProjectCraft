import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
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

  ///Returns true if a new document was created.
  Future<bool> addDocument(String collection, String docId, Map<String, dynamic> data) async {
    if (await _exists(collection, docId)) return false;
    await  _db.collection(collection).doc(docId).set(data);
    return true;
  }


  ///Returns true if a document was delete.
  Future<bool> deleteDocument(String collection, String docId) async {
    if (!await _exists(collection, docId)) return false;
    await _db.collection(collection).doc(docId).delete();
    return true;
  }

  ///Return true if a new document was created.
  Future<bool> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    if (await _exists(collection, docId)) {
    await _db.collection(collection).doc(docId).update(data);
    return false;
    }
    await addDocument(collection, docId, data);
    return true;
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