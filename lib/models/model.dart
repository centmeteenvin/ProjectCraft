
abstract class Serializable {
  String get uuid;
  String get collectionName;
  Map<String, dynamic> toMap();
  factory Serializable.fromMap(Map<String,dynamic> map) => throw UnimplementedError();
}
