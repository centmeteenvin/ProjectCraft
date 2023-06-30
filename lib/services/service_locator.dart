
import 'package:get_it/get_it.dart';
import 'package:project_craft/services/firestore.dart';
import 'package:project_craft/services/repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FireStoreService(isTesting:false));
  locator.registerLazySingleton(() {
    return PersonRepository(locator<FireStoreService>());
  });
  locator.registerLazySingleton(() {
    return ProjectRepository(locator<FireStoreService>());
  });
  locator.registerLazySingleton(() {
    return TaskRepository(locator<FireStoreService>());
  });
}