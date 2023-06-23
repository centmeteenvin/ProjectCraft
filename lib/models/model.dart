
abstract class Serializable {
  String get uuid;
  Map<String, dynamic> toMap();
  static Serializable fromMap(Map<String, dynamic> map) => throw UnimplementedError();
  // factory Serializable.fromMap(Map<String,dynamic> map) => throw UnimplementedError();
}

abstract class Lockable {
  bool get isLocked;
  String get lockedBy;
}