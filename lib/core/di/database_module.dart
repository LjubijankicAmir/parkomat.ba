import 'package:injectable/injectable.dart';
import 'package:parkomat/data/datasources/local/app_database.dart';

@module
abstract class DatabaseModule {
  @LazySingleton(dispose: closeDatabase)
  AppDatabase get database => AppDatabase();
}

Future<void> closeDatabase(AppDatabase database) => database.close();
