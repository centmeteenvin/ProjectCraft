import 'package:project_craft/models/model.dart';

abstract class LockException implements Exception {
  late final dynamic lockable; //Should be a lockable or a map
  final bool lock;
  final String message;

  LockException(this.message, dynamic lockable, this.lock) {
    if (lockable is Lockable || lockable is Map<String, dynamic>) {
      this.lockable = lockable;
    } else {
      throw TypeError();
    }
  }

  @override String toString() => '${runtimeType.toString()}: $message';
}

class IsLockedException extends LockException {
  
  IsLockedException(dynamic object) : super('This object was locked by another instance', object, true);
}

///This objects is a lockable but we tried to execute a write action without obtaining the lock;
class NotLockedException extends LockException {
  NotLockedException(dynamic object) : super('This object is a lockable but we tried to execute a write action without obtaining the lock', object, false);
}

class NoAgentException extends LockException {
  NoAgentException(dynamic object, bool lock) : super('The object being edited is Lockable, but no agent was provided', object, lock);
}

class ResourceDoesNotExistException implements Exception {
  final String message;
  ResourceDoesNotExistException(this.message);

  @override
  String toString() => "${runtimeType.toString()}: $message";
}

class ResourceNotLockableException implements Exception {
  final String message;
  ResourceNotLockableException(this.message);

  @override
  String toString() => "${runtimeType.toString()}: $message";
}