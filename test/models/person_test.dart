import 'package:test/test.dart';
import 'package:project_craft/models/person.dart';

void main() {
  group('Map Tests', () {
    test('ToMap with empty projects', () {
      Person vincent = const Person(
          uuid: "1",
          firstName: "Vincent",
          lastName: "Verbergt",
          photoUrl: "",
          projectIds: <String>{});
      var resultMap = {
        "uuid": "1",
        "firstName": "Vincent",
        "lastName": "Verbergt",
        "photoUrl": "",
        "projects": <String>[]
      };
      expect(vincent.toMap(), resultMap);
    });

    test('toMap with 3 random projects', () {
      for (int n = 0; n < 100; n++) {
        var projectIds = <String>{};
        for (var i = 0; i < 3; i++) {
          projectIds.add(i.toString());
        }
        Person vincent = Person(
            uuid: "1",
            firstName: "Vincent",
            lastName: "Verbergt",
            photoUrl: "",
            projectIds: projectIds);
        var resultMap = {
          "uuid": "1",
          "firstName": "Vincent",
          "lastName": "Verbergt",
          "photoUrl": "",
          "projects": ["0", "1", "2"],
        };
        expect(vincent.toMap(), resultMap);
      }
    });
  });
}
