import 'package:flutter_test/flutter_test.dart';
import 'package:project_craft/services/firestore.dart';
import 'package:project_craft/utils/exceptions.dart';

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

    group('Lock tests', () {
      test('Obtain lock and afterwards release, includes tests for the exceptions', () async {
        expect(await testCollectionEmpty(fs), true);
        var lockable = getLockable();
        var notLockable = getNotLockable();
        var agent = "test agent";
        var collection = "tests";
        expect(lockable.containsKey(isLockedKey), true);
        expect(lockable.containsKey(lockedByKey), true);
        expect(() => fs.obtainLock(collection, lockable["uuid"], agent), throwsA(isA<ResourceDoesNotExistException>()));
        expect(() => fs.releaseLock(collection, lockable["uuid"], agent), throwsA(isA<ResourceDoesNotExistException>()));
        expect(() => fs.obtainLock(collection, notLockable["uuid"]!, agent), throwsA(isA<ResourceDoesNotExistException>()));
        expect(() => fs.releaseLock(collection, notLockable["uuid"]!, agent), throwsA(isA<ResourceDoesNotExistException>()));
        expect(await fs.addDocument(collection, lockable["uuid"], lockable), true);
        expect(await fs.addDocument(collection, notLockable["uuid"]!, notLockable), true);
        expect(() => fs.obtainLock(collection, notLockable["uuid"]!, agent), throwsA(isA<ResourceNotLockableException>()));
        expect(() => fs.releaseLock(collection, notLockable["uuid"]!, agent), throwsA(isA<ResourceNotLockableException>()));
        expect(await fs.releaseLock(collection, lockable["uuid"], agent), false);
        expect(await fs.obtainLock(collection, lockable["uuid"], agent), true);
        expect(await fs.obtainLock(collection, lockable["uuid"], agent), false);
        expect(await fs.releaseLock(collection, lockable["uuid"], agent), true);
        expect(await fs.deleteDocument(collection, notLockable["uuid"]), true);
        expect(await fs.obtainLock(collection, lockable["uuid"], agent), true);
        expect(await fs.deleteDocument(collection, lockable["uuid"], agent: agent), true);
        
      });

      test('Test write operations on a lockable without obtaining the key', () async {
        expect(await testCollectionEmpty(fs), true);
        final lockable = getLockable();
        final notLockable = getNotLockable();
        const collection = "tests";
        expect(await fs.addDocument(collection, lockable["uuid"], lockable), true);
        expect(await fs.addDocument(collection, notLockable["uuid"], notLockable), true);
        lockable["data"] = "new data";
        expect(() => fs.updateDocument(collection, lockable["uuid"], lockable), throwsA(isA<NoAgentException>()));
        expect(() => fs.updateDocument(collection, lockable["uuid"], lockable, agent: ""), throwsA(isA<NotLockedException>()));
        expect(await fs.updateDocument(collection, notLockable["uuid"], notLockable), false);
        expect(() => fs.deleteDocument(collection, lockable["uuid"]), throwsA(isA<NoAgentException>()));
        expect(() => fs.deleteDocument(collection, lockable["uuid"], agent: ""), throwsA(isA<NotLockedException>()));
        expect(await fs.deleteDocument(collection, notLockable["uuid"]), true);
        expect(await fs.obtainLock(collection, lockable["uuid"], "test"), true);
        expect(await fs.deleteDocument(collection, lockable["uuid"], agent: "test"), true);
      });

      test('Test write on a lockable object when obtaining the key but the wrong agent is provided, also test that read action is still available', () async {
        expect(await testCollectionEmpty(fs), true);
        final lockable = getLockable();
        const collection = "tests";
        const agent1 = "agent1";
        const agent2 = "agent2";
        expect(await fs.addDocument(collection, lockable["uuid"], lockable), true);
        expect(await fs.obtainLock(collection, lockable["uuid"], agent1), true);
        lockable[isLockedKey] = true;
        lockable[lockedByKey] = agent1;
        expect(() => fs.updateDocument(collection, lockable["uuid"], lockable, agent: agent2), throwsA(isA<IsLockedException>()));
        expect(() => fs.deleteDocument(collection, lockable["uuid"], agent: agent2), throwsA(isA<IsLockedException>()));
        expect(await fs.fetchDocument(collection, lockable["uuid"]), lockable);
        expect(await fs.deleteDocument(collection, lockable["uuid"], agent: agent1), true);
      });

      test('Test write action on a locked object that', () async {
        expect(await testCollectionEmpty(fs), true);
        final lockable = getLockable();
        const collection = "tests";
        const agent1 = "agent1";
        expect(await fs.addDocument(collection, lockable["uuid"], lockable), true);
        expect(await fs.obtainLock(collection, lockable["uuid"], agent1), true);
        lockable[isLockedKey] = false;
        lockable[lockedByKey] = "fakes";
        lockable["data"] = "updated data";
        expect(await fs.updateDocument(collection, lockable["uuid"], lockable, agent: agent1), false);
        expect(await fs.updateDocument(collection, lockable["uuid"], lockable, agent: agent1), false);
        lockable[isLockedKey] = true;
        lockable[lockedByKey] = agent1;
        expect(await fs.fetchDocument(collection, lockable["uuid"]), lockable);
        expect(await fs.deleteDocument(collection, lockable["uuid"], agent: agent1), true);
        expect(await testCollectionEmpty(fs), true);
      });
    });
  });
}

Future<bool> testCollectionEmpty(FireStoreService fs) async {
      return (await fs.listDocIds("tests")).isEmpty;
}

Map<String, dynamic> getLockable() {
  return {
    isLockedKey:false,
    lockedByKey: "",
    "data": "data",
    "uuid":"lockable",
  };
}

Map<String, dynamic> getNotLockable() => {
          "uuid":"notLockable",
          "data":"data"
        };

