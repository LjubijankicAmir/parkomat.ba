import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The app's single SQLite database. Tables are added by the features that
/// own them.
@DriftDatabase()
class AppDatabase extends _$AppDatabase {
  /// Pass an [executor] in tests, e.g. `NativeDatabase.memory()`.
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'parkomat',
              // On the web, SQLite runs as WebAssembly in a worker. Both files
              // live in `web/` and come from the drift release matching the
              // locked drift version.
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (details) async {
      // SQLite ignores foreign keys unless they're enabled per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
