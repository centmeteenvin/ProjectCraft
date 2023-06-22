import 'package:flutter_test/flutter_test.dart';
import 'package:project_craft/services/firestore.dart';

void main() {
  group('firestoreService tests', () {
    final fs = FireStoreService(isTesting: true);
    test('check that db is empty', () async {
      var docIds = await fs.listDocIds("tests");
      expect(docIds.isEmpty, true);
      expect(await testCollectionEmpty(fs), true);
    });
    test( 'Add a document to a test collection, check if it is added and afterwards remove it,', () async {
      Map<String, dynamic> data = {"testValue":1};
      expect(await testCollectionEmpty(fs), true);
      expect(await fs.addDocument("tests", "1", data), true);
      expect((await fs.listDocIds("tests")).length, 1);
      expect(await fs.fetchDocument("tests", "1"), data);
      data["testValue"] = 2;
      expect(await fs.addDocument("tests", "1", data), false);
      expect((await fs.listDocIds("tests")).length, 1);
      expect(await fs.fetchDocument("tests", "1"), {"testValue":1});
      expect(await fs.deleteDocument("tests", "1"),  true);
      expect(await fs.deleteDocument("tests", "1"),  false);
      expect(await testCollectionEmpty(fs), true);
    });

    test('Add a document via the update method, change it, delete it', () async {
      Map<String, dynamic> data = {"testValue":1};
      expect(await testCollectionEmpty(fs), true);
      expect(await fs.updateDocument("tests", "1", data), true);
      expect(await fs.fetchDocument("tests", "1"), data);
      data["testValue"]++;
      expect(await fs.updateDocument("tests", "1", data), false);
      expect((await fs.listDocIds("tests")), ["1"]);
      expect(await fs.fetchDocument("tests", "1"), data);
      expect(await fs.deleteDocument("tests", "1"),  true);
      expect(await testCollectionEmpty(fs), true);
    });
  });
}

Future<bool> testCollectionEmpty(FireStoreService fs) async {
      return (await fs.listDocIds("tests")).isEmpty;
}