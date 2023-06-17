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
        Person vincent = randomPerson();
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
  group('copyWith Tests', () {
    test('no fields changed', () {
      Person vincent = randomPerson();
      Person vincent2 = vincent.copyWith();
      expect(vincent2, vincent);
    });
    test('name Changed', () {
      Person vincent = randomPerson();
      Person luna = vincent.copyWith(firstName: "Luna Mei", lastName: "Baeyens");
      expect(luna.firstName, "Luna Mei");
      expect(luna.lastName, "Baeyens");
    });

    test('projects changed', () {
      Person random = randomPerson();
      Person other = random.copyWith(projectIds: {"1", "2"});
      expect(other.projectIds, {"1", "2"});
      
    });
  });
}

Person randomPerson() {
        var projectIds = <String>{};
        for (var i = 0; i < 3; i++) {
          projectIds.add(i.toString());
        }
        return Person(
            uuid: "1",
            firstName: "Vincent",
            lastName: "Verbergt",
            photoUrl: "",
            projectIds: projectIds);
}